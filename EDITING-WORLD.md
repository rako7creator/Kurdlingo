# Editing the world in Godot

The game now uses the actual saved EditableWorld scene at startup. Position,
rotation, scale, mesh/material edits, copied decorations, and deleted decorations
are preserved in gameplay. main.tscn overrides are included too.

For adding, copying, or deleting objects, open scenes/editable_world.tscn directly.
Select the top-level object Node3D so its graphics and collision move together.
Save all open scenes, stop the game, then run main.tscn with F5.
Changes to a visual mesh's size do not automatically resize its collision shape.

Gameplay references are rebound using the original layout_index metadata. Keep
that metadata on existing objects. Copied learning objects share the original
word identity; adding a new word still requires updating vocabulary data/code.
Personal saved object positions can override vocabulary object positions; use
the game's Reset moved objects setting to test the project layout for those words.

Do not run tools/generate_editor_world.gd after editing without a backup: it
replaces the saved world scene with a newly generated original layout.
