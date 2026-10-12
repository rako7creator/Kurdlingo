#!/usr/bin/env python3
"""Optional last step to show baked School and Citadel IN main.tscn's editor.
Requires tested, active SchoolEditable and CitadelEditable scenes.
Creates backups; refuses unexpected source versions and prior main scene integration.
"""
from pathlib import Path
import shutil
import sys

root = Path.cwd()
main = root/'scripts'/'main.gd'
scene = root/'main.tscn'
school = root/'school'/'SchoolModule.gd'
citadel = root/'citadel'/'CitadelModule.gd'
school_scene = root/'school'/'SchoolEditable.tscn'
citadel_scene = root/'citadel'/'CitadelEditable.tscn'

def stop(message):
    sys.exit('STOP — nothing changed: '+message)

for path in (main, scene, school, citadel, school_scene, citadel_scene):
    if not path.is_file(): stop('Missing '+str(path))

source = main.read_text(encoding='utf-8')
original_scene = scene.read_text(encoding='utf-8')
cs = citadel.read_text(encoding='utf-8')
ss = school.read_text(encoding='utf-8')

if 'school_editor_baked' not in school_scene.read_text(encoding='utf-8'):
    stop('SchoolEditable scene is missing its baked metadata.')
if 'citadel_editor_baked' not in citadel_scene.read_text(encoding='utf-8'):
    stop('CitadelEditable scene is missing its baked metadata.')
if 'call_deferred("_initialize_school")' not in ss:
    stop('School script does not support delayed initialization; run the new kit prepare first.')
if 'res://school/SchoolEditable.tscn' in original_scene or 'res://citadel/CitadelEditable.tscn' in original_scene:
    stop('One or more areas already appears in main.tscn. Review it before trying again.')
if original_scene.count('[gd_scene load_steps=3 format=3]')!=1:
    stop('Unexpected main.tscn scene header.')
city_resource='[ext_resource type="PackedScene" path="res://scenes/editable_world.tscn" id="2"]'
if original_scene.count(city_resource)!=1 or original_scene.count('[editable path="EditableWorld"]')!=1:
    stop('Current main.tscn does not match the safely supported scene layout.')
if 'id="3"' in original_scene or 'id="4"' in original_scene:
    stop('Main scene already has extra resource identifiers.')

old_school = ('school_module=preload("res://school/SchoolEditable.tscn").instantiate()\n'
              '\tschool_module.world=self\n'
              '\tadd_child(school_module)')
old_citadel = ('citadel_module=preload("res://citadel/CitadelEditable.tscn").instantiate()\n'
               '\tcitadel_module.world=self\n'
               '\tadd_child(citadel_module)')
if source.count(old_school)!=1 or source.count(old_citadel)!=1:
    stop('main.gd has unexpected creation code; cannot prevent duplicate school/citadel.')

head='''func _ready() -> void:
    if world == null:
        push_error("CitadelModule requires a world reference before add_child().")
        return
    # A baked scene already owns its editable geometry and transforms.'''
replacement='''func _ready() -> void:
    if world == null:
        # Direct child of main.tscn: wait until the parent has loaded vocabulary/UI.
        world = get_parent()
        call_deferred("_initialize_citadel")
        return
    _initialize_citadel()

func _initialize_citadel() -> void:
    if world == null:
        push_error("CitadelModule requires a world reference.")
        return
    # A baked scene already owns its editable geometry and transforms.'''
if cs.count(head)!=1:
    stop('CitadelModule.gd is not the known prepared version; do not overwrite custom changes.')

edited_main = source.replace(old_school, 'school_module=get_node("SchoolEditable")', 1)
edited_main = edited_main.replace(old_citadel, 'citadel_module=get_node("CitadelEditable")', 1)
edited_scene = original_scene.replace('[gd_scene load_steps=3 format=3]', '[gd_scene load_steps=5 format=3]', 1)
edited_scene = edited_scene.replace(city_resource, city_resource+'\n[ext_resource type="PackedScene" path="res://school/SchoolEditable.tscn" id="3"]\n[ext_resource type="PackedScene" path="res://citadel/CitadelEditable.tscn" id="4"]', 1)
edited_scene += '\n[node name="SchoolEditable" parent="." instance=ExtResource("3")]\n\n[node name="CitadelEditable" parent="." instance=ExtResource("4")]\n'
edited_citadel = cs.replace(head,replacement,1)

backups=[(main,main.with_name('main.gd.before_showing_editable_world')),
         (scene,scene.with_name('main.tscn.before_showing_editable_world')),
         (citadel,citadel.with_name('CitadelModule.gd.before_showing_editable_world'))]
for _,backup in backups:
    if backup.exists(): stop('Backup already exists: '+str(backup))
for original,backup in backups: shutil.copy2(original,backup)
# All matching/preflight operations have completed. Make the three changes.
main.write_text(edited_main,encoding='utf-8')
citadel.write_text(edited_citadel,encoding='utf-8')
scene.write_text(edited_scene,encoding='utf-8')
print('SUCCESS: SchoolEditable and CitadelEditable now appear in main.tscn editor and are not created a second time during Play.')
print('Original city scene preserved. Backups created for all three modified files.')
print('NEXT: Reopen main.tscn in Godot; test F5, F8/E, F10/E/H, and older vocabulary.')
