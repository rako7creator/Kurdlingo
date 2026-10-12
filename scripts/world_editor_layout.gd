class_name WorldEditorLayout
extends RefCounted

# Saved IDs are independent of procedural-builder traversal order.
static func spatial_nodes(root: Node) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for child in root.get_children():
		if child is Node3D: result.append(child)
		result.append_array(spatial_nodes(child))
	return result

static func take_scene(root: Node) -> Node3D:
	var layout = root.get_node_or_null("EditableWorld") as Node3D
	if layout != null: root.remove_child(layout)
	return layout

static func bind_scene(world: Node3D, layout: Node3D) -> bool:
	if layout == null:
		push_error("Saved EditableWorld is missing; refusing to rebuild the city.")
		return false
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_legacy_bindings.json"))
	var identities: Dictionary = {}
	var words: Dictionary = {}
	var guardians: Dictionary = {}
	var rescues: Dictionary = {}
	var seats: Array = []
	var migrated = 0
	for node in layout.get_children():
		if not node.has_meta("world_id") and node.has_meta("layout_index"):
			var old_key = str(int(node.get_meta("layout_index")))
			if legacy.bindings.has(old_key):
				var record: Dictionary = legacy.bindings[old_key]
				node.set_meta("world_id", record.id)
				node.set_meta("world_role", record.role)
				node.set_meta("world_key", record.key)
				migrated += 1
			if legacy.get("collisions", {}).has(old_key):
				node.set_meta("world_collision", legacy.collisions[old_key])
		var identity = str(node.get_meta("world_id", ""))
		if identity != "":
			if identities.has(identity):
				push_error("Duplicate world_id: " + identity + ". Assign a new ID to the copied object.")
				return false
			identities[identity] = node
		var role = str(node.get_meta("world_role", ""))
		if role == "": continue
		if identity == "" or not node is Node3D:
			push_error("Gameplay object lacks a persistent spatial identity: " + str(node.name))
			return false
		var key = str(node.get_meta("world_key", ""))
		var refs: Dictionary
		match role:
			"word":
				if not world.by_id.has(key) or str(node.get_meta("word_id", "")) != key:
					push_error("Invalid vocabulary binding: " + key)
					return false
				refs = words
			"guardian", "rescue":
				if not world.REGION_CENTERS.has(key) or (role == "guardian" and str(node.get_meta("region", "")) != key):
					push_error("Invalid NPC binding: " + role + ":" + key)
					return false
				refs = guardians if role == "guardian" else rescues
			"seat":
				seats.append({"node": node, "word": ""})
				continue
			_:
				push_error("Unknown world_role: " + role)
				return false
		if refs.has(key):
			push_error("Duplicate gameplay binding: " + role + ":" + key)
			return false
		refs[key] = node
		if role == "word" and key in ["chair", "school_chair", "bench", "gallery_bench"]:
			seats.append({"node": node, "word": key})
	for id in world.by_id:
		if not words.has(id):
			push_error("Saved vocabulary object is missing: " + str(id))
			return false
	for region in world.REGION_CENTERS:
		if not guardians.has(region) or not rescues.has(region):
			push_error("Saved NPC references are missing: " + str(region))
			return false
	world.object_nodes = words
	world.guardians = guardians
	world.rescue_cells = rescues
	world.walk_seats = seats
	for child in layout.get_children():
		clear_owners(child)
		layout.remove_child(child)
		# Godot's restored @ auto-names can collide with newly allocated runtime
		# auto-names and leave nodes/resources inaccessible. Reserve saved names
		# in memory only; the editor scene and intentional names stay unchanged.
		if str(child.name).begins_with("@"):
			child.name = "Saved_" + str(child.get_meta("world_id", child.get_instance_id())).replace("-", "")
		if child is Node3D: child.transform = layout.transform * child.transform
		world.add_child(child)
		apply_collision(child)
	layout.free()
	for region in rescues: rescues[region].visible = not region in world.defeated
	for region in guardians:
		if region in world.defeated: guardians[region].scale = Vector3.ONE * 0.75
	if migrated > 0: push_warning("Legacy scene fallback bound " + str(migrated) + " objects; persist IDs before editing this older scene.")
	return true

static func apply_collision(node: Node) -> void:
	var kind = str(node.get_meta("world_collision", ""))
	if kind == "": return
	for child in node.get_children():
		if child is StaticBody3D and child.collision_layer == 4 and kind == "building":
			child.collision_layer = 5
	if kind in ["tree", "pole"] and node is Node3D:
		var dimensions: Vector3 = node.get_meta("dimensions", Vector3.ONE)
		var body = StaticBody3D.new()
		body.name = "MovementTrunk"
		body.collision_layer = 1
		body.collision_mask = 0
		var collision = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		shape.radius = 0.12 if kind == "pole" else clampf(minf(dimensions.x, dimensions.z) * 0.08, 0.18, 0.65)
		shape.height = minf(dimensions.y, 2.5)
		collision.shape = shape
		collision.position.y = shape.height * 0.5
		body.add_child(collision)
		node.add_child(body)

static func flower_instances(root: Node) -> int:
	var total = 0
	for node in spatial_nodes(root):
		if node is MultiMeshInstance3D and node.multimesh != null: total += node.multimesh.instance_count
	return total

static func clear_owners(node: Node) -> void:
	node.owner = null
	for child in node.get_children(): clear_owners(child)
