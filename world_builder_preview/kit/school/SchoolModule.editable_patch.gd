extends Node3D
## KurdLingo Phase 2 modular school — first playable implementation.
## No changes to existing vocabulary IDs or EditableWorld are required.
## Integration point: scripts/main.gd (instructions and sample patch included).

const CONTENT_PATH = "res://school/school_content.json"
const SAVE_PATH = "user://kurdlingo_school_progress.json"
const INTERIOR_ORIGIN = Vector3(-70, 0, -215)
const EXTERIOR_GATE = Vector3(-57, 0, -68)
const BANDS = [Vector2(-23, -12), Vector2(-12, -1), Vector2(-1, 10), Vector2(10, 21)]
const LEVEL_HEIGHT = 4.2
const WALL = Color("eed5a7")
const WOOD = Color("b88b5e")
const GOLD = Color("e8b95b")
const PAVEMENT = Color("e9d9bc")
const BLUE = Color("78a8bc")

var world: Node3D
var content: Dictionary = {}
var building: Node3D
var word_nodes: Array[Dictionary] = []
var doors: Array[Dictionary] = []
var npcs: Array[Dictionary] = []
var known: Dictionary = {}
var school_seen: Dictionary = {}
var completed: Dictionary = {}
var inside = false
var roof_parts: Array[Node3D] = []
var active_panel: PanelContainer
var panel_content: VBoxContainer
var panel_layer: CanvasLayer
var hint: Label

func _ready() -> void:
	if world == null:
		# When this scene is directly instanced in main.tscn, the parent main.gd
		# has not finished its own _ready yet. Defer our setup one idle cycle.
		world = get_parent() as Node3D
		call_deferred("_initialize_school")
		return
	_initialize_school()

func _initialize_school() -> void:
	if world == null:
		push_error("KurdLingoSchool: could not find its game-world parent.")
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CONTENT_PATH))
	if not parsed is Dictionary:
		push_error("KurdLingoSchool: invalid school content JSON")
		return
	content = parsed
	for id in world.by_id:
		var row: Dictionary = world.by_id[id]
		var key = str(row.get("en", "")).strip_edges().to_lower()
		if not known.has(key):
			known[key] = str(id)
	_load_school_progress()
	if bool(get_meta("school_editor_baked", false)):
		building = get_node_or_null("KurdLingoSchoolCampus_126x104") as Node3D
		if building == null:
			push_error("Editable school is missing its Campus root. Do not regenerate over edits.")
			return
		_restore_baked_school(self)
	else:
		_build_school()
		_build_entry()
	_build_ui()

func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color, solid: bool = true) -> Node3D:
	var anchor = Node3D.new()
	anchor.position = at
	parent.add_child(anchor)
	var mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	if color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.roughness = 0.24
	mesh.material_override = material
	anchor.add_child(mesh)
	if solid:
		var body = StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		anchor.add_child(body)
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
	return anchor

func _label(parent: Node3D, words: String, at: Vector3, scale_factor: float = 1.0) -> void:
	var sign = Label3D.new()
	sign.text = words
	sign.font_size = 40
	sign.pixel_size = 0.0045 * scale_factor
	sign.modulate = Color("233f4b")
	sign.position = at
	if world != null and words.contains("بەخێربێن") and world.sorani_font != null:
		sign.font = world.sorani_font
	elif world != null and world.english_font != null:
		sign.font = world.english_font
	parent.add_child(sign)

# Saved editable scene references are recovered from metadata after opening in Godot.
# Unlike procedural generation, this preserves moved doors, school objects and roofs.
func _restore_baked_school(node: Node) -> void:
	if node is Node3D:
		if node.has_meta("school_baked_word"):
			var entry: Dictionary = node.get_meta("school_baked_word")
			var edited_word: String = str(entry.get("word", ""))
			for marker in node.get_children():
				if marker is Marker3D and marker.has_method("get_word_override"):
					var chosen: String = str(marker.get("english_override")).strip_edges()
					if chosen != "": edited_word = chosen
			word_nodes.append({"node": node, "word": edited_word, "room": str(entry.get("room", ""))})
		if node.has_meta("school_baked_door"):
			var data: Dictionary = node.get_meta("school_baked_door")
			doors.append({"node": node, "position": node.position, "open": false, "side": int(data.get("side", 1))})
		if node.has_meta("school_baked_npc"):
			var data: Dictionary = node.get_meta("school_baked_npc")
			npcs.append({"node": node, "id": str(data.get("id", "")), "title": str(data.get("title", "NPC"))})
		if bool(node.get_meta("school_baked_roof", false)):
			roof_parts.append(node)
	for child in node.get_children():
		_restore_baked_school(child)

func _build_entry() -> void:
	# Exterior gateway remains near the existing school object, which is not removed.
	var gate = Node3D.new()
	gate.name = "SchoolGateway"
	gate.position = EXTERIOR_GATE
	add_child(gate)
	_box(gate, Vector3(0, 1.25, 0), Vector3(4.8, 0.75, 0.22), BLUE, false)
	_box(gate, Vector3(-2.1, 0.7, 0), Vector3(0.15, 1.4, 0.15), WOOD, false)
	_box(gate, Vector3(2.1, 0.7, 0), Vector3(0.15, 1.4, 0.15), WOOD, false)
	_label(gate, "KURDLINGO SCHOOL  /  E ENTER", Vector3(0, 1.25, 0.17), 0.75)

func _block(at: Vector3, size: Vector3, color: Color, solid: bool = true, as_roof: bool = false) -> Node3D:
	var part = _box(building, at, size, color, solid)
	if as_roof: roof_parts.append(part)
	return part

func _windows_z(z: float, start_x: float, end_x: float, floor_n: int) -> void:
	# Real window openings, transparent panes and structural posts, not painted squares.
	var y: float = float(floor_n) * LEVEL_HEIGHT
	var width := end_x - start_x
	var number := maxi(1, int(width / 8.0))
	var step := width / float(number)
	_block(Vector3((start_x + end_x) * 0.5, y + 0.53, z), Vector3(width, 1.06, 0.42), WALL)
	_block(Vector3((start_x + end_x) * 0.5, y + 3.75, z), Vector3(width, 0.90, 0.42), WALL)
	for i in range(number):
		var cx := start_x + (float(i) + 0.5) * step
		_block(Vector3(cx, y + 2.12, z), Vector3(maxf(1.2, step - 0.95), 2.35, 0.09), Color(0.40, 0.67, 0.81, 0.55), false)
		_block(Vector3(start_x + float(i) * step, y + 2.12, z), Vector3(0.42, 2.36, 0.47), Color("f9efd9"))
	_block(Vector3(end_x, y + 2.12, z), Vector3(0.42, 2.36, 0.47), Color("f9efd9"))

func _windows_x(x: float, low_z: float, high_z: float, floor_n: int) -> void:
	var y: float = float(floor_n) * LEVEL_HEIGHT
	var width := high_z - low_z
	var number := maxi(1, int(width / 8.0))
	var step := width / float(number)
	_block(Vector3(x, y + 0.53, (low_z + high_z) * 0.5), Vector3(0.42, 1.06, width), WALL)
	_block(Vector3(x, y + 3.75, (low_z + high_z) * 0.5), Vector3(0.42, 0.90, width), WALL)
	for i in range(number):
		var cz := low_z + (float(i) + 0.5) * step
		_block(Vector3(x, y + 2.12, cz), Vector3(0.09, 2.35, maxf(1.2, step - 0.95)), Color(0.40, 0.67, 0.81, 0.55), false)
		_block(Vector3(x, y + 2.12, low_z + float(i) * step), Vector3(0.47, 2.36, 0.42), Color("f9efd9"))
	_block(Vector3(x, y + 2.12, high_z), Vector3(0.47, 2.36, 0.42), Color("f9efd9"))

func _tree(point: Vector3, size: float = 3.2) -> void:
	_block(point + Vector3(0, size * 0.32, 0), Vector3(0.33, size * 0.64, 0.33), WOOD)
	var crown = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = size * 0.40
	sphere.height = size * 0.80
	crown.mesh = sphere
	var material = StandardMaterial3D.new()
	material.albedo_color = Color("79be9b")
	crown.material_override = material
	crown.position = point + Vector3(0, size * 0.76, 0)
	building.add_child(crown)

func _build_school() -> void:
	building = Node3D.new()
	building.name = "KurdLingoSchoolCampus_126x104"
	building.position = INTERIOR_ORIGIN
	add_child(building)
	# Outside footprint: 162x148 with sports courts and a welcoming garden.
	_block(Vector3(0, -0.08, 7), Vector3(162, 0.16, 148), Color("80b77b"), false)
	_block(Vector3(0, 0.04, 61), Vector3(17, 0.08, 45), PAVEMENT, false)
	_block(Vector3(0, 0.03, 86), Vector3(168, 0.06, 11), Color("75878b"), false)
	for side in [-1, 1]:
		_block(Vector3(float(side) * 7, 1.25, 78), Vector3(1.1, 2.5, 1.1), WALL)
		_block(Vector3(float(side) * 45, 0.85, 78), Vector3(74, 1.7, 0.18), Color("f4e7d4"))
		_block(Vector3(float(side) * 80, 0.85, 3), Vector3(0.18, 1.7, 149), Color("f4e7d4"))
		for n in range(5): _tree(Vector3(float(side) * (14 + n * 12), 0.2, 62), 3.1)
	_label(building, "KURDLINGO SCHOOL  •  MAIN GATE", Vector3(0, 4.0, 78), 2.5)
	# Four-connected wings form a true full-scale square school around a courtyard.
	# Actual first-floor holes are kept over stair shafts.
	for info in [[0.0, 32.0, 126.0, 24.0], [0.0, -36.0, 126.0, 24.0], [-52.0, -2.0, 22.0, 68.0], [52.0, -2.0, 22.0, 68.0]]:
		var x: float = info[0]
		var z: float = info[1]
		var w: float = info[2]
		var d: float = info[3]
		_block(Vector3(x, 0.13, z), Vector3(w, 0.26, d), PAVEMENT)
		_block(Vector3(x, LEVEL_HEIGHT * 2 + 0.36, z), Vector3(w + 0.8, 0.55, d + 0.8), Color("b77768"), true, true)
	# Upstairs floors; front stair shafts x +-13 are left open.
	_block(Vector3(0, LEVEL_HEIGHT, -36), Vector3(126, 0.27, 24), PAVEMENT)
	for side in [-1, 1]: _block(Vector3(float(side) * 52, LEVEL_HEIGHT, -2), Vector3(22, 0.27, 68), PAVEMENT)
	for part in [[-39.5, 47.0], [0.0, 20.0], [39.5, 47.0]]:
		_block(Vector3(float(part[0]), LEVEL_HEIGHT, 32), Vector3(float(part[1]), 0.27, 24), PAVEMENT)
	_block(Vector3(0, LEVEL_HEIGHT, 19.0), Vector3(86, 0.27, 4.0), PAVEMENT)
	# Outer walls contain windows on both floors. Front lobby has a real entrance.
	for floor_n in [0, 1]:
		_windows_z(-48.0, -63, 63, floor_n)
		_windows_x(-63.0, -48.0, 44.0, floor_n)
		_windows_x(63.0, -48.0, 44.0, floor_n)
		if floor_n == 0:
			_windows_z(44.0, -63, -6, floor_n)
			_windows_z(44.0, 6, 63, floor_n)
		else:
			_windows_z(44.0, -63, 63, floor_n)
		# Room doors face the open courtyard, giving access to every room.
		for side in [-1, 1]:
			for band_i in range(BANDS.size()):
				var bounds: Vector2 = BANDS[band_i]
				var cz := (bounds.x + bounds.y) * 0.5
				var door_gap := 2.8
				_block(Vector3(float(side) * 41, float(floor_n) * LEVEL_HEIGHT + 2.0, (bounds.x + cz - door_gap * 0.5) * 0.5), Vector3(0.28, 4.0, cz - door_gap * 0.5 - bounds.x), WALL)
				_block(Vector3(float(side) * 41, float(floor_n) * LEVEL_HEIGHT + 2.0, (bounds.y + cz + door_gap * 0.5) * 0.5), Vector3(0.28, 4.0, bounds.y - cz - door_gap * 0.5), WALL)
				_add_door(float(side) * 41, cz, floor_n, side)
			# Three dividers with a 5m gap near the courtyard corridor.
			for split_z in [-12.0, -1.0, 10.0]:
				_block(Vector3(float(side) * 55, float(floor_n) * LEVEL_HEIGHT + 2, split_z), Vector3(16, 4, 0.25), WALL)
		# Courtyard arcade has columns and walkable openings to library/foyer.
		for col in range(-60, 61, 10):
			for z in [-24.0, 20.0]:
				_block(Vector3(float(col), float(floor_n) * LEVEL_HEIGHT + 2, z), Vector3(0.42, 4.0, 0.42), Color("f8ebcf"))
	# A spacious main courtyard with plants, benches and paths.
	_block(Vector3(0, 0.04, -2), Vector3(81, 0.08, 42), Color("acd19e"), false)
	_block(Vector3(0, 0.10, -2), Vector3(5, 0.05, 42), PAVEMENT, false)
	_block(Vector3(0, 0.10, 0), Vector3(80, 0.05, 5), PAVEMENT, false)
	for x in [-30.0, -17.0, 17.0, 30.0]:
		for z in [-14.0, 10.0]: _tree(Vector3(x, 0.15, z), 3.0)
	# Balcony guardrails around the open courtyard (2nd floor only).
	for z in [-21.0, 18.0]:
		for x in [-31.0, -20.0, -9.0, 9.0, 20.0, 31.0]:
			_block(Vector3(x, LEVEL_HEIGHT + 0.56, z), Vector3(8.0, 1.12, 0.13), WOOD)
	# Entrance canopy, entrance pillars, oversized front sign and school crest.
	_block(Vector3(0, 3.85, 47.0), Vector3(21, 0.55, 7), Color("b77768"))
	for x in [-9.0, 9.0]: _block(Vector3(x, 1.91, 48), Vector3(0.75, 3.82, 0.75), Color("f8ebcf"))
	_block(Vector3(0, 6.65, 44.35), Vector3(38, 2.6, 0.32), Color("fff0d8"), false)
	_label(building, "KURDLINGO SCHOOL", Vector3(0, 6.5, 44.59), 3.5)
	_label(building, "WELCOME  /  بەخێربێن", Vector3(0, 2.9, 47.0), 1.5)
	# Stairwell slopes rise in 24 walkable 17.5cm steps; slab cut-outs above.
	for side in [-1, 1]:
		var px := float(side) * 13.0
		for i in range(24):
			var rise := float(i + 1) * LEVEL_HEIGHT / 24.0
			var z := 39.8 - float(i) * 0.71
			_block(Vector3(px, rise * 0.5, z), Vector3(5.1, rise, 0.72), PAVEMENT)
		for offset in [-3.0, 3.0]:
			_block(Vector3(px + offset, 2.7, 31.5), Vector3(0.12, 0.12, 17), WOOD, false)
	# Lightweight, shadow-free interior lights make the rooms readable.
	for level in [0, 1]:
		for x in [-52.0, 0.0, 52.0]:
			var light = OmniLight3D.new()
			light.position = Vector3(x, float(level) * LEVEL_HEIGHT + 3.55, -15)
			light.light_energy = 0.42
			light.omni_range = 29
			light.shadow_enabled = false
			building.add_child(light)
	# School rooms, bilingual word cards and missions use the existing data.
	for room in content.get("rooms", []): _build_room(room)
	_add_npc("teacher", "Teacher Sara", Vector3(0, 0, 30.0), Color("5ca88c"))
	_add_npc("librarian", "School Librarian", Vector3(-48, LEVEL_HEIGHT, 15), Color("9e72ae"))
	_add_npc("cafeteria", "Cafeteria Worker", Vector3(-49, 0, 5), Color("d39467"))
	_add_npc("student", "Student", Vector3(8, 0, -34), Color("5b92d0"))
	_label(building, "GROUND FLOOR: RECEPTION · CLASSROOMS · CAFETERIA", Vector3(0, 2.7, 22.3), 1.3)
	_label(building, "E EXIT TO THE CITY", Vector3(0, 2.55, 43.0), 1.4)
	# Exterior sport courts and schoolyard seating.
	for side in [-1, 1]:
		var px := float(side) * 73.0
		_block(Vector3(px, 0.07, 1), Vector3(14, 0.14, 29), Color("c57f6a"), false)
		_block(Vector3(px, 2.2, -8), Vector3(0.16, 4.4, 0.16), WALL)
		_block(Vector3(px, 4.1, -8), Vector3(2.6, 1.0, 0.17), BLUE, false)
		_block(Vector3(px, 0.55, 31), Vector3(7.5, 0.25, 1), WOOD)

func _add_door(x: float, z: float, level: int, side: int) -> void:
	# Openable panel swings into its own classroom. Player collision follows.
	var hinge = Node3D.new()
	hinge.position = Vector3(x, float(level) * LEVEL_HEIGHT, z - 1.13)
	hinge.name = "ClassroomDoor_%s_%s_%s" % [level, side, z]
	building.add_child(hinge)
	_box(hinge, Vector3(0, 1.15, 1.13), Vector3(0.12, 2.3, 2.26), WOOD)
	doors.append({"node": hinge, "position": hinge.position, "open": false, "side": side})

func _build_room(room: Dictionary) -> void:
	var bounds: Vector2 = BANDS[int(room.get("band", 0))]
	var center_z = (bounds.x + bounds.y) * 0.5
	var left = str(room.get("side", "left")) == "left"
	var floor_n = 0 if str(room.get("floor", "ground")) == "ground" else 1
	var base_y = float(floor_n) * LEVEL_HEIGHT
	var side_x = -52.0 if left else 52.0
	var marker_x = -42.5 if left else 42.5
	_label(building, str(room.get("label", "Room")), Vector3(marker_x, base_y + 2.75, center_z), 1.0)
	var objects: Array = room.get("objects", [])
	var xs = [-59.0, -54.0, -49.0] if left else [49.0, 54.0, 59.0]
	for i in range(objects.size()):
		var row = int(i / 3)
		var col = i % 3
		var z = lerpf(bounds.x + 1.5, bounds.y - 1.5, float(row) / 2.0)
		var at = Vector3(float(xs[col]), base_y, z)
		_add_school_object(str(room.get("id", "")), str(objects[i]), at)

func _add_school_object(room_id: String, word: String, at: Vector3) -> void:
	var id = word.strip_edges().to_lower()
	var color = [Color("6e9fa7"), Color("b6a276"), Color("bb8065"), Color("8da781"), Color("9884ab")][int(word.length()) % 5]
	var stand = Node3D.new()
	stand.name = "SchoolObject_" + id.replace(" ", "_")
	stand.position = at
	building.add_child(stand)
	# Different low-poly shapes by vocabulary category instead of a sea of cubes.
	if id in ["chair", "office chair", "stool"]:
		_box(stand, Vector3(0, 0.44, 0), Vector3(0.9, 0.15, 0.80), color)
		_box(stand, Vector3(0, 0.94, -0.35), Vector3(0.9, 0.95, 0.13), color)
	elif id in ["desk", "reading table", "table", "reception desk", "teacher desk", "lab table"]:
		_box(stand, Vector3(0, 0.75, 0), Vector3(2.5, 0.18, 1.2), WOOD)
		for side in [-1, 1]: _box(stand, Vector3(float(side) * 1.06, 0.34, 0), Vector3(0.15, 0.68, 0.15), BLUE)
	elif id in ["computer", "monitor", "laptop"]:
		_box(stand, Vector3(0, 0.43, 0), Vector3(1.2, 0.83, 0.12), Color("354c57"))
		_box(stand, Vector3(0, 0.43, 0.09), Vector3(1.1, 0.7, 0.04), BLUE, false)
	elif id in ["book", "notebook", "dictionary", "textbook"]:
		_box(stand, Vector3(0, 0.15, 0), Vector3(0.74, 0.3, 0.95), color)
		_box(stand, Vector3(0, 0.31, 0), Vector3(0.72, 0.04, 0.93), PAVEMENT, false)
	elif id in ["whiteboard", "blackboard", "noticeboard"]:
		_box(stand, Vector3(0, 1.48, 0), Vector3(2.6, 1.8, 0.12), Color("38766e"))
	elif id in ["microscope", "test tube", "beaker", "thermometer"]:
		_box(stand, Vector3(0, 0.12, 0), Vector3(0.6, 0.2, 0.45), BLUE)
		_box(stand, Vector3(0, 0.65, 0), Vector3(0.16, 0.88, 0.19), color)
	elif id in ["guitar", "drum", "piano", "flute"]:
		_box(stand, Vector3(0, 0.62, 0), Vector3(0.84, 1.1, 0.25), WOOD)
	else:
		_box(stand, Vector3(0, 0.34, 0), Vector3(1.5, 0.68, 1.0), WOOD)
		_box(stand, Vector3(0, 0.84, 0), Vector3(0.8, 0.28, 0.55), color, false)
	_label(stand, word.capitalize(), Vector3(0, 1.95, 0.25), 0.85)
	word_nodes.append({"node": stand, "word": id, "room": room_id})

func _add_npc(id: String, title: String, at: Vector3, color: Color) -> void:
	var person = Node3D.new()
	person.position = at
	building.add_child(person)
	_box(person, Vector3(0, 0.90, 0), Vector3(0.60, 0.85, 0.37), color, false)
	var head = MeshInstance3D.new()
	var shape = SphereMesh.new()
	shape.radius = 0.30
	shape.height = 0.6
	head.mesh = shape
	var material = StandardMaterial3D.new()
	material.albedo_color = Color("e1ad89")
	head.material_override = material
	head.position = Vector3(0, 1.53, 0)
	person.add_child(head)
	_label(person, title, Vector3(0, 2.15, 0), 0.8)
	npcs.append({"node": person, "id": id, "title": title})

func _build_ui() -> void:
	panel_layer = CanvasLayer.new()
	panel_layer.layer = 12
	add_child(panel_layer)
	hint = Label.new()
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.offset_left = -260
	hint.offset_right = 260
	hint.offset_top = -90
	hint.offset_bottom = -55
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color("fff0cf"))
	if world.english_font != null: hint.add_theme_font_override("font", world.english_font)
	panel_layer.add_child(hint)
	active_panel = PanelContainer.new()
	active_panel.set_anchors_preset(Control.PRESET_CENTER)
	active_panel.offset_left = -290
	active_panel.offset_right = 290
	active_panel.offset_top = -190
	active_panel.offset_bottom = 190
	active_panel.visible = false
	panel_layer.add_child(active_panel)
	panel_content = VBoxContainer.new()
	panel_content.add_theme_constant_override("separation", 8)
	active_panel.add_child(panel_content)

func _heading(text_value: String, sorani: bool = false) -> Label:
	var l = Label.new()
	l.text = text_value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 23 if not sorani else 24)
	if sorani and world.sorani_font != null:
		l.add_theme_font_override("font", world.sorani_font)
		l.layout_direction = Control.LAYOUT_DIRECTION_RTL
	elif world != null and world.english_font != null:
		l.add_theme_font_override("font", world.english_font)
	return l

func _panel_button(title: String, action: Callable) -> void:
	var button = Button.new()
	button.text = title
	button.custom_minimum_size.y = 36
	if world.english_font != null: button.add_theme_font_override("font", world.english_font)
	button.pressed.connect(action)
	panel_content.add_child(button)

func _open_panel() -> void:
	for child in panel_content.get_children():
		panel_content.remove_child(child)
		child.queue_free()
	active_panel.visible = true

func dismiss_panel() -> bool:
	if active_panel != null and active_panel.visible:
		active_panel.visible = false
		return true
	return false

func _word_id(en: String) -> String:
	var aliases: Dictionary = content.get("aliases", {})
	var lookup: Variant = aliases.get(en, en)
	if lookup == null:
		return ""
	var key = str(lookup).to_lower()
	# Aliases can provide an existing ID (daily_whiteboard), not just English.
	if world.by_id.has(key):
		return key
	return str(known.get(key, ""))

func _show_word(word: String) -> void:
	var canonical = _word_id(word)
	school_seen[word] = true
	_check_missions()
	_save_school_progress()
	if canonical != "":
		# Reuse existing English/Sorani vocabulary card, audio and XP.
		world.inspect_word(canonical)
		return
	_open_panel()
	panel_content.add_child(_heading(word.capitalize()))
	panel_content.add_child(_heading("Sorani translation pending review", false))
	panel_content.add_child(_heading("Object discovered in KurdLingo School."))
	_panel_button("Close", func(): dismiss_panel())

func _conversation(id: String) -> void:
	_open_panel()
	if id == "teacher":
		panel_content.add_child(_heading("Teacher Sara: Welcome to KurdLingo School!"))
		panel_content.add_child(_heading("Which of these is a classroom object?"))
		_panel_button("A book", func(): _answer_teacher(true))
		_panel_button("A mountain", func(): _answer_teacher(false))
		_panel_button("An ocean", func(): _answer_teacher(false))
	elif id == "librarian":
		panel_content.add_child(_heading("Librarian: Welcome to the reading room!"))
		panel_content.add_child(_heading("Find the dictionary and the book."))
		_panel_button("Thank you!", func(): dismiss_panel())
	elif id == "cafeteria":
		panel_content.add_child(_heading("Cafeteria Worker: What would you like?"))
		_panel_button("A cup of water, please.", func(): _complete_talk(id))
		_panel_button("A sandwich, please.", func(): _complete_talk(id))
	else:
		panel_content.add_child(_heading("Student: Hello! Welcome to our school."))
		_panel_button("Hello!", func(): _complete_talk(id))
	_panel_button("Close", func(): dismiss_panel())

func _answer_teacher(correct: bool) -> void:
	if not correct:
		world.toast("Try again. Look for something you use in a classroom.")
		return
	_complete_talk("teacher")
	world.toast("Correct! A book is used at school.")

func _complete_talk(id: String) -> void:
	school_seen["talk:" + id] = true
	_check_missions()
	_save_school_progress()
	dismiss_panel()

func _show_missions() -> void:
	_open_panel()
	panel_content.add_child(_heading("KurdLingo School Missions"))
	for mission in content.get("missions", []):
		var done = completed.has(str(mission.id))
		var met = 0
		for goal in mission.goals:
			if school_seen.has(str(goal)): met += 1
		panel_content.add_child(_heading(("✓ " if done else "• ") + str(mission.name) + "   (%s/%s)" % [met, mission.goals.size()]))
	_panel_button("Close", func(): dismiss_panel())

func _check_missions() -> void:
	for mission in content.get("missions", []):
		var id = str(mission.id)
		if completed.has(id): continue
		var all_done = true
		for goal in mission.goals:
			if not school_seen.has(str(goal)):
				all_done = false
				break
		if all_done:
			completed[id] = true
			world.xp += int(mission.get("xp", 20))
			world.toast("School mission completed: " + str(mission.name))
			world.save_progress()
			world.update_hud()

func _save_school_progress() -> void:
	# Own versioned save; never overwrite the legacy 1000-word progress schema.
	var file = FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		push_warning("School progress was not saved")
		return
	file.store_string(JSON.stringify({"version": 1, "seen": school_seen, "completed": completed}))
	file.close()
	var err = DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH))
	if err != OK: push_warning("Could not finalize school progress save: " + str(err))

func _load_school_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if parsed is Dictionary and int(parsed.get("version", -1)) == 1:
		if parsed.get("seen") is Dictionary: school_seen = parsed.seen
		if parsed.get("completed") is Dictionary: completed = parsed.completed

# The school and gate can be moved in Godot: gameplay follows their saved transforms.
func _campus_point(local_point: Vector3) -> Vector3:
	if building != null: return building.to_global(local_point)
	return INTERIOR_ORIGIN + local_point

func _gate_point(local_point: Vector3 = Vector3.ZERO) -> Vector3:
	var gate: Node3D = get_node_or_null("SchoolGateway") as Node3D
	if gate != null: return gate.to_global(local_point)
	return EXTERIOR_GATE + local_point

func _nearby_action() -> Dictionary:
	if not inside:
		if world.player.global_position.distance_to(_gate_point()) < 4.6:
			return {"kind": "enter", "text": "E · Enter KurdLingo School"}
		return {}
	var player_pos: Vector3 = world.player.global_position
	var exit_pos = _campus_point(Vector3(0, 0, 42.0))
	if player_pos.distance_to(exit_pos) < 3.3:
		return {"kind": "exit", "text": "E · Leave school / return to city"}
	var nearest_dist = 2.7
	var choice: Dictionary = {}
	for door in doors:
		var d = player_pos.distance_to(door.node.global_position + Vector3(0, 1.1, 1.1))
		if d < nearest_dist:
			nearest_dist = d
			choice = {"kind": "door", "ref": door, "text": "E · Open / close classroom door"}
	for npc in npcs:
		var d = player_pos.distance_to(npc.node.global_position)
		if d < nearest_dist:
			nearest_dist = d
			choice = {"kind": "npc", "ref": npc, "text": "E · Talk to " + str(npc.title)}
	for obj in word_nodes:
		var d = player_pos.distance_to(obj.node.global_position + Vector3(0, 0.9, 0))
		if d < nearest_dist:
			nearest_dist = d
			choice = {"kind": "word", "ref": obj, "text": "E · Inspect " + str(obj.word)}
	return choice

func try_interact() -> bool:
	if not world.session_started or world.screen != null:
		return false
	if dismiss_panel():
		return true
	var action: Dictionary = _nearby_action()
	if action.is_empty():
		return false
	match str(action.kind):
		"enter":
			inside = true
			world.player.teleport(_campus_point(Vector3(0, 0, 62.0)))
			world.toast("Welcome to KurdLingo School. Explore rooms and press E to learn!")
		"exit":
			inside = false
			world.player.teleport(_gate_point(Vector3(0, 0, 2.8)))
			world.toast("Back in KurdLingo City")
		"word":
			_show_word(str(action.ref.word))
		"npc":
			_conversation(str(action.ref.id))
		"door":
			var door: Dictionary = action.ref
			door.open = not bool(door.open)
			door.node.rotation.y = (PI * 0.5 if int(door.side) == 1 else -PI * 0.5) if door.open else 0.0
	return true

func _process(_delta: float) -> void:
	if hint == null or world == null or world.player == null: return
	hint.visible = world.session_started and world.screen == null and not active_panel.visible
	if not hint.visible: return
	var action: Dictionary = _nearby_action()
	hint.text = str(action.get("text", ""))
	for roof in roof_parts:
		if is_instance_valid(roof): roof.visible = not inside
	if inside:
		var local_player: Vector3 = building.to_local(world.player.global_position)
		for room in content.get("rooms", []):
			var y = 0.0 if str(room.floor) == "ground" else LEVEL_HEIGHT
			var b: Vector2 = BANDS[int(room.band)]
			var x_ok = (-63.0 < local_player.x and local_player.x < -41.0) if str(room.side) == "left" else (41.0 < local_player.x and local_player.x < 63.0)
			if x_ok and absf(local_player.y - y) < 2.0 and local_player.z >= b.x and local_player.z <= b.y:
				var id = str(room.id)
				if not school_seen.has("visit:" + id):
					school_seen["visit:" + id] = true
					_check_missions()
					_save_school_progress()
				break

func open_missions() -> void:
	if inside and world.session_started and world.screen == null:
		_show_missions()

func debug_warp_to_gate() -> void:
	if OS.is_debug_build() and world.player != null:
		inside = false
		world.player.teleport(_gate_point(Vector3(0, 0, 2.8)))
