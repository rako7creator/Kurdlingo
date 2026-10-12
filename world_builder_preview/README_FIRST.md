# KurdLingo — Editable World Builder (Phase 2/3 + future phases)

**Goal:** see your School, Erbil Citadel, existing city, and future places *in Godot's editor*; move/rotate/resize their real meshes and colliders; add English–Sorani vocabulary points anywhere. No Codex required for installation.

## What is actually ready in this package

- A **one-time school scene baker** tailored to the `SchoolModule.gd` you uploaded. It serializes the current big school into `school/SchoolEditable.tscn` so walls, furniture, stairs, doors, NPC placeholders and vocabulary markers become selectable in the editor. The school script is patched to load those edited nodes instead of rebuilding duplicate geometry during gameplay.
- Compatibility with your already-generated `citadel/CitadelEditable.tscn` (from the previous Citadel converter). This package **does not delete or rebake it**, and does not overwrite its script. If your Citadel scene fails to open, stop before activation.
- The **existing original city** is already saved and editable as `scenes/editable_world.tscn`. This package does not rewrite or reorganize its 16,000+ nodes; that would risk the 1,000 existing gameplay references.
- A **WorldWordMarker.gd** node for vocabulary everywhere, with exported `word_id`, English, Sorani, example sentences and interaction radius visible in the Godot Inspector. It uses the existing canonical vocabulary/audio when a valid old ID is selected and a separate custom vocabulary file for truly new words.
- **14 editable starter location scenes:** Hospital, Supermarket, University, Library, Bakery, Police Station, Fire Station, Bank/Post Office, Zoo, Mountain Village, Forest/Waterfall, Desert Oasis, Beach/Harbor and Airport. They have low-poly starter layouts and learning markers. **They are prototypes only, not complete finished locations, NPCs or missions**, and they are not automatically added to your existing map.

**What this does not claim:** it does not finish every future location, draw production-quality architecture/characters, implement all AI conversations or mobile exports, or verify visuals/physics in your Godot 4.7.2 installation. This environment cannot run Godot; the converters must be run and checked on your PC.

## Safe installation (Windows 11, VS Code PowerShell; your current branch `codex/phase-0-audit`)

1. **Stop the game in Godot** (the editor can remain open). Keep a Git commit or backup of your current work. If Git shows uncommitted changes, commit those before you proceed. In particular, do not discard your existing `school`, `citadel` or scene edits.
2. Copy downloaded `KurdLingo_Editable_World_Builder.zip` to `C:\Users\musta\Documents\GitHub\Kurdlingo` (as you did for earlier ZIPs).
3. In that folder's VS Code PowerShell terminal, enter these commands **one at a time**:

```powershell
Expand-Archive ".\KurdLingo_Editable_World_Builder.zip" -DestinationPath ".\editable_preview"
python .\editable_preview\kit\tools\install_editable_world.py prepare
```

`prepare` verifies the uploaded school-script SHA before patching, copies reusable tooling, makes backups of the **school script and main game script**, then adds a generic vocabulary hub without removing any current school/Citadel hooks. It refuses unexpected versions or differing preexisting files.

4. **With the Godot editor running, but the game stopped**, bake the school and create optional starter places:

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\Run_Editable_Builders_Windows.ps1"
```

This uses your actual Windows Godot 4.7 executable to make `res://school/SchoolEditable.tscn` and `res://modules_editable/*.tscn`. It does **not** activate the school or overwrite the original city's scene. If Godot shows an error, **STOP and send the full terminal screenshot. Do not activate.**

5. In Godot, in **FileSystem**, double-click `school/SchoolEditable.tscn` and `citadel/CitadelEditable.tscn`. Select walls, classroom objects, school doors, Kurdish houses and roof nodes in the Scene tree. Confirm they appear in the 3D viewport. **Keep your saved edits modest while testing.**
6. **Only after both scenes open**, activate each one (one command at a time):

```powershell
python .\editable_preview\kit\tools\install_editable_world.py activate-school
python .\editable_preview\kit\tools\install_editable_world.py activate-citadel
```

7. **To also see both locations in the MAIN editor map (your screenshot):** first verify the separate scenes open and gameplay works. Then, stop the running game and enter:

```powershell
python .\editable_preview\kit\tools\show_both_in_main.py
```

This is the optional last step. It adds **SchoolEditable** and **CitadelEditable** as visible scene instances under `SoraniWorld` in `main.tscn` and changes `main.gd` to use those instances without creating any duplicates. It makes backups of `main.tscn`, `scripts/main.gd` and `citadel/CitadelModule.gd`. Reopen `main.tscn` in Godot and expand those two nodes in the Scene panel. For editing instance children, right-click the instance and choose **Editable Children**, or open their source `.tscn` directly.

8. In Godot, open `main.tscn`, press F5, press F8 then E to enter the school, and press F10 to travel to the Citadel. Test floors, school doors, roof hiding, E vocabulary, H heritage quests, F9 school missions and existing-city words. Do not commit to GitHub until the tests work.

If you have not yet completed the old Citadel converter's `prepare` / bake, the Citadel activation will be refused. That is intentional.

## Make anything editable

- **Existing city:** open `scenes/editable_world.tscn` directly. The root-level saved nodes can be moved; always move the parent Node3D, not just its mesh, so collisions follow. Do not remove existing `world_id`, `world_role`, `world_key` or `word_id` metadata.
- **School:** open `school/SchoolEditable.tscn`. Move objects under `KurdLingoSchoolCampus_126x104`. `LearningPoint_*` children are Inspector-editable vocabulary markers.
- **Citadel:** open `citadel/CitadelEditable.tscn`. Expand named traditional houses, Bazaar etc. Existing `LearningPoint_*` markers preserve native Citadel interactions. To add new vocabulary anywhere, add the new `WorldWordMarker.gd` marker described below.
- **New location template:** open a scene in `modules_editable`; use Godot's Scene tree to change furniture, rooms, colours, props. Drag the scene into `main.tscn` when ready, move it to an unobstructed location and connect it to your city paths. Do not put huge starter locations on occupied lots.

## Add English + Kurdish Sorani vocabulary **anywhere**

1. In Godot, select a wall, object, furniture or any `Node3D` in any editable scene.
2. Right-click that object in the **Scene** panel, choose **Add Child Node** → **Marker3D**. Rename it `LearningPoint_MyWord`.
3. In **Inspector**, attach `res://learn/WorldWordMarker.gd` to that Marker3D.
4. Enter either an existing **word_id** such as `book`, `tea`, `carpet`, `school`, or `gate`, **or** type a new ID into `learn/custom_words.json` and choose that ID in the Inspector. Optional fields: English, Sorani, English/Sorani example sentences, distance.
5. Move the Marker3D so its gizmo is near where the player can stand. Save the scene and run the game.
6. Walk near the marker and press **E**. Existing word IDs use the original English/Sorani pronunciation/audio. New words display a card and use audio files only if you provide valid paths in `learn/custom_words.json`.

**Important:** New Sorani translations are NOT automatically generated. Enter your reviewed Kurdish translation in the marker or `custom_words.json`. The example custom word deliberately has a blank translation.

## Reversibility and avoiding damage

- The installer creates `scripts/main.gd.before_editable_world` and `school/SchoolModule.gd.before_editable_world` before the initial integration. Activation creates separate main-script backups.
- Neither generator writes `scenes/editable_world.tscn`. Never run `tools/generate_editor_world.gd` against the saved city.
- The school's original `SchoolModule.tscn` and the Citadel's original `CitadelModule.tscn` remain untouched.
- The generators **refuse to overwrite** any existing editable `.tscn` so your editor changes are protected.
- If new files differ from existing files, installation stops rather than replacing your edits.
- New custom vocabulary progress is stored separately at `user://kurdlingo_custom_words_progress.json` and does not renumber the original 1,000 entries or delete any audio.
- Use `git diff` or Source Control to review all changes. **Do not blindly reset your repo or paste destructive delete commands.**

## Check status

```powershell
python .\editable_preview\kit\tools\install_editable_world.py status
```

## Limitations for later phases

The 14 editable starter scenes are **not automatically positioned**, because there is no verified free-space survey of your local edited world and some would extend beyond existing player/map bounds. They are ready for visual editing in Godot; adding roads, missions, AI NPCs, full accurate objects, city connections, terrain expansion, storylines, mobile support and performance testing remains additional work. Completing all those safely in one batch without testing would risk your 2 GB project and shared Git branch.
