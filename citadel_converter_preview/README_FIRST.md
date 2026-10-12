# KurdLingo — Erbil Citadel: make buildings editable inside Godot

This package was tailored to your uploaded **CitadelModule.gd** (25 KB).

## Why the editor scene looked empty
Your script creates all structures inside `_ready()` when the game starts. The `.tscn` currently contains only the `ErbilCitadel` root. This converter invokes the SAME building functions once in Godot's runtime and **saves their actual meshes, collisions, house groups and Marker3D vocabulary points** to a new `.tscn` file.

## What you gain
- `citadel/CitadelEditable.tscn` — open in the Godot 3D editor, expand traditional house nodes, move walls, stairs, roofs, bazaars, furniture, etc.
- A saved copy of the mound, grand gate, 12 houses, museum, bazaar, tea house, courtyards and details.
- Interaction markers saved as children of each local building; moving markers with objects preserves proximity interactions.
- The roof-hiding gameplay, guide UI, heritage missions, existing 1,000 word IDs, existing recordings, existing School V2 and original city remain in place.

## Before installing
1. Be on your KurdLingo Git branch `codex/phase-0-audit`.
2. Back up/commit your current working School and Citadel changes. `git status` tells you whether they are committed. Don't overwrite unrelated edits.
3. This tool will refuse to alter `citadel/CitadelModule.gd` if it is not **exactly** the version you uploaded in chat. If changed, send the current file for a new converter.

## Install / convert in Windows VS Code terminal (PowerShell)
Assumes ZIP was downloaded to Windows Downloads folder, and your terminal is already in `C:\Users\musta\Documents\GitHub\Kurdlingo`.

```powershell
Copy-Item "$env:USERPROFILE\Downloads\KurdLingo_Citadel_Editable_Converter.zip" .
Expand-Archive ".\KurdLingo_Citadel_Editable_Converter.zip" -DestinationPath ".\citadel_editable_preview"
python .\citadel_editable_preview\install_citadel_editable.py prepare
```

`prepare` backs up the original `CitadelModule.gd`, installs a patched script that can load baked geometry without duplicating it, and installs the Godot baker. Your running game still uses the original scene at this point.

While the Godot editor is open, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\citadel_editable_preview\run_bake_windows.ps1
```

The script locates your running Godot application and starts Godot headless to generate `citadel/CitadelEditable.tscn`. **This can take time and produce a large text scene; do not stop it mid-run.** If the Godot executable isn't detected, use the `-GodotExe` argument as described in the error.

Then open Godot and double-click `citadel/CitadelEditable.tscn` in FileSystem. Expand `KurdishTraditionalHouse_00`, `HistoricBazaar`, etc. The architecture should now be selectable in 3D even before playing.

**ONLY after verifying the editable scene**, activate it:

```powershell
python .\citadel_editable_preview\install_citadel_editable.py activate
```

Reopen `main.tscn` in Godot, press F5, press F10 to travel to the Citadel. Test E interactions and H heritage missions. The source scene and original scripts remain backed up, and existing city and School V2 remain unchanged.

## Revert (if something doesn't work)
```powershell
python .\citadel_editable_preview\install_citadel_editable.py revert
```

This restores the original runtime Citadel scene path and original `CitadelModule.gd` only if they have not been independently edited since installation. It intentionally leaves `CitadelEditable.tscn` and backups intact.

## Important notes
- This is a converter, **not a redesign**. The baked Citadel should match its previously procedural version, not turn automatically into high-quality external 3D models.
- The Citadel's geometry is authored as editable MeshInstance3D + StaticBody3D + CollisionShape3D nodes, grouped by house/area. It remains resource-intensive; don't duplicate thousands of nodes indiscriminately.
- Some procedural props are initially called `CitadelBox` / `CitadelRound`, under named buildings. Rename any you edit as desired. Keep the `LearningPoint_*` nodes for interactions.
- Because no Godot 4.7 executable is installed in this ChatGPT environment, the conversion has not been run here; test Godot's reported result and capture errors if any.
- Godot's root movement saved in `CitadelEditable.tscn` is preserved on play. Some roof parts are dynamically hidden while indoors; do not delete their baked metadata if you want roof hiding to continue.
- Conversion does not touch or regenerate `scenes/editable_world.tscn`.
