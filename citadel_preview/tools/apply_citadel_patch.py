#!/usr/bin/env python3
"""Safely add the independent Phase 3 Erbil Citadel scene to KurdLingo.

Works with current Phase1, standalone Phase2, and School V2 patched main.gd.
No changes to EditableWorld, vocabulary, progress_store or audio.
Run in project root: python tools/apply_citadel_patch.py
"""
from pathlib import Path
import sys
import shutil

root = Path.cwd()
main = root / 'scripts' / 'main.gd'
required = [root / 'project.godot', main,
            root / 'citadel' / 'CitadelModule.gd',
            root / 'citadel' / 'CitadelModule.tscn',
            root / 'scripts' / 'progress_store.gd']
missing = [str(p.relative_to(root)) for p in required if not p.is_file()]
if missing:
    sys.exit('ERROR: Required project files missing: ' + ', '.join(missing))
source = main.read_text(encoding='utf-8')
if 'citadel_module=preload("res://citadel/CitadelModule.tscn")' in source:
    print('Citadel already integrated. No files were modified.')
    sys.exit(0)
if 'var citadel_module' in source or 'citadel_module.try_interact()' in source:
    sys.exit('ERROR: A partial Citadel integration is present. No changes made.')
replacements = [
    ('var handling: ObjectHandling\n', 'var handling: ObjectHandling\nvar citadel_module\n'),
    ('\tif bool(options.fullscreen):DisplayServer.window_set_mode',
     '\t# Phase 3 Citadel is added separately after saved-world and optional school setup.\n'
     '\tcitadel_module=preload("res://citadel/CitadelModule.tscn").instantiate()\n'
     '\tcitadel_module.world=self\n\tadd_child(citadel_module)\n'
     '\tif bool(options.fullscreen):DisplayServer.window_set_mode'),
]

# Preserve the School V2 E hook if installed, and otherwise preserve vanilla E.
school_e = '\t\t\t\tif school_module==null or not school_module.try_interact():interact()'
vanilla_e = '\t\t\tKEY_E:interact()'
if school_e in source:
    replacements.append((school_e,
        '\t\t\t\tif citadel_module==null or not citadel_module.try_interact():\n'
        '\t\t\t\t\tif school_module==null or not school_module.try_interact():interact()'))
elif vanilla_e in source:
    replacements.append((vanilla_e,
        '\t\t\tKEY_E:\n'
        '\t\t\t\tif citadel_module==null or not citadel_module.try_interact():interact()'))
else:
    sys.exit('ERROR: Unsupported E interaction hook; no files changed. Send the main.gd excerpt.')

# Escape from heritage panel takes priority over existing pause logic / school panels.
if '\t\tif event.keycode==KEY_ESCAPE and school_module!=null' in source:
    anchor = '\t\tif event.keycode==KEY_ESCAPE and school_module!=null'
    replacement = ('\t\tif event.keycode==KEY_ESCAPE and citadel_module!=null and citadel_module.dismiss_panel():\n'
                   '\t\t\tget_viewport().set_input_as_handled();return\n' + anchor)
else:
    anchor = '\t\tif event.keycode==KEY_ESCAPE:\n'
    replacement = ('\t\tif event.keycode==KEY_ESCAPE and citadel_module!=null and citadel_module.dismiss_panel():\n'
                   '\t\t\tget_viewport().set_input_as_handled();return\n' + anchor)
replacements.append((anchor, replacement))

# F10 travels to the Citadel. H opens heritage quests (both unused in original game).
key_anchor = '\t\t\tKEY_T:story.menu()'
replacements.append((key_anchor,
    '\t\t\tKEY_F10:\n'
    '\t\t\t\tif citadel_module!=null:citadel_module.debug_warp_to_gate()\n'
    '\t\t\tKEY_H:\n'
    '\t\t\t\tif citadel_module!=null:citadel_module.open_missions()\n' + key_anchor))

for before, after in replacements:
    occurrences = source.count(before)
    if occurrences != 1:
        sys.exit(f'ERROR: Expected exactly one patch anchor {before!r}, found {occurrences}. Nothing changed.')
    source = source.replace(before, after, 1)

backup = main.with_name('main.gd.before_citadel_phase3')
if backup.exists():
    sys.exit('ERROR: Backup already exists. Refusing to overwrite: ' + str(backup))
shutil.copy2(main, backup)
main.write_text(source, encoding='utf-8')
print('SUCCESS: Citadel integrated alongside the original city and any School V2 module.')
print('Backup:', backup)
print('Keys: F10 Citadel travel/return, E inspect/talk, H heritage missions, Esc close.')
print('Please open Godot and verify the school and Citadel before committing.')
