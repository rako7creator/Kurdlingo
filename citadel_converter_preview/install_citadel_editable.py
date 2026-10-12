#!/usr/bin/env python3
"""Prepare, activate, check, or revert the editable Erbil Citadel conversion.

Run from KurdLingo PROJECT ROOT, passing this file path as an argument:
python .\citadel_editable_preview\install_citadel_editable.py prepare
python .\citadel_editable_preview\install_citadel_editable.py activate
python .\citadel_editable_preview\install_citadel_editable.py status
python .\citadel_editable_preview\install_citadel_editable.py revert
"""
from pathlib import Path
import hashlib
import shutil
import sys

PROJECT = Path.cwd()
KIT = Path(__file__).resolve().parent
ORIGINAL_SHA = (KIT/'ORIGINAL_SCRIPT_SHA256.txt').read_text().strip()
CITADEL = PROJECT/'citadel'
TOOLS = PROJECT/'tools'
MODULE = CITADEL/'CitadelModule.gd'
MODULE_BACKUP = CITADEL/'CitadelModule.gd.before_editable_conversion'
BAKER = TOOLS/'bake_citadel_editable.gd'
BAKED = CITADEL/'CitadelEditable.tscn'
MAIN = PROJECT/'scripts'/'main.gd'
MAIN_BACKUP = PROJECT/'scripts'/'main.gd.before_editable_conversion'
OLD_SCENE = 'res://citadel/CitadelModule.tscn'
NEW_SCENE = 'res://citadel/CitadelEditable.tscn'


def fail(message):
    sys.exit('STOP: ' + message)


def checksum(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_project():
    for path in (PROJECT/'project.godot', MODULE, CITADEL/'CitadelModule.tscn', MAIN):
        if not path.is_file():
            fail('Missing project file: ' + str(path))
    branch_file = PROJECT/'.git'
    # The current branch is checked via git separately; do not change it here.


def prepare():
    require_project()
    expected = KIT/'citadel'/'CitadelModule.editable_patch.gd'
    baker_source = KIT/'tools'/'bake_citadel_editable.gd'
    if not expected.is_file() or not baker_source.is_file():
        fail('Some converter files are missing from the extracted ZIP.')
    if MODULE_BACKUP.exists():
        if MODULE.read_bytes() == expected.read_bytes():
            print('Already prepared. The original Citadel script backup exists.')
            return
        fail('Backup exists but current CitadelModule.gd differs. Do not overwrite it.')
    if checksum(MODULE) != ORIGINAL_SHA:
        fail('CitadelModule.gd has changed since it was uploaded. No files modified; send me the new script.')
    if BAKER.exists() and BAKER.read_bytes() != baker_source.read_bytes():
        fail('A different bake script already exists. No files modified.')
    # First create a backup. No main.gd, original world or .tscn is changed.
    CITADEL.mkdir(parents=True, exist_ok=True)
    TOOLS.mkdir(parents=True, exist_ok=True)
    shutil.copy2(MODULE, MODULE_BACKUP)
    shutil.copy2(baker_source, BAKER)
    try:
        shutil.copy2(expected, MODULE)
    except Exception:
        shutil.copy2(MODULE_BACKUP, MODULE)
        raise
    print('SUCCESS: Prepared editable Citadel script and Godot baking tool.')
    print('Backed up: citadel/CitadelModule.gd.before_editable_conversion')
    print('Original CitadelModule.tscn, saved city, School V2 and main.gd are unchanged.')
    print('NEXT: Use Godot to bake CitadelEditable.tscn, then run activate.')


def activate():
    require_project()
    if not MODULE_BACKUP.exists():
        fail('Run prepare before activate.')
    if not BAKED.is_file():
        fail('CitadelEditable.tscn not yet generated. Run Godot bake first.')
    if b'citadel_editor_baked' not in BAKED.read_bytes():
        fail('CitadelEditable.tscn is missing baked metadata; refusing to activate.')
    source = MAIN.read_text(encoding='utf-8')
    if NEW_SCENE in source:
        print('Editable Citadel already active. No changes made.')
        return
    if source.count(OLD_SCENE) != 1:
        fail('Did not find exactly one existing Citadel scene path in scripts/main.gd. No change made.')
    if MAIN_BACKUP.exists():
        fail('A prior main.gd backup exists. Refusing to overwrite.')
    shutil.copy2(MAIN, MAIN_BACKUP)
    try:
        MAIN.write_text(source.replace(OLD_SCENE, NEW_SCENE), encoding='utf-8')
    except Exception:
        shutil.copy2(MAIN_BACKUP, MAIN)
        raise
    print('SUCCESS: The game now loads CitadelEditable.tscn instead of the generated original.')
    print('Main script backup: scripts/main.gd.before_editable_conversion')
    print('Original CitadelModule.tscn remains available; no duplicate Citadel is loaded.')
    print('NEXT: Open Godot, edit citadel/CitadelEditable.tscn, save, and test F10/E/H.')


def status():
    require_project()
    source = MAIN.read_text(encoding='utf-8')
    print('Current folder:', PROJECT)
    print('Original Citadel backup:', MODULE_BACKUP.exists())
    print('Baking tool installed:', BAKER.is_file())
    print('Editable scene generated:', BAKED.is_file())
    print('Editable scene active:', NEW_SCENE in source)
    print('Original scene active:', OLD_SCENE in source)


def revert():
    require_project()
    if MAIN_BACKUP.exists():
        source = MAIN.read_text(encoding='utf-8')
        if source.count(NEW_SCENE) != 1:
            fail('Main.gd was modified again. Refusing to overwrite; restore it manually from its backup.')
        restored = source.replace(NEW_SCENE, OLD_SCENE)
        MAIN.write_text(restored, encoding='utf-8')
        print('Restored original active Citadel scene path in scripts/main.gd.')
    if MODULE_BACKUP.exists():
        patched = (KIT/'citadel'/'CitadelModule.editable_patch.gd').read_bytes()
        if MODULE.read_bytes() != patched:
            fail('Citadel script has additional changes. Not overwriting your edits; restore manually.')
        shutil.copy2(MODULE_BACKUP, MODULE)
        print('Restored original CitadelModule.gd from backup.')
    print('CitadelEditable.tscn left in place to preserve editor changes.')


if __name__ == '__main__':
    mode = sys.argv[1].strip().lower() if len(sys.argv)>1 else 'status'
    if mode not in {'prepare','activate','status','revert'}:
        fail('Use one of: prepare, activate, status, revert')
    {'prepare':prepare,'activate':activate,'status':status,'revert':revert}[mode]()
