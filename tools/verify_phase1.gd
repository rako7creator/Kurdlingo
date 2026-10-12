extends SceneTree

const Layout = preload("res://scripts/world_editor_layout.gd")
const Store = preload("res://scripts/progress_store.gd")
var failed = false

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		push_error("PHASE 1 TEST FAILURE: " + message)

func make_world() -> Node3D:
	var world = load("res://scripts/main.gd").new()
	world.vocabulary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vocabulary.json"))
	for row in world.vocabulary: world.by_id[row.id] = row
	return world

func saved_scene() -> Node3D:
	return load("res://scenes/editable_world.tscn").instantiate()

func run() -> void:
	var world = make_world()
	var layout = saved_scene()
	var expected: Dictionary = {}
	for node in layout.get_children():
		if node.get_meta("world_role", "") == "word": expected[node.get_meta("word_id")] = {"node": node, "transform": node.transform}
	# Deliberately invalidate every numeric index and reverse all root children.
	for node in layout.get_children():
		node.set_meta("layout_index", -1)
		layout.move_child(node, 0)
	check(Layout.bind_scene(world, layout), "Persistent binding survives traversal and index changes")
	check(world.object_nodes.size() == 1000 and world.guardians.size() == 20 and world.rescue_cells.size() == 20, "Complete gameplay reference sets")
	for id in expected:
		check(world.object_nodes[id] == expected[id].node and world.object_nodes[id].transform == expected[id].transform, "Identity and placement retained: " + str(id))
	check(world.walk_seats.size() == 63, "All existing walking seats retained")
	# Suppress normal _ready: this fixture only tests saved geometry and physics.
	world.set_script(null)
	root.add_child(world)
	var explorer = load("res://scripts/player.gd").new()
	explorer.position = Vector3(0, 1, 16)
	world.add_child(explorer)
	await physics_frame
	await physics_frame
	var counts = {"building": 0, "tree": 0, "pole": 0}
	var tested: Dictionary = {}
	for node in world.get_children():
		var kind = str(node.get_meta("world_collision", ""))
		if not counts.has(kind): continue
		counts[kind] += 1
		var body: StaticBody3D
		for child in node.get_children():
			if child is StaticBody3D and (child.collision_layer & 1) != 0: body = child
		check(body != null, "Movement collider exists: " + str(node.name))
		if body == null or tested.has(kind): continue
		var shape_node: CollisionShape3D = body.get_child(0)
		var half_width = shape_node.shape.size.x * 0.5 if kind == "building" else shape_node.shape.radius
		var centre: Vector3 = node.global_position + Vector3(0, 1, 0)
		var ray = PhysicsRayQueryParameters3D.create(centre + Vector3(half_width + 0.5, 0, 0), centre - Vector3(half_width + 0.5, 0, 0), 1, [explorer.get_rid()])
		var hit = world.get_world_3d().direct_space_state.intersect_ray(ray)
		check(not hit.is_empty() and hit.collider == body, "Physical movement layer blocks " + kind)
		var motion_result = KinematicCollision3D.new()
		var start = Transform3D(Basis.IDENTITY, node.global_position + Vector3(half_width + 0.6, 0.1, 0))
		check(explorer.test_move(start, Vector3(-1.2, 0, 0), motion_result), "Character capsule cannot pass through " + kind)
		tested[kind] = true
	check(counts == {"building": 19, "tree": 400, "pole": 62}, "Selective blocker counts")
	root.remove_child(world)
	world.free()
	# Older scenes use the frozen migration map, never a newly generated city.
	world = make_world()
	layout = saved_scene()
	for node in layout.get_children():
		for key in ["world_id", "world_role", "world_key", "world_collision"]:
			if node.has_meta(key): node.remove_meta(key)
		layout.move_child(node, 0)
	check(Layout.bind_scene(world, layout), "Legacy fallback survives reordered scene children")
	check(world.object_nodes.size() == 1000 and world.walk_seats.size() == 63, "Legacy reference completeness")
	world.free()
	# Corruption must fail closed instead of silently assigning the wrong object.
	world = make_world()
	layout = saved_scene()
	var first = layout.get_children()[1]
	var second = layout.get_children()[2]
	second.set_meta("world_id", first.get_meta("world_id"))
	print("EXPECTED DIAGNOSTIC: duplicate world_id")
	check(not Layout.bind_scene(world, layout), "Duplicate persistent IDs are rejected")
	layout.free()
	world.free()
	world = make_world()
	layout = saved_scene()
	layout.get_node("Word_apple").remove_meta("world_role")
	print("EXPECTED DIAGNOSTIC: missing apple")
	check(not Layout.bind_scene(world, layout), "Missing vocabulary binding is rejected")
	layout.free()
	world.free()
	var path = "user://phase1-verification/progress.json"
	check(Store.write(path, {"version": 3, "xp": 10}), "First save succeeds")
	check(Store.write(path, {"version": 3, "xp": 25}), "Replacing save succeeds")
	check(Store.read(path).xp == 25 and Store.read_dictionary(path + ".bak").xp == 10, "Previous valid save is backed up")
	var corrupt = FileAccess.open(path, FileAccess.WRITE)
	corrupt.store_string("{partial"); corrupt.close()
	check(Store.read(path).xp == 10, "Corrupt save recovers backup")
	check(Store.write(path, {"version": 3, "xp": 40}), "Saving after recovery succeeds")
	check(Store.read_dictionary(path + ".bak").xp == 10, "Corrupt primary never replaces valid backup")
	var blocked = "user://phase1-verification/blocked.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked))
	print("EXPECTED DIAGNOSTIC: replacement destination is a directory")
	check(not Store.write(blocked, {"version": 3, "xp": 50}), "Failed rename is reported")
	check(Store.read_dictionary(blocked + ".tmp").xp == 50, "Failed replacement retains staged progress")
	print("PHASE 1 VERIFICATION ", "FAIL" if failed else "PASS")
	quit(1 if failed else 0)
