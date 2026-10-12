extends SceneTree
## Run with Godot 4.7: godot --headless --path PROJECT --script res://tools/bake_citadel_editable.gd
## Output is a NEW scene. The original CitadelModule.tscn is NOT overwritten.
const SOURCE := "res://citadel/CitadelModule.tscn"
const OUTPUT := "res://citadel/CitadelEditable.tscn"
const CONSTRUCTION := [
    "_terrain", "_outer_walls", "_gate", "_alleyways",
    "_traditional_houses", "_bazaar", "_tea_house", "_museum",
    "_historic_square", "_guide"
]

func _initialize() -> void:
    call_deferred("_bake")

func _bake() -> void:
    if FileAccess.file_exists(OUTPUT):
        _fail("Editable scene already exists. Refusing to overwrite your editor changes: " + OUTPUT)
        return
    var source_scene: PackedScene = load(SOURCE)
    if source_scene == null:
        _fail("Could not load " + SOURCE)
        return
    var citadel: Node3D = source_scene.instantiate() as Node3D
    if citadel == null:
        _fail("Root of source Citadel scene is not Node3D.")
        return
    if bool(citadel.get_meta("citadel_editor_baked", false)):
        citadel.free()
        _fail("Source is already baked; refusing to bake it twice.")
        return
    # The source script is executed on this DETACHED scene. _ready() never runs,
    # so no player, saved data, audio, generated UI or world is required.
    citadel.position = Vector3(-235.0, 0.0, -167.0)
    for method_name in CONSTRUCTION:
        if not citadel.has_method(method_name):
            citadel.free()
            _fail("Construction function missing: " + str(method_name))
            return
        citadel.call(method_name)
    var points: Array = citadel.get("interactables")
    if points.size() < 35:
        citadel.free()
        _fail("Too few learning points; construction did not complete safely.")
        return
    for i in range(points.size()):
        var entry: Dictionary = points[i]
        var host: Node3D = entry.get("parent") as Node3D
        if host == null:
            citadel.free()
            _fail("Interaction parent missing at index " + str(i))
            return
        var marker := Marker3D.new()
        marker.name = "LearningPoint_%03d_%s" % [i, _safe_label(str(entry.get("label", "Item")))]
        marker.position = entry.get("point", Vector3.ZERO)
        marker.set_meta("citadel_baked_interaction", {
            "label": str(entry.get("label", "")),
            "word": str(entry.get("word", "")),
            "mission": str(entry.get("mission", "")),
            "dialogue": str(entry.get("dialogue", ""))
        })
        host.add_child(marker)
    var roof_list: Array = citadel.get("roofs")
    if roof_list.size() < 30:
        citadel.free()
        _fail("Expected house roof geometry was not generated.")
        return
    for entry in roof_list:
        var roof: MeshInstance3D = entry.get("roof") as MeshInstance3D
        if roof != null:
            roof.set_meta("citadel_baked_roof", true)
    citadel.set_meta("citadel_editor_baked", true)
    citadel.set_meta("citadel_bake_version", 1)
    _assign_owners(citadel, citadel)
    var output_scene := PackedScene.new()
    var packing_error := output_scene.pack(citadel)
    if packing_error != OK:
        citadel.free()
        _fail("PackedScene.pack failed: " + error_string(packing_error))
        return
    var save_error := ResourceSaver.save(output_scene, OUTPUT)
    citadel.free()
    if save_error != OK:
        _fail("Could not write " + OUTPUT + ": " + error_string(save_error))
        return
    print("SUCCESS: Created editable Citadel scene: " + OUTPUT)
    print("Saved ", points.size(), " learning markers and ", roof_list.size(), " removable roof parts.")
    print("NEXT: Open CitadelEditable.tscn in Godot. Then run installer activate to use it in the game.")
    quit(0)

func _safe_label(words: String) -> String:
    var result := ""
    for character in words:
        if character.is_valid_identifier():
            result += character
        else:
            result += "_"
    return result.substr(0, 36)

func _assign_owners(parent: Node, root: Node) -> void:
    for child in parent.get_children():
        child.owner = root
        _assign_owners(child, root)

func _fail(message: String) -> void:
    push_error("CITADEL BAKE FAILED: " + message)
    quit(1)
