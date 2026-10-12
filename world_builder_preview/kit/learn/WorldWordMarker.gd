@tool
extends Marker3D
## Drag this marker under any editable Godot object; edit vocabulary in Inspector.
## This does not change or renumber the game's original 1,000 word IDs.
@export var word_id: String = ""
@export var english_override: String = ""
@export var sorani_override: String = ""
@export_multiline var example_en: String = ""
@export_multiline var example_ckb: String = ""
@export_range(1.0, 6.0, 0.1) var interact_radius: float = 2.8
@export var learning_enabled: bool = true

func _enter_tree() -> void:
    add_to_group("kurdlingo_learning_points")

func get_word_override() -> String:
    return english_override
