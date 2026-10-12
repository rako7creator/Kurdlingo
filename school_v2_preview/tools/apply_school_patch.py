#!/usr/bin/env python3
"""Safely attach the new school to existing KurdLingo scripts/main.gd.

Run from the project root after copying school/. Never overwrites editable_world.tscn.
A .before_school_phase2 backup is created for scripts/main.gd.
Idempotent: repeated invocation does not duplicate hooks.
"""
from pathlib import Path
import sys

root=Path.cwd()
p=root/'scripts'/'main.gd'
required=[root/'project.godot',root/'school'/'SchoolModule.tscn',root/'school'/'SchoolModule.gd',root/'school'/'school_content.json']
missing=[str(x.relative_to(root)) for x in required if not x.exists()]
if missing:
    sys.exit('Missing required project or school files: '+', '.join(missing))
if not p.exists():sys.exit('Missing scripts/main.gd')
s=p.read_text(encoding='utf-8')
if 'var school_module' in s and 'school_module.try_interact()' in s:
    print('School already appears integrated. No changes made.');sys.exit(0)
if 'var school_module' in s:
    sys.exit('Partial integration detected. Review scripts/main.gd manually before patching.')
replacements=[
  ('var handling: ObjectHandling\n','var handling: ObjectHandling\nvar school_module\n'),
  ('\tshow_title()\n\tif bool(options.fullscreen):',
   '\tshow_title()\n\t# Phase 2 school is a modular scene, never part of generated editor world.\n\tschool_module=preload("res://school/SchoolModule.tscn").instantiate()\n\tschool_module.world=self\n\tadd_child(school_module)\n\tif bool(options.fullscreen):'),
  ('\t\tif event.keycode==KEY_ESCAPE:\n',
   '\t\tif event.keycode==KEY_ESCAPE and school_module!=null and school_module.dismiss_panel():\n\t\t\tget_viewport().set_input_as_handled();return\n\t\tif event.keycode==KEY_ESCAPE:\n'),
  ('\t\t\tKEY_E:interact()\n',
   '\t\t\tKEY_E:\n\t\t\t\tif school_module==null or not school_module.try_interact():interact()\n\t\t\tKEY_F8:\n\t\t\t\tif school_module!=null:school_module.debug_warp_to_gate()\n\t\t\tKEY_F9:\n\t\t\t\tif school_module!=null:school_module.open_missions()\n')
]
for original,replacement in replacements:
    count=s.count(original)
    if count!=1:
        sys.exit('Cannot safely patch: expected exactly one instance of '+repr(original.strip())+', found '+str(count)+'. No edits made.')
    s=s.replace(original,replacement,1)
backup=p.with_name(p.name+'.before_school_phase2')
if backup.exists():sys.exit('Backup already exists; refusing to overwrite '+str(backup))
backup.write_bytes(p.read_bytes())
p.write_text(s,encoding='utf-8')
print('SUCCESS: attached modular school; preserved the original main.gd backup:',backup)
print('Review git diff; test with Godot before committing. F8 = warp to school gateway (debug); F9 = school missions (inside school).')
