extends SceneTree
## Creates optional EDITABLE starter-scenes; never inserts/replaces existing city.
## These are starter environments, NOT finished game districts.
const ROOT := "res://modules_editable/"
const MARKER := "res://learn/WorldWordMarker.gd"
const PALETTE := [Color("#ddbd93"), Color("#f1d7b4"), Color("#92b5ad"), Color("#b3c5da"), Color("#c99177")]
const THEMES := [
    {"name":"Hospital", "words":["hospital","doctor","bed","chair","medicine","computer","door","window"]},
    {"name":"Supermarket", "words":["shop","apple","bread","basket","plate","water","table","cash register"]},
    {"name":"University", "words":["school","book","computer","desk","library","map","chair","notebook"]},
    {"name":"Library", "words":["book","dictionary","desk","chair","lamp","paper","map","shelf"]},
    {"name":"Bakery", "words":["bread","cake","oven","plate","cup","spoon","table","basket"]},
    {"name":"Police_Station", "words":["police","telephone","desk","computer","door","key","map","chair"]},
    {"name":"Fire_Station", "words":["fire","water","truck","helmet","door","telephone","map","ladder"]},
    {"name":"Bank_PostOffice", "words":["bank","money","letter","telephone","desk","computer","clock","chair"]},
    {"name":"Zoo", "words":["animal","lion","elephant","bird","tree","water","gate","bench"]},
    {"name":"Mountain_Village", "words":["house","mountain","tree","carpet","bread","tea","basket","door"]},
    {"name":"Forest_Waterfall", "words":["tree","water","river","flower","bird","bench","rock","bridge"]},
    {"name":"Desert_Oasis", "words":["sand","water","tree","horse","house","basket","sun","gate"]},
    {"name":"Beach_Harbor", "words":["water","boat","fish","beach","sand","bench","shop","tree"]},
    {"name":"Airport", "words":["airport","airplane","passport","ticket","bag","gate","chair","clock"]},
]
var word_script: Script

func _initialize() -> void:
    call_deferred("_generate")

func _generate() -> void:
    word_script = load(MARKER)
    if word_script == null:
        _failure("Learning marker script missing: " + MARKER)
        return
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT))
    var made := 0
    for theme in THEMES:
        var filename: String = ROOT + str(theme["name"]) + ".tscn"
        if FileAccess.file_exists(filename):
            print("SKIPPED existing editable location (preserving your edits): ", filename)
            continue
        var root := Node3D.new()
        root.name = str(theme["name"]) + "_Editable"
        root.set_meta("starter_scene_only", true)
        root.set_meta("move_into_main_when_ready", true)
        _make_template(root, theme)
        _owners(root, root)
        var packed := PackedScene.new()
        if packed.pack(root) != OK:
            root.free()
            _failure("Packing failed: " + filename)
            return
        var err := ResourceSaver.save(packed, filename)
        root.free()
        if err != OK:
            _failure("Save failed: " + filename + " : " + error_string(err))
            return
        made += 1
    print("SUCCESS: Created ", made, " new editable location starter-scenes in ", ROOT)
    quit(0)

func _make_template(root: Node3D, theme: Dictionary) -> void:
    var name: String = str(theme["name"])
    var is_outdoors: bool = name in ["Zoo", "Mountain_Village", "Forest_Waterfall", "Desert_Oasis", "Beach_Harbor"]
    var lot := Node3D.new()
    lot.name = "Land_and_Paths"
    root.add_child(lot)
    var building := Node3D.new()
    building.name = "Editable_Building_and_Rooms"
    root.add_child(building)
    var props := Node3D.new()
    props.name = "Furniture_and_Learning_Objects"
    root.add_child(props)
    _cube(lot, "PlotGround", Vector3(0, -0.16, 0), Vector3(45, 0.30, 40), Color("#8caf82"), true)
    _cube(lot, "MainWalkway", Vector3(0, 0.02, 14), Vector3(5, 0.06, 14), Color("#d2c4a8"), false)
    if not is_outdoors:
        _cube(building, "GroundFloor", Vector3(0, 0.17, 0), Vector3(29, 0.34, 23), Color("#e8d5af"), true)
        _cube(building, "RearWall", Vector3(0, 2.5, -11.35), Vector3(29, 5, 0.35), PALETTE[0], true)
        for side in [-1, 1]:
            _cube(building, "SideWall", Vector3(float(side) * 14.4, 2.5, 0), Vector3(0.4, 5, 23), PALETTE[0], true)
            _cube(building, "EntranceWallWing", Vector3(float(side) * 9.2, 2.5, 11.35), Vector3(10.2, 5, 0.38), PALETTE[0], true)
            _cube(building, "WindowGlass", Vector3(float(side)*7, 2.5, 11.58), Vector3(5, 2.1, 0.1), Color(0.42, 0.75, 0.84, 0.50), false)
        _cube(building, "DoorHeader", Vector3(0, 4.2, 11.35), Vector3(8.5, 1.65, 0.4), PALETTE[0], true)
        _cube(building, "Roof_remove_for_inside_view", Vector3(0, 5.3, 0), Vector3(30, 0.45, 24), Color(0.72, 0.42, 0.35, 0.33), false)
        _cube(building, "InteriorRoomDivider", Vector3(-5.0, 2.1, -4), Vector3(0.25, 4.2, 10), PALETTE[1], true)
        _cube(building, "FrontDesk", Vector3(0, 0.84, 5.0), Vector3(5, 1.55, 1.5), PALETTE[4], true)
    else:
        for i in range(6):
            var p := Vector3(-13 + float(i%3)*13, 0, -10 + float(i/3)*15)
            _cube(building, "OutdoorPlatform", p + Vector3(0, 0.2, 0), Vector3(9, 0.4, 8), PALETTE[1], true)
            _cube(building, "PavilionRoof", p + Vector3(0, 3.7, 0), Vector3(9.4, 0.35, 8.6), Color(0.62, 0.42, 0.32, 0.50), false)
            for xx in [-4.0, 4.0]:
                _cube(building, "OpenAirColumn", p + Vector3(xx, 1.87, -3.6), Vector3(0.25, 3.7, 0.25), PALETTE[0], true)
    _text(root, name.replace("_", " ").to_upper(), Vector3(0, 6.7, 11.5), 82)
    var items: Array = theme["words"]
    for i in range(items.size()):
        var row: int = i / 4
        var col: int = i % 4
        var x: float = -11.0 + float(col) * 7.0
        var z: float = -7.0 + float(row) * 8.0
        var obj := Node3D.new()
        obj.name = "LearningProp_%02d_%s" % [i, str(items[i]).replace(" ", "_")]
        obj.position = Vector3(x, 0, z)
        props.add_child(obj)
        _cube(obj, "DisplayStand", Vector3(0, 0.42, 0), Vector3(2.6, 0.84, 1.6), PALETTE[i % PALETTE.size()], true)
        _cube(obj, "ItemModel_placeholder", Vector3(0, 1.04, 0), Vector3(1.0, 0.45, 0.65), PALETTE[(i+2) % PALETTE.size()], false)
        _text(obj, str(items[i]).capitalize(), Vector3(0, 1.76, 0.1), 40)
        var marker := Marker3D.new()
        marker.name = "Edit_vocabulary_in_Inspector"
        marker.set_script(word_script)
        marker.set("english_override", str(items[i]))
        marker.set("interact_radius", 2.8)
        marker.position = Vector3(0, 0.95, 1.0)
        obj.add_child(marker)

func _mat(tint: Color) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.roughness = 0.86
    if tint.a < 1.0:
        result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return result

func _cube(parent: Node3D, label_name: String, center: Vector3, size: Vector3, tint: Color, solid: bool) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = label_name
    mesh.position = center
    var cube := BoxMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.material_override = _mat(tint)
    parent.add_child(mesh)
    if solid:
        var body := StaticBody3D.new()
        body.name = "PhysicsCollision"
        body.collision_layer = 1
        body.collision_mask = 0
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = size
        shape.shape = box
        body.add_child(shape)
        mesh.add_child(body)

func _text(parent: Node3D, words: String, point: Vector3, fontsize: int) -> void:
    var sign := Label3D.new()
    sign.name = "EditableRoomSign"
    sign.text = words
    sign.position = point
    sign.font_size = fontsize
    sign.pixel_size = 0.007
    sign.modulate = Color("#20404c")
    parent.add_child(sign)

func _owners(node: Node, root: Node) -> void:
    for child in node.get_children():
        child.owner = root
        _owners(child, root)

func _failure(message: String) -> void:
    push_error("TEMPLATE GENERATOR FAILED: " + message)
    quit(1)
