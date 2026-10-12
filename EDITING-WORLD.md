# Editing the world in Godot

The game now uses the actual saved EditableWorld scene at startup. Position,
rotation, scale, mesh/material edits, copied decorations, and deleted decorations
are preserved in gameplay. main.tscn overrides are included too.

For adding, copying, or deleting objects, open scenes/editable_world.tscn directly.
Select the top-level object Node3D so its graphics and collision move together.
Save all open scenes, stop the game, then run main.tscn with F5.
Changes to a visual mesh's size do not automatically resize its collision shape.

Gameplay references now use persistent `world_id`, `world_role`, and `world_key`
metadata on top-level objects. Keep these on existing objects. Vocabulary objects
also keep their original `word_id`. Node order and old `layout_index` values no
longer control gameplay. The frozen `data/world_legacy_bindings.json` map provides
a fallback for older scene copies; do not update it when editing the city.

Duplicating an object copies its ID. Give a copied decoration a fresh UUID and
remove `world_role` and `world_key` if it is purely decorative. For a decorative
copy of a learning object, also remove `word_id` from the copy and its collider.
A new learning object needs its own vocabulary entry, recordings, UUID, and
matching word metadata. Duplicate IDs or missing learning/NPC bindings stop
startup with an explicit error instead of silently selecting the wrong node.

Saved anonymous `@...` node names receive safe names in memory to avoid collisions
with runtime-created objects. Their editor names and the saved scene stay intact.
Personal saved object positions can override vocabulary object positions; use
the game's Reset moved objects setting to test the project layout for those words.

Existing building camera blockers also block walking. Existing tree and streetlight
blockers gain a simple trunk/pole collider at runtime; foliage remains passable.
The `world_collision` metadata selects this behaviour. Small decorations do not
automatically gain colliders. Progress saves retain version 3 and existing word
IDs, write through a checked staging file, and keep the previous valid `.bak`.

Phase 1 verification: `python tools/verify_phase1_preservation.py` checks the
checkpoint's geometry and assets. Run `godot --headless --path <isolated-copy>
--script res://tools/verify_phase1.gd` for binding/collision/save regression tests,
and `godot --headless --path <isolated-copy> -- --self-test` for existing gameplay.
Give test copies a distinct `config/custom_user_dir_name` in their project.godot
before launching them, so test data and any startup saves stay isolated.

Do not run tools/generate_editor_world.gd against this edited world: it
replaces the saved world scene with a newly generated original layout.
