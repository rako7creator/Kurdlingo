extends SceneTree

func _initialize() -> void:
	call_deferred("generate")

func generate() -> void:
	var world = load("res://scripts/main.gd").new()
	world.name = "EditableWorld"
	world.english_font = load("res://assets/NotoSans.ttf")
	world.sorani_font = load("res://assets/NotoSansArabic.ttf")
	world.vocabulary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vocabulary.json"))
	world.build_environment()
	world.build_world()
	var nodes = WorldEditorLayout.spatial_nodes(world)
	for index in range(nodes.size()):
		var node = nodes[index]
		node.set_meta("layout_index", index)
		node.set_meta("original_transform", node.transform)
		if node.has_meta("word_id") and node.get_parent() == world:
			node.name = "Word_" + str(node.get_meta("word_id"))
	own_children(world, world)
	world.set_script(null)
	var scene = PackedScene.new()
	var error = scene.pack(world)
	if error == OK:
		error = ResourceSaver.save(scene, "res://scenes/editable_world.tscn")
	world.free()
	if error != OK:
		push_error("World scene generation failed: " + str(error))
		quit(1)
		return
	print("EDITOR WORLD GENERATED: ", nodes.size(), " spatial nodes")
	quit()

func own_children(node: Node, owner_node: Node) -> void:
	for child in node.get_children():
		child.owner = owner_node
		own_children(child, owner_node)
