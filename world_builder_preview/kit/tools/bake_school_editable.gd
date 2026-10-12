extends SceneTree
## One-time conversion. Does not touch original SchoolModule.tscn or editable_world.tscn.
const ORIGINAL := "res://school/SchoolModule.tscn"
const OUTPUT := "res://school/SchoolEditable.tscn"
const DATA := "res://school/school_content.json"
const WORD_SCRIPT := "res://learn/WorldWordMarker.gd"

func _initialize() -> void:
    call_deferred("_bake")

func _bake() -> void:
    if FileAccess.file_exists(OUTPUT):
        _error("SchoolEditable.tscn already exists. Refusing to overwrite editor changes.")
        return
    var base: PackedScene = load(ORIGINAL)
    var catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA))
    var word_script: Script = load(WORD_SCRIPT)
    if base == null or not catalog is Dictionary or word_script == null:
        _error("School scene, content or WorldWordMarker script is missing.")
        return
    var school: Node3D = base.instantiate() as Node3D
    if school == null:
        _error("Original school root isn't Node3D.")
        return
    school.set("content", catalog)
    # Detached scene: _ready() is not called, so no live player/save/UI is needed.
    school.call("_build_school")
    school.call("_build_entry")
    var words: Array = school.get("word_nodes")
    var doors: Array = school.get("doors")
    var npcs: Array = school.get("npcs")
    var roofs: Array = school.get("roof_parts")
    if words.size() < 30 or doors.size() < 5 or roofs.size() < 4:
        school.free()
        _error("School construction incomplete: word markers=%d, doors=%d, roofs=%d" % [words.size(), doors.size(), roofs.size()])
        return
    for i in range(words.size()):
        var row: Dictionary = words[i]
        var host: Node3D = row.get("node") as Node3D
        if host == null:
            school.free()
            _error("Word object missing during bake.")
            return
        var word: String = str(row.get("word", ""))
        host.set_meta("school_baked_word", {"word":word,"room":str(row.get("room", ""))})
        var marker: Marker3D = Marker3D.new()
        marker.name = "LearningPoint_%03d_%s" % [i, word.replace(" ", "_").replace("/", "_")]
        marker.set_script(word_script)
        marker.set("english_override", word)
        marker.set("interact_radius", 2.7)
        marker.position = Vector3(0, 0.9, 0)
        host.add_child(marker)
    for i in range(doors.size()):
        var row: Dictionary = doors[i]
        var door: Node3D = row.get("node") as Node3D
        if door != null:
            door.set_meta("school_baked_door", {"side": int(row.get("side", 1))})
    for i in range(npcs.size()):
        var row: Dictionary = npcs[i]
        var npc: Node3D = row.get("node") as Node3D
        if npc != null:
            npc.name = "SchoolNPC_%s" % str(row.get("id", "person")).replace(" ", "_")
            npc.set_meta("school_baked_npc", {"id": str(row.get("id", "")), "title": str(row.get("title", "NPC"))})
    for node in roofs:
        var roof: Node3D = node as Node3D
        if roof != null:
            roof.set_meta("school_baked_roof", true)
    school.set_meta("school_editor_baked", true)
    school.set_meta("school_bake_version", 1)
    _assign_owners(school, school)
    var pack := PackedScene.new()
    var packed := pack.pack(school)
    if packed != OK:
        school.free()
        _error("Could not pack school: " + error_string(packed))
        return
    var saved := ResourceSaver.save(pack, OUTPUT)
    school.free()
    if saved != OK:
        _error("Could not save school: " + error_string(saved))
        return
    print("SUCCESS: SchoolEditable.tscn created with %d learning objects, %d doors, %d NPCs and %d roofs." % [words.size(), doors.size(), npcs.size(), roofs.size()])
    quit(0)

func _assign_owners(parent: Node, root: Node) -> void:
    for child in parent.get_children():
        child.owner = root
        _assign_owners(child, root)

func _error(message: String) -> void:
    push_error("SCHOOL BAKE FAILED: " + message)
    quit(1)
