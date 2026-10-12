extends Node
## E interaction for user-created vocabulary markers in any saved Godot scene.
## Existing school/Citadel interactions keep their own precedence in main.gd.
const CATALOG := "res://learn/custom_words.json"
const SAVE := "user://kurdlingo_custom_words_progress.json"
var world: Node3D
var known: Dictionary = {}
var custom: Dictionary = {}
var discovered: Dictionary = {}
var layer: CanvasLayer
var popup: PanelContainer
var panel: VBoxContainer
var voice: AudioStreamPlayer

func _ready() -> void:
    if world == null:
        push_error("WorldLearningHub requires a world reference.")
        return
    for entry in world.vocabulary:
        known[str(entry.id)] = entry
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
    if parsed is Array:
        for row in parsed:
            if row is Dictionary and str(row.get("id", "")) != "":
                custom[str(row.id)] = row
    var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE)) if FileAccess.file_exists(SAVE) else {}
    if loaded is Dictionary:
        discovered = loaded
    layer = CanvasLayer.new()
    layer.layer = 16
    add_child(layer)
    voice = AudioStreamPlayer.new()
    add_child(voice)

func try_interact() -> bool:
    if world == null or world.player == null or not world.session_started or world.screen != null:
        return false
    if popup != null and is_instance_valid(popup):
        return false
    var winner: Marker3D
    var nearest := 6.1
    var player_pos: Vector3 = world.player.global_position
    for item in get_tree().get_nodes_in_group("kurdlingo_learning_points"):
        if not item is Marker3D or not item.is_inside_tree():
            continue
        if not bool(item.get("learning_enabled")):
            continue
        var dist := player_pos.distance_to(item.global_position)
        var radius: float = float(item.get("interact_radius"))
        if dist <= radius and dist < nearest:
            nearest = dist
            winner = item
    if winner == null:
        return false
    inspect(winner)
    return true

func inspect(marker: Marker3D) -> void:
    var id: String = str(marker.get("word_id")).strip_edges()
    var english: String = str(marker.get("english_override")).strip_edges()
    var sorani: String = str(marker.get("sorani_override")).strip_edges()
    var en_example: String = str(marker.get("example_en"))
    var ckb_example: String = str(marker.get("example_ckb"))
    if known.has(id):
        world.inspect_word(id)
        return
    if custom.has(id):
        var row: Dictionary = custom[id]
        if english == "": english = str(row.get("en", ""))
        if sorani == "": sorani = str(row.get("ckb", ""))
        if en_example == "": en_example = str(row.get("example_en", ""))
        if ckb_example == "": ckb_example = str(row.get("example_ckb", ""))
    if english == "":
        world.toast("Set word_id or English override on the WorldWordMarker in Godot Inspector.")
        return
    # If no ID is supplied, reuse any existing approved vocabulary concept by English.
    if id == "":
        for key in known.keys():
            var row: Dictionary = known[key]
            if str(row.get("en", "")).to_lower() == english.to_lower():
                world.inspect_word(key)
                return
    var save_id: String = id if id != "" else "free:" + english.to_lower()
    discovered[save_id] = true
    _save_custom()
    _show_card(english, sorani if sorani != "" else "Sorani translation pending review", en_example, ckb_example, id)

func _save_custom() -> void:
    var file := FileAccess.open(SAVE + ".tmp", FileAccess.WRITE)
    if file == null:
        push_warning("Could not save custom learning progress")
        return
    file.store_string(JSON.stringify(discovered))
    file.close()
    var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE + ".tmp"), ProjectSettings.globalize_path(SAVE))
    if err != OK:
        push_warning("Custom learning progress could not be finalized: " + str(err))

func _text(words: String, size: int = 21, sorani: bool = false) -> Label:
    var label := Label.new()
    label.text = words
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    if sorani and world.sorani_font != null:
        label.add_theme_font_override("font", world.sorani_font)
        label.text_direction = Control.TEXT_DIRECTION_RTL
    elif world.english_font != null:
        label.add_theme_font_override("font", world.english_font)
    return label

func _show_card(english: String, sorani: String, example_en: String, example_ckb: String, id: String) -> void:
    if popup != null and is_instance_valid(popup):
        popup.queue_free()
    popup = PanelContainer.new()
    popup.set_anchors_preset(Control.PRESET_CENTER)
    popup.custom_minimum_size = Vector2(560, 260)
    popup.offset_left = -280
    popup.offset_right = 280
    popup.offset_top = -180
    popup.offset_bottom = 180
    layer.add_child(popup)
    panel = VBoxContainer.new()
    panel.add_theme_constant_override("separation", 12)
    popup.add_child(panel)
    panel.add_child(_text(english.capitalize(), 30))
    panel.add_child(_text(sorani, 25, true))
    if example_en != "": panel.add_child(_text(example_en, 16))
    if example_ckb != "": panel.add_child(_text(example_ckb, 17, true))
    var row := HBoxContainer.new()
    panel.add_child(row)
    if custom.has(id):
        for lang in ["en", "ckb"]:
            var audio_path: String = str(custom[id].get("audio_" + lang, ""))
            if audio_path != "" and ResourceLoader.exists(audio_path):
                var sound_button := Button.new()
                sound_button.text = "Hear " + ("English" if lang == "en" else "Sorani")
                sound_button.pressed.connect(func(): voice.stream = load(audio_path); voice.play())
                row.add_child(sound_button)
    var close := Button.new()
    close.text = "Close"
    close.pressed.connect(_close_popup)
    row.add_child(close)

func _close_popup() -> void:
    if popup != null and is_instance_valid(popup):
        popup.queue_free()
    popup = null
