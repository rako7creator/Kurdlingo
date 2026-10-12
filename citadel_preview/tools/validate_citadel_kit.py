#!/usr/bin/env python3
"""Lightweight offline sanity tests; does not run Godot."""
from pathlib import Path
from tempfile import TemporaryDirectory
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
script = (root / 'citadel/CitadelModule.gd').read_text(encoding='utf-8')
scene = (root / 'citadel/CitadelModule.tscn').read_text(encoding='utf-8')
installer = root / 'tools/apply_citadel_patch.py'
assert '[ext_resource' in scene and 'CitadelModule.gd' in scene
for func in ['_ready', '_terrain', '_outer_walls', '_gate', '_traditional_houses', '_bazaar', '_tea_house', '_museum', 'try_interact', 'open_missions', 'dismiss_panel', 'debug_warp_to_gate']:
    assert f'func {func}(' in script, func
for token in ['world.inspect_word(', 'ProgressStore.write(', 'HEIGHT', 'SITE', 'world.save_progress()', 'mission_panel']:
    assert token in script, token
for forbidden in ['generate_editor_world.gd', 'editable_world.tscn =', 'vocabulary.append(']:
    assert forbidden not in script, forbidden

# The patcher is checked against a minimal Phase1 main template AND a School V2 template.
for use_school in [False, True]:
    with TemporaryDirectory() as tmp:
        base = Path(tmp)
        for path in ['project.godot', 'citadel/CitadelModule.gd', 'citadel/CitadelModule.tscn', 'scripts/progress_store.gd']:
            dst = base / path
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text('placeholder', encoding='utf-8')
        main = ('var handling: ObjectHandling\n'
                'func _ready():\n\tshow_title()\n\tif bool(options.fullscreen):DisplayServer.window_set_mode()\n'
                'func _unhandled_input(event):\n'
                + ('\t\tif event.keycode==KEY_ESCAPE and school_module!=null and school_module.dismiss_panel():\n\t\t\treturn\n' if use_school else '')
                + '\t\tif event.keycode==KEY_ESCAPE:\n\t\t\tpass\n'
                '\tmatch event.keycode:\n')
        main += ('\t\t\tKEY_E:\n\t\t\t\tif school_module==null or not school_module.try_interact():interact()\n'
                 if use_school else '\t\t\tKEY_E:interact()\n')
        main += '\t\t\tKEY_T:story.menu()\n'
        (base / 'scripts/main.gd').write_text(main, encoding='utf-8')
        p = subprocess.run([sys.executable, str(installer)], cwd=base, capture_output=True, text=True)
        assert p.returncode == 0, p.stderr+p.stdout
        new = (base / 'scripts/main.gd').read_text(encoding='utf-8')
        assert 'citadel_module.try_interact()' in new
        assert 'KEY_F10:' in new and 'KEY_H:' in new
        assert '.before_citadel_phase3' in str(list((base/'scripts').glob('*before*')))
        p2 = subprocess.run([sys.executable, str(installer)], cwd=base, capture_output=True, text=True)
        assert p2.returncode == 0 and 'already integrated' in p2.stdout
print('OK: Scene/script content sanity + patcher (with or without School V2) + repeat-safe installation')
