#!/usr/bin/env python3
"""Safely install editor-editable support in existing KurdLingo project.

Run from project root:
 python ./editable_preview/tools/install_editable_world.py prepare
 python ./editable_preview/tools/install_editable_world.py status
 python ./editable_preview/tools/install_editable_world.py activate-school
 python ./editable_preview/tools/install_editable_world.py activate-citadel

Nothing modifies editable_world.tscn or vocabulary.json.
"""
from pathlib import Path
import hashlib
import shutil
import sys

ROOT = Path.cwd()
KIT = Path(__file__).resolve().parents[1]
MAIN = ROOT / 'scripts' / 'main.gd'
SCHOOL = ROOT / 'school' / 'SchoolModule.gd'
BACKUP_SCHOOL = ROOT / 'school' / 'SchoolModule.gd.before_editable_world'
BACKUP_MAIN = ROOT / 'scripts' / 'main.gd.before_editable_world'
SCENE_SCHOOL = ROOT / 'school' / 'SchoolEditable.tscn'
SCENE_CITADEL = ROOT / 'citadel' / 'CitadelEditable.tscn'
SCHOOL_FROM = 'res://school/SchoolModule.tscn'
SCHOOL_TO = 'res://school/SchoolEditable.tscn'
CITADEL_FROM = 'res://citadel/CitadelModule.tscn'
CITADEL_TO = 'res://citadel/CitadelEditable.tscn'


def stop(message):
    sys.exit('STOP (no destructive changes): ' + message)


def sha(b):
    return hashlib.sha256(b).hexdigest()


def needed():
    for file in [ROOT/'project.godot', MAIN, SCHOOL, ROOT/'school'/'school_content.json', ROOT/'citadel'/'CitadelModule.gd', ROOT/'scenes'/'editable_world.tscn']:
        if not file.is_file():
            stop('Missing ' + str(file))


def safe_copy(src, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        if dest.read_bytes() != src.read_bytes():
            stop(f'File already exists with different content: {dest}. Please review manually.')
        return
    shutil.copy2(src, dest)


def atomic_write(path, content):
    temporary = path.with_name(path.name + '.editable_world_tmp')
    if temporary.exists():
        stop('Temporary file already exists: ' + str(temporary))
    temporary.write_text(content, encoding='utf-8')
    temporary.replace(path)


def check_branch():
    import subprocess
    result = subprocess.run(['git', 'branch', '--show-current'], cwd=ROOT, capture_output=True, text=True)
    if result.returncode == 0:
        print('Git branch:', result.stdout.strip())
        if result.stdout.strip() != 'codex/phase-0-audit':
            stop('You wanted to use codex/phase-0-audit. Switch back or review branch before editing.')


def prepare():
    needed()
    check_branch()
    original_hash = (KIT/'school'/'SOURCE_SHA256.txt').read_text().strip()
    desired_school = (KIT/'school'/'SchoolModule.editable_patch.gd').read_bytes()
    actual_school = SCHOOL.read_bytes()
    if actual_school != desired_school and sha(actual_school) != original_hash:
        stop('SchoolModule.gd has changed from the uploaded source. Preserve those edits; upload the updated script for a revised kit.')
    resources = [
        ('learn/WorldWordMarker.gd', 'learn/WorldWordMarker.gd'),
        ('learn/WorldLearningHub.gd', 'learn/WorldLearningHub.gd'),
        ('learn/custom_words.json', 'learn/custom_words.json'),
        ('tools/bake_school_editable.gd', 'tools/bake_school_editable.gd'),
        ('tools/create_future_editable_templates.gd', 'tools/create_future_editable_templates.gd'),
        ('tools/Run_Editable_Builders_Windows.ps1', 'tools/Run_Editable_Builders_Windows.ps1'),
    ]
    for source, destination in resources:
        src = KIT/source
        dest = ROOT/destination
        if dest.is_file() and dest.read_bytes() != src.read_bytes():
            stop('Existing unrelated file differs: ' + destination)
    main_txt = MAIN.read_text(encoding='utf-8')
    add_hub = 'var learning_hub' not in main_txt
    if add_hub:
        if main_txt.count('var handling: ObjectHandling\n') != 1 or main_txt.count('func interact() -> void:\n') != 1:
            stop('Unexpected main.gd structure. Refusing to alter the main script.')
        if main_txt.count('\thandling=ObjectHandling.new(self)\n') != 1:
            stop('Cannot identify safe point to create the learning hub.')
    if BACKUP_SCHOOL.exists() and actual_school != desired_school:
        stop('A school backup already exists but SchoolModule.gd differs; check previous preparation.')
    if BACKUP_MAIN.exists() and add_hub:
        stop('A prior main.gd backup exists. Review before retrying.')
    # Stage copies before modifications; original world and data never changed.
    for source, destination in resources:
        safe_copy(KIT/source, ROOT/destination)
    if actual_school != desired_school:
        shutil.copy2(SCHOOL, BACKUP_SCHOOL)
        atomic_write(SCHOOL, desired_school.decode('utf-8'))
    if add_hub:
        shutil.copy2(MAIN, BACKUP_MAIN)
        main_txt = main_txt.replace('var handling: ObjectHandling\n', 'var handling: ObjectHandling\nvar learning_hub\n', 1)
        main_txt = main_txt.replace('\thandling=ObjectHandling.new(self)\n', '\thandling=ObjectHandling.new(self)\n\tlearning_hub=load("res://learn/WorldLearningHub.gd").new()\n\tlearning_hub.world=self\n\tadd_child(learning_hub)\n', 1)
        main_txt = main_txt.replace('func interact() -> void:\n', 'func interact() -> void:\n\tif learning_hub!=null and learning_hub.try_interact():return\n', 1)
        atomic_write(MAIN, main_txt)
    print('SUCCESS: Editable-world support prepared. The original city and vocabulary are untouched.')
    print('NEXT: Keep Godot open and run tools/Run_Editable_Builders_Windows.ps1 in PowerShell.')
    print('Then inspect editable scenes before running activate-school / activate-citadel.')


def status():
    needed()
    text = MAIN.read_text(encoding='utf-8')
    for label, check in [('School prepared', (KIT/'school'/'SchoolModule.editable_patch.gd').read_bytes() == SCHOOL.read_bytes()),
                         ('Learning hub installed', 'learning_hub=load("res://learn/WorldLearningHub.gd").new()' in text),
                         ('School editable scene created', SCENE_SCHOOL.is_file()),
                         ('School editable scene active', SCHOOL_TO in text),
                         ('Citadel editable scene created', SCENE_CITADEL.is_file()),
                         ('Citadel editable scene active', CITADEL_TO in text)]:
        print(label + ':', 'YES' if check else 'NO')
    print('Original city saved scene preserved:', (ROOT/'scenes'/'editable_world.tscn').is_file())


def activate(old, new, output, meta, backup_name):
    needed()
    if not output.is_file():
        stop('Baked scene not found: ' + str(output))
    if meta.encode() not in output.read_bytes():
        stop('Baked scene metadata missing. Do not activate an unverified scene.')
    text = MAIN.read_text(encoding='utf-8')
    if new in text:
        print('Already active; no files changed.')
        return
    if text.count(old) != 1:
        stop('Scene path not unique in current main.gd; no files modified.')
    backup = MAIN.with_name(backup_name)
    if backup.exists():
        stop('Activation backup already exists; refusing to replace it.')
    shutil.copy2(MAIN, backup)
    atomic_write(MAIN, text.replace(old, new, 1))
    print('SUCCESS: Changed scene reference to', new)
    print('Backup saved:', backup)
    print('Run Godot F5 and check doors, stairs, collisions, learning interactions and camera.')


def main():
    mode = sys.argv[1] if len(sys.argv)>1 else 'status'
    if mode == 'prepare': prepare()
    elif mode == 'status': status()
    elif mode == 'activate-school': activate(SCHOOL_FROM, SCHOOL_TO, SCENE_SCHOOL, 'school_editor_baked', 'main.gd.before_activating_school_editable')
    elif mode == 'activate-citadel':
        if not (ROOT/'citadel'/'CitadelModule.gd.before_editable_conversion').exists():
            stop('Citadel converter preparation not detected; do not activate an unpatched Citadel script.')
        activate(CITADEL_FROM, CITADEL_TO, SCENE_CITADEL, 'citadel_editor_baked', 'main.gd.before_activating_citadel_editable')
    else: stop('Choose: prepare, status, activate-school, activate-citadel')

if __name__ == '__main__': main()
