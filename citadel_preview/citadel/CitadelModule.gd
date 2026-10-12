extends Node3D
const ProgressStore = preload("res://scripts/progress_store.gd")
## KurdLingo Phase 3 — Erbil Citadel-inspired, real-world Kurdish heritage campus.
## This module is added under main.gd after EditableWorld has been rebound.
## No changes to existing 1,000 vocabulary IDs, models, audio or saved world scene.

const SAVE_PATH := "user://kurdlingo_citadel_progress.json"
const SITE := Vector3(-235.0, 0.0, -167.0) # Move if it overlaps a saved-world landmark.
const HEIGHT := 5.0
const RADIUS := 62.0
const EARTH := Color("#b87559")
const EARTH_LIGHT := Color("#ddaa80")
const LIMESTONE := Color("#ecd0a6")
const PLASTER := Color("#f4dcad")
const WOOD := Color("#855b40")
const DARK := Color("#28444e")
const TILE := Color("#bb7664")
const SKY_BLUE := Color("#77bad0")
const TEA_GREEN := Color("#7a9981")
const RUG_RED := Color("#a44e54")
const GOLD := Color("#e4ba65")
const PROMPTS := [
    {"id":"gate", "title":"Enter the grand gate", "note":"Find the historic entrance arch", "xp":15},
    {"id":"carpet", "title":"Discover a Kurdish carpet", "note":"Visit the traditional bazaar", "xp":20},
    {"id":"tea", "title":"Learn the word tea", "note":"Find the tea house", "xp":20},
    {"id":"museum", "title":"Explore the heritage museum", "note":"Find an exhibit inside the museum", "xp":25},
    {"id":"house", "title":"Enter a traditional house", "note":"Look for an open courtyard doorway", "xp":20},
    {"id":"stairs", "title":"Explore an upstairs room", "note":"Walk up the internal house staircase", "xp":25},
    {"id":"guide", "title":"Speak to a local guide", "note":"Listen to a short cultural introduction", "xp":25}
]

var world
var interactables: Array[Dictionary] = []
var roofs: Array[Dictionary] = []
var completion: Dictionary = {}
var entrance_from := Vector3.ZERO
var has_entrance_from := false
var using_shortcut := false
var hint: Label
var panel_layer: CanvasLayer
var mission_panel: PanelContainer
var guide_lines: Array[String] = [
    "Welcome to the Erbil Citadel! / بەخێربێن بۆ قەڵای هەولێر",
    "The historic Citadel sits above the modern city.",
    "Look for Kurdish carpets, houses, tea, crafts and our heritage museum.",
    "Use E to inspect items. Your existing English and Sorani recordings will play.",
    "Climb the stairs inside the traditional house to explore the second floor."
]
var guide_page := 0

func _ready() -> void:
    if world == null:
        push_error("CitadelModule requires a world reference before add_child().")
        return
    position = SITE
    _load_progress()
    _terrain()
    _outer_walls()
    _gate()
    _alleyways()
    _traditional_houses()
    _bazaar()
    _tea_house()
    _museum()
    _historic_square()
    _guide()
    _ui()
    print("KurdLingo Erbil Citadel loaded; original world scene preserved.")

func _ready_for_input() -> bool:
    return world != null and world.player != null and is_instance_valid(world.player) and world.session_started

func _process(_delta: float) -> void:
    if hint == null or not _ready_for_input():
        return
    var p: Vector3 = to_local(world.player.global_position)
    var within := Vector2(p.x, p.z).length() < 145.0
    hint.get_parent().visible = within and world.screen == null
    if within:
        var obj := _nearest(4.1)
        hint.text = "E  ·  %s   |   H  ·  Heritage missions   |   F10  ·  Return" % str(obj.get("label", "Inspect historic objects"))
    # Third-person visibility: hide only the roof of the house the player occupies.
    for info in roofs:
        var h: Node3D = info["node"]
        var roof: MeshInstance3D = info["roof"]
        if not is_instance_valid(roof):
            continue
        var local_p: Vector3 = h.to_local(world.player.global_position)
        roof.visible = not (absf(local_p.x) < 7.1 and absf(local_p.z) < 6.3 and local_p.y > 0.0 and local_p.y < 8.0)

func _make_material(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.9
    if color.a < 0.98:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.roughness = 0.23
    return m

func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color, solid: bool = true, angle: float = 0.0) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    mesh.name = "CitadelBox"
    mesh.position = at
    mesh.rotation.y = angle
    var cube := BoxMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.material_override = _make_material(color)
    parent.add_child(mesh)
    if solid:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        var col := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        col.shape = shape
        body.add_child(col)
        mesh.add_child(body)
    return mesh

func _cylinder(parent: Node3D, at: Vector3, radius: float, depth: float, color: Color, solid: bool = true) -> Node3D:
    var mesh := MeshInstance3D.new()
    mesh.name = "CitadelRound"
    mesh.position = at
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = radius
    cylinder.bottom_radius = radius
    cylinder.height = depth
    cylinder.radial_segments = 32
    mesh.mesh = cylinder
    mesh.material_override = _make_material(color)
    parent.add_child(mesh)
    if solid:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        var shape := CylinderShape3D.new()
        shape.radius = radius
        shape.height = depth
        var col := CollisionShape3D.new()
        col.shape = shape
        body.add_child(col)
        mesh.add_child(body)
    return mesh

func _sign(parent: Node3D, words: String, at: Vector3, scale: float = 0.005, sorani: bool = false) -> void:
    var label := Label3D.new()
    label.text = words
    label.position = at
    label.font_size = 56
    label.pixel_size = scale
    label.modulate = DARK
    label.no_depth_test = false
    if sorani and world.sorani_font != null:
        label.font = world.sorani_font
    elif world.english_font != null:
        label.font = world.english_font
    parent.add_child(label)

func _target(node: Node3D, label: String, word: String, local_point: Vector3, mission: String = "", dialogue: String = "") -> void:
    interactables.append({"parent":node, "point": local_point, "label":label, "word":word, "mission":mission, "dialogue":dialogue})

func _terrain() -> void:
    # Sandstone mound and raised, accessible plateau. Upper circular collider is the floor.
    _cylinder(self, Vector3(0, 1.9, 0), 63.0, 3.8, EARTH, true)
    _cylinder(self, Vector3(0, 4.4, 0), 61.0, 1.2, EARTH_LIGHT, true) # top at 5.0
    _cylinder(self, Vector3(0, 5.03, 0), 59.4, 0.05, Color("#d9b588"), false)
    for r in [64.5, 66.7, 68.9]:
        # Outer earth bands suggest the stepped tell without obstructing player.
        _cylinder(self, Vector3(0, (69.0-r)*0.55, 0), r, 0.12, EARTH_LIGHT, false)
    # Usable approach stairway starts outside the mound and finishes level with plateau.
    for i in range(40):
        var y := float(i + 1) * (HEIGHT / 40.0)
        var z := 126.0 - float(i) * 1.65
        _box(self, Vector3(0, y * 0.5, z), Vector3(13.0, y, 0.88), LIMESTONE)
    _box(self, Vector3(0, 5.08, 59), Vector3(13, 0.16, 8), LIMESTONE)
    # Sidewalk link toward the Workshop district, on the way back to central Market/Town.
    _box(self, Vector3(26, 0.02, 124), Vector3(54, 0.05, 6), LIMESTONE, false)
    _box(self, Vector3(54, 0.02, 108), Vector3(6, 0.05, 36), LIMESTONE, false)
    for x in [-7.0, 7.0]:
        for i in range(8):
            var y := float(i + 1) * 0.62
            var z := 124.0 - float(i) * 8.0
            _box(self, Vector3(x, y + 0.7, z), Vector3(0.3, 1.4, 0.3), DARK, false)
    _sign(self, "ERBIL CITADEL", Vector3(0, 2.5, 97.0), 0.005)
    _sign(self, "قەڵای هەولێر", Vector3(0, 1.8, 97.0), 0.005, true)
    _target(self, "Citadel gateway", "gate", Vector3(0, 5, 57), "gate")

func _outer_walls() -> void:
    # Perimeter segments and crenellations, with a large intentional south entrance gap.
    var parts := 42
    for n in range(parts):
        var a := TAU * (float(n) + 0.5) / float(parts)
        if a < 0.23 or a > TAU - 0.23:
            continue
        var x := sin(a) * 59.4
        var z := cos(a) * 59.4
        _box(self, Vector3(x, 7.5, z), Vector3(9.3, 5.0, 2.8), EARTH, true, a)
        _box(self, Vector3(x, 10.1, z), Vector3(8.8, 0.45, 3.3), LIMESTONE, true, a)
        for b in [-1.0, 1.0]:
            _box(self, Vector3(x + b * cos(a) * 2.35, 10.62, z - b * sin(a) * 2.35), Vector3(2.2, 0.98, 2.2), EARTH_LIGHT, false, a)

func _gate() -> void:
    # Grand historic gate: broad central portal, framed arches and wooden doors that stay open.
    for x in [-10.2, 10.2]:
        _box(self, Vector3(x, 8.7, 57.0), Vector3(3.5, 7.4, 5.0), EARTH)
        _box(self, Vector3(x, 12.3, 57.2), Vector3(4.3, 0.65, 5.7), LIMESTONE)
    _box(self, Vector3(0, 12.25, 57.0), Vector3(18.4, 2.0, 5.3), EARTH)
    _box(self, Vector3(0, 13.37, 57.0), Vector3(22.2, 0.55, 6.0), LIMESTONE)
    for x in [-7.0, 7.0]:
        _box(self, Vector3(x, 8.2, 54.6), Vector3(0.72, 4.0, 0.28), WOOD, false, x * 0.045)
        _box(self, Vector3(x * 0.82, 10.3, 54.7), Vector3(0.8, 1.5, 0.35), LIMESTONE, false, x * 0.048)
    _sign(self, "ERBIL CITADEL", Vector3(0, 12.05, 60.0), 0.008)
    _sign(self, "قەڵای هەولێر", Vector3(0, 10.72, 60.0), 0.007, true)
    _target(self, "Grand gate", "gate", Vector3(0, 5.25, 52.5), "gate")

func _alleyways() -> void:
    # A connected central plaza with spoke paths to the ring of houses.
    _cylinder(self, Vector3(0, 5.12, 0), 15.2, 0.14, Color("#e6cdb3"), false)
    for a in range(8):
        var radians := float(a) * TAU / 8.0
        _box(self, Vector3(sin(radians)*23.0, 5.14, cos(radians)*23.0), Vector3(6.0, 0.09, 40.0), Color("#e6cfb0"), false, radians)
    # A visible connection from gate to main plaza.
    _box(self, Vector3(0, 5.13, 31.3), Vector3(13.5, 0.07, 53), LIMESTONE, false)
    for x in [-14.0, 14.0]:
        for z in [15.0, 35.0]:
            _lantern(self, Vector3(x, 5.0, z))

func _lantern(parent: Node3D, at: Vector3) -> void:
    _box(parent, at + Vector3(0, 1.35, 0), Vector3(0.16, 2.7, 0.16), WOOD)
    _box(parent, at + Vector3(0, 2.84, 0), Vector3(0.76, 0.9, 0.76), GOLD, false)
    _box(parent, at + Vector3(0, 3.35, 0), Vector3(1.1, 0.23, 1.1), WOOD)
    _target(parent, "Lantern", "lantern", at, "")

func _traditional_houses() -> void:
    # Twelve detached two-storey Kurdish courtyard-edge houses, not a European castle.
    # Each has a walkable ground floor and genuine open doorway; four have stair access.
    for i in range(12):
        var a := TAU * (float(i) + 0.5) / 12.0
        var house := Node3D.new()
        house.name = "KurdishTraditionalHouse_%02d" % i
        house.position = Vector3(sin(a)*40.0, 5.0, cos(a)*40.0)
        house.rotation.y = a
        add_child(house)
        _house(house, i)

func _house(node: Node3D, index: int) -> void:
    var wall_color: Color = [PLASTER, LIMESTONE, EARTH_LIGHT, Color("#e9c7a5")][index % 4]
    # Slight elevation enables inspection of a real two-floor house interior.
    _box(node, Vector3(0, 0.16, 0), Vector3(13.0, 0.3, 12.0), LIMESTONE)
    _box(node, Vector3(0, 3.9, 5.86), Vector3(13, 7.8, 0.34), wall_color)
    for x in [-6.32, 6.32]:
        _box(node, Vector3(x, 3.9, 0), Vector3(0.36, 7.8, 12), wall_color)
    for y in [1.75, 5.42]:
        for x in [-4.55, 4.55]:
            # Front facade windows: deep wooden reveals, transparent painted glass.
            _box(node, Vector3(x, y, -6.02), Vector3(2.3, 1.75, 0.25), SKY_BLUE, false)
            _box(node, Vector3(x, y, -6.21), Vector3(2.55, 0.17, 0.3), WOOD, false)
            _box(node, Vector3(x, y, -6.21), Vector3(0.18, 1.84, 0.31), WOOD, false)
    _box(node, Vector3(-4.62, 3.9, -5.94), Vector3(3.72, 7.8, 0.36), wall_color)
    _box(node, Vector3(4.62, 3.9, -5.94), Vector3(3.72, 7.8, 0.36), wall_color)
    _box(node, Vector3(0, 6.23, -5.94), Vector3(5.65, 3.34, 0.36), wall_color)
    _box(node, Vector3(0, 3.45, -5.94), Vector3(5.65, 0.85, 0.36), wall_color)
    _box(node, Vector3(0, 3.0, -6.06), Vector3(5.65, 0.3, 0.4), WOOD, false)
    _box(node, Vector3(0, 0.24, -6.17), Vector3(6.2, 0.19, 1.1), LIMESTONE, false)
    # The two-floor roof is hidden for the current player-occupied house.
    var roof := _box(node, Vector3(0, 8.0, 0), Vector3(13.8, 0.45, 13), TILE)
    roofs.append({"node":node, "roof":roof})
    for x in [-6.4, 6.4]:
        var side_parapet := _box(node, Vector3(x, 8.65, 0), Vector3(0.4, 1.0, 12.8), EARTH_LIGHT)
        roofs.append({"node":node, "roof":side_parapet})
    var back_parapet := _box(node, Vector3(0, 8.65, 5.9), Vector3(13.0, 1.0, 0.43), EARTH_LIGHT)
    roofs.append({"node":node, "roof":back_parapet})
    var label_pos := Vector3(0, 3.9, -6.25)
    if index in [0, 3, 6, 9]:
        _sign(node, "TRADITIONAL HOUSE", label_pos, 0.0035)
    # Furnished lower storey, visible through the open doorway.
    _box(node, Vector3(-2.8, 0.6, 2.0), Vector3(3.0, 0.55, 1.5), WOOD)
    _box(node, Vector3(-2.7, 0.18, -0.5), Vector3(5.2, 0.07, 3.5), RUG_RED, false)
    _box(node, Vector3(-2.7, 0.23, -0.5), Vector3(4.6, 0.09, 0.18), GOLD, false)
    _box(node, Vector3(2.0, 1.0, 3.4), Vector3(2.5, 2.0, 0.7), WOOD)
    _target(node, "Traditional Kurdish house", "house", Vector3(0, 0.5, -5.0), "house")
    _target(node, "Carpet", "carpet", Vector3(-2.7, 0.5, -0.4), "carpet")
    _target(node, "Wooden table", "table", Vector3(-2.8, 0.45, 2.0))
    if index in [0, 3, 6, 9]:
        # Three pieces of second-floor walkway leave a staircase void at x=3.5.
        _box(node, Vector3(-2.2, 3.62, 0), Vector3(8.0, 0.25, 11.5), PLASTER)
        _box(node, Vector3(5.65, 3.62, 0), Vector3(1.65, 0.25, 11.5), PLASTER)
        for n in range(20):
            var rise := float(n + 1) * (3.52 / 20.0)
            var depth := -5.4 + float(n) * 0.55
            _box(node, Vector3(3.5, rise*0.5, depth), Vector3(2.6, rise, 0.65), LIMESTONE)
        # Short top bridge links staircase to usable upstairs room.
        _box(node, Vector3(1.65, 3.65, 5.05), Vector3(5.2, 0.25, 2.2), PLASTER)
        _box(node, Vector3(-2.1, 3.67, 0.8), Vector3(3.5, 0.08, 2.2), RUG_RED, false)
        _target(node, "Upper-floor room", "stairs", Vector3(-0.9, 3.8, 4.1), "stairs")
        _target(node, "Staircase", "stairs", Vector3(3.6, 0.6, -4.4), "")

func _bazaar() -> void:
    var bazaar := Node3D.new()
    bazaar.name = "HistoricBazaar"
    bazaar.position = Vector3(25, 5.0, 8)
    add_child(bazaar)
    _sign(bazaar, "KURDISH BAZAAR", Vector3(0, 4.7, 10.0), 0.005)
    for row in range(2):
        for i in range(4):
            var x := -8.0 + float(i)*5.2
            var z := 6.0 if row == 0 else -8.0
            _box(bazaar, Vector3(x, 0.93, z), Vector3(4.5, 1.85, 2.4), WOOD)
            _box(bazaar, Vector3(x, 2.75, z), Vector3(4.9, 0.18, 3.7), [RUG_RED, GOLD, SKY_BLUE, TEA_GREEN][i], false)
            for post in [-1.95, 1.95]:
                _box(bazaar, Vector3(x+post, 1.8, z-1.2), Vector3(0.12, 3.4, 0.12), WOOD)
            var typ: String = ["carpet", "basket", "pot", "bread"][i]
            var tone: Color = [RUG_RED, GOLD, EARTH_LIGHT, PLASTER][i]
            if i == 0:
                _box(bazaar, Vector3(x, 1.95, z), Vector3(3.2, 0.09, 1.5), tone, false)
            else:
                _box(bazaar, Vector3(x, 1.98, z), Vector3(0.85, 0.55, 0.85), tone, false)
            _target(bazaar, typ.capitalize(), typ, Vector3(x, 0.9, z-1.0), "carpet" if typ == "carpet" else "")
    _target(bazaar, "Bazaar shop", "shop", Vector3(2.0, 0.4, 10.0))

func _tea_house() -> void:
    var tea := Node3D.new()
    tea.name = "CitadelTeaHouse"
    tea.position = Vector3(-27, 5, 14)
    add_child(tea)
    _box(tea, Vector3(0, 3.2, 0), Vector3(18, 0.3, 14), WOOD)
    for x in [-8.5, 8.5]:
        for z in [-6.2, 6.2]:
            _box(tea, Vector3(x, 1.62, z), Vector3(0.35, 3.24, 0.35), WOOD)
    _sign(tea, "CITADEL TEA HOUSE", Vector3(0, 3.95, 7.1), 0.0045)
    for i in range(3):
        var x := -5.2 + float(i) * 5.2
        _box(tea, Vector3(x, 0.75, 1.0), Vector3(2.3, 0.16, 2.0), WOOD)
        for cx in [-1.7, 1.7]:
            _box(tea, Vector3(x+cx, 0.33, 1.0), Vector3(0.8, 0.4, 1.2), RUG_RED)
        _box(tea, Vector3(x, 1.0, 1), Vector3(0.36, 0.38, 0.36), GOLD, false)
        _target(tea, "Kurdish tea", "tea", Vector3(x, 0.75, 1.1), "tea")
    _box(tea, Vector3(6, 1.25, -4.3), Vector3(1.6, 2.2, 1.4), EARTH_LIGHT)
    _target(tea, "Teapot", "daily_teapot", Vector3(6, 1.15, -4.3))
    _target(tea, "Cup", "cup", Vector3(0, 0.75, 1.3))

func _museum() -> void:
    var museum := Node3D.new()
    museum.name = "KurdishHeritageMuseum"
    museum.position = Vector3(-2, 5, -28)
    add_child(museum)
    _box(museum, Vector3(0, 0.15, 0), Vector3(25, 0.3, 19), LIMESTONE)
    _box(museum, Vector3(0, 2.25, -9.2), Vector3(25, 4.5, 0.45), PLASTER)
    for x in [-12.2, 12.2]:
        _box(museum, Vector3(x, 2.25, 0), Vector3(0.45, 4.5, 19), PLASTER)
    for x in [-9.1, 9.1]:
        _box(museum, Vector3(x, 2.25, 9.2), Vector3(6.7, 4.5, 0.45), PLASTER)
    _box(museum, Vector3(0, 4.2, 9.2), Vector3(11.5, 0.5, 0.45), WOOD)
    _box(museum, Vector3(0, 4.85, 0), Vector3(25.2, 0.35, 19.5), TILE)
    _sign(museum, "CITADEL HERITAGE MUSEUM", Vector3(0, 5.35, 9.6), 0.0047)
    _box(museum, Vector3(-6, 0.9, -3), Vector3(4.6, 1.8, 2.6), WOOD)
    _box(museum, Vector3(-6, 1.93, -3), Vector3(1.1, 0.55, 1.1), EARTH_LIGHT, false)
    _box(museum, Vector3(6, 0.9, -3), Vector3(4.6, 1.8, 2.6), WOOD)
    _box(museum, Vector3(6, 1.95, -3), Vector3(3.5, 0.08, 2), RUG_RED, false)
    _target(museum, "Heritage museum", "daily_museum_ticket", Vector3(0, 0.4, 7.5), "museum", "This exhibition introduces Kurdish history and crafts.")
    _target(museum, "Traditional pottery", "pot", Vector3(-6, 1, -3), "museum")
    _target(museum, "Kurdish carpet display", "carpet", Vector3(6, 1, -3), "museum")

func _historic_square() -> void:
    _cylinder(self, Vector3(0, 5.65, 0), 4.8, 1.1, LIMESTONE)
    _cylinder(self, Vector3(0, 6.28, 0), 3.5, 0.2, SKY_BLUE, false)
    _target(self, "Fountain", "fountain", Vector3(0, 5.8, 4.0))
    _box(self, Vector3(0, 8.2, 0), Vector3(0.26, 4.6, 0.26), WOOD)
    for n in range(3):
        var stripe_color: Color = [RUG_RED, PLASTER, TEA_GREEN][n]
        _box(self, Vector3(0, 9.9 - float(n)*0.65, 0.2), Vector3(3.1, 0.62, 0.1), stripe_color, false)
    _target(self, "Kurdish flag", "flag", Vector3(0, 5.1, 2.8))
    _sign(self, "WELCOME TO THE CITADEL", Vector3(0, 7.3, 13.0), 0.004)

func _guide() -> void:
    var guide := Node3D.new()
    guide.name = "CitadelHeritageGuide"
    guide.position = Vector3(-7.4, 5, 26)
    add_child(guide)
    _box(guide, Vector3(0, 0.9, 0), Vector3(0.8, 1.55, 0.52), SKY_BLUE)
    var head := MeshInstance3D.new()
    head.name = "GuideHead"
    var shape := SphereMesh.new()
    shape.radius = 0.4
    shape.height = 0.8
    head.mesh = shape
    head.position = Vector3(0, 2.0, 0)
    head.material_override = _make_material(Color("#deb995"))
    guide.add_child(head)
    _sign(guide, "CITADEL GUIDE", Vector3(0, 2.72, 0.3), 0.0035)
    _target(guide, "Talk to the Kurdish guide", "", Vector3.ZERO, "guide", "guide")

func _ui() -> void:
    panel_layer = CanvasLayer.new()
    panel_layer.layer = 8
    add_child(panel_layer)
    var hint_box := PanelContainer.new()
    hint_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    hint_box.offset_left = -345
    hint_box.offset_right = 345
    hint_box.offset_top = -140
    hint_box.offset_bottom = -87
    hint_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel_layer.add_child(hint_box)
    hint = Label.new()
    hint.text = "E · Inspect Kurdish culture   |   H · Missions"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hint_box.add_child(hint)
    hint_box.visible = false
    mission_panel = PanelContainer.new()
    mission_panel.set_anchors_preset(Control.PRESET_CENTER)
    mission_panel.offset_left = -365
    mission_panel.offset_right = 365
    mission_panel.offset_top = -280
    mission_panel.offset_bottom = 280
    mission_panel.visible = false
    panel_layer.add_child(mission_panel)

func _nearest(max_distance: float) -> Dictionary:
    var result: Dictionary = {}
    var nearest := max_distance
    for entry in interactables:
        var host: Node3D = entry["parent"]
        var pos: Vector3 = host.to_global(entry["point"])
        var distance: float = world.player.global_position.distance_to(pos)
        if distance < nearest:
            nearest = distance
            result = entry
    return result

func _here() -> bool:
    if not _ready_for_input():
        return false
    var p: Vector3 = to_local(world.player.global_position)
    return Vector2(p.x, p.z).length() < 105.0

func try_interact() -> bool:
    # Intercepts E only close to an Erbil Citadel object; existing school/city E keeps working.
    if not _here() or mission_panel.visible:
        return false
    var item := _nearest(4.1)
    if item.is_empty():
        return false
    var dialogue := str(item.get("dialogue", ""))
    if dialogue == "guide":
        guide_page = 0
        _show_guide()
    else:
        var word := str(item.get("word", ""))
        if word != "" and world.by_id.has(word):
            world.inspect_word(word)
        else:
            world.toast(str(item.get("label", "")) + " · translation/audio review pending")
    _finish(str(item.get("mission", "")))
    return true

func _finish(id: String) -> void:
    if id == "" or completion.has(id):
        return
    for mission in PROMPTS:
        if mission.id == id:
            completion[id] = true
            world.xp += int(mission.xp)
            world.update_hud()
            _save_progress()
            world.save_progress()
            world.toast("Heritage mission completed: " + str(mission.title) + "  +" + str(mission.xp) + " XP")
            return

func _load_progress() -> void:
    if world.test_mode:
        return
    var data: Dictionary = ProgressStore.read(SAVE_PATH)
    if data.get("completed") is Dictionary:
        completion = data.completed.duplicate()

func _save_progress() -> void:
    if world.test_mode:
        return
    ProgressStore.write(SAVE_PATH, {"version":1, "completed":completion})

func _show_guide() -> void:
    var text := "CITADEL HERITAGE GUIDE\n\n" + guide_lines[clampi(guide_page, 0, guide_lines.size()-1)]
    _show_panel(text, true)

func _show_panel(words: String, next_page: bool = false) -> void:
    for child in mission_panel.get_children():
        child.queue_free()
    var content := VBoxContainer.new()
    mission_panel.add_child(content)
    var header := Label.new()
    header.text = words
    header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    header.custom_minimum_size = Vector2(690, 410)
    header.add_theme_font_size_override("font_size", 19)
    if world.english_font != null:
        header.add_theme_font_override("font", world.english_font)
    content.add_child(header)
    if next_page and guide_page < guide_lines.size() - 1:
        var next_button := Button.new()
        next_button.text = "Next / Continue"
        next_button.pressed.connect(func(): guide_page += 1; _show_guide())
        content.add_child(next_button)
    var close_button := Button.new()
    close_button.text = "Close (Esc)"
    close_button.pressed.connect(dismiss_panel)
    content.add_child(close_button)
    mission_panel.visible = true

func open_missions() -> void:
    if not _here() or world.screen != null:
        return
    var msg := "ERBIL CITADEL — CULTURAL LEARNING\n\n"
    for i in range(PROMPTS.size()):
        var objective: Dictionary = PROMPTS[i]
        var checked := "✓ " if completion.has(objective.id) else "□ "
        msg += checked + str(objective.title) + " (" + str(objective.xp) + " XP)\n"
    msg += "\nInteract with historic objects using E."
    _show_panel(msg)

func dismiss_panel() -> bool:
    if mission_panel == null or not mission_panel.visible:
        return false
    mission_panel.visible = false
    return true

func debug_warp_to_gate() -> void:
    if not _ready_for_input():
        return
    var p: Vector3 = to_local(world.player.global_position)
    if using_shortcut:
        using_shortcut = false
        world.player.teleport(entrance_from if has_entrance_from else Vector3(0, 1, 16))
        world.toast("Returned to KurdLingo city.")
        return
    entrance_from = world.player.global_position
    has_entrance_from = true
    using_shortcut = true
    world.player.teleport(to_global(Vector3(0, 0.2, 137)))
    world.toast("Erbil Citadel: climb the entrance stairs, explore, and press H for missions.")
