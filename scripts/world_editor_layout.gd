class_name WorldEditorLayout
extends RefCounted

static func spatial_nodes(root: Node) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for child in root.get_children():
		if child is Node3D:
			result.append(child)
		result.append_array(spatial_nodes(child))
	return result

static func take_scene(root: Node) -> Node3D:
	var layout = root.get_node_or_null("EditableWorld") as Node3D
	if layout != null:
		root.remove_child(layout)
	return layout

# The saved scene supplies the actual geometry, including copies and deletions.
# The builder supplies gameplay references, which are rebound before it is freed.
static func use_scene(world: Node3D, layout: Node3D, generated: Array[Node]) -> void:
	var built: Array[Node3D] = []
	for node in generated:
		if node is Node3D:
			built.append(node)
		built.append_array(spatial_nodes(node))
	var saved: Dictionary = {}
	for node in spatial_nodes(layout):
		if node.has_meta("layout_index"):
			var index = int(node.get_meta("layout_index"))
			# Duplicates retain metadata; keep the first node for gameplay identity.
			if not saved.has(index):
				saved[index] = node
	var replacements: Dictionary = {}
	for index in range(built.size()):
		if saved.has(index):
			replacements[built[index]] = saved[index]
	for refs in [world.object_nodes, world.guardians, world.rescue_cells]:
		for key in refs.keys():
			var old = refs[key]
			if replacements.has(old):
				refs[key] = replacements[old]
			else:
				refs.erase(key)
	var seats: Array = []
	for entry in world.walk_seats:
		if replacements.has(entry.node):
			seats.append({"node": replacements[entry.node], "word": entry.word})
	world.walk_seats = seats
	for node in generated:
		world.remove_child(node)
		node.free()
	for child in layout.get_children():
		clear_owners(child)
		layout.remove_child(child)
		if child is Node3D:
			child.transform = layout.transform * child.transform
		world.add_child(child)
	layout.free()
	for region in world.rescue_cells:
		world.rescue_cells[region].visible = not region in world.defeated
	for region in world.guardians:
		if region in world.defeated:
			world.guardians[region].scale = Vector3.ONE * 0.75

static func clear_owners(node: Node) -> void:
	node.owner = null
	for child in node.get_children():
		clear_owners(child)
