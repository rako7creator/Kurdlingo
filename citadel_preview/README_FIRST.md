# KurdLingo — Phase 3: Erbil Citadel (prototype)

This ZIP contains **actual Godot 4 scene and GDScript code** for an Erbil Citadel-inspired interactive place inside your existing KurdLingo world. No Codex or API key is required for installation.

**Phase 3 remains a prototype until you run it in Godot.** Its low-poly geometry, doors/openings, proportions, stair collisions, overlays and placement have NOT been tested in Godot here. Treat it as a first playable pass, not a detailed architectural reproduction of Erbil's UNESCO-listed Citadel.

## What is included

- Raised sandstone citadel mound (approx. 125-unit diameter), historic-looking wall circuit with grand entrance, broad steps, decorative arched gateway and signs in English/Sorani.
- 12 traditional courtyard-edge houses with open doorways, furnishings, woven-look carpets and flat roofs. Four have walkable upper levels and internal staircases.
- Covered traditional bazaar (8 stalls) with carpet, baskets, pottery and bread.
- Covered tea house, pottery exhibits, heritage museum and small central fountain/cultural flag square.
- A simple cultural guide with a scripted introductory conversation.
- Seven heritage objectives with XP and a separately stored progress file.
- Interactive objects wired to the **existing** `world.inspect_word(word_id)` cards and word recordings wherever canonical vocabulary IDs exist (e.g. carpet, tea, house, pot, basket, gate, stairs, teapot, lamp, bread, museum ticket).
- A safe integration patch that works alongside the **School V2** installation from this conversation.

## Installation on Windows (VS Code terminal / PowerShell)

Use the same project folder as before: `C:\Users\musta\Documents\GitHub\Kurdlingo`. Stay on your existing branch `codex/phase-0-audit`.

Before installing, close the running game, review your current changes (`git status`) and **keep your already installed school files**. Save a backup or Git commit of a known-working version before testing larger changes. Do not discard other people's edits.

1. Download `KurdLingo_Phase3_Erbil_Citadel.zip` to Windows Downloads.
2. In VS Code's PowerShell terminal, from the Kurdlingo project root, run the commands below, **one at a time**:

```powershell
Expand-Archive -Path "$env:USERPROFILE\Downloads\KurdLingo_Phase3_Erbil_Citadel.zip" -DestinationPath ".\citadel_v3_preview"
Copy-Item ".\citadel_v3_preview\citadel" ".\citadel" -Recurse
python ".\citadel_v3_preview\tools\apply_citadel_patch.py"
```

The ZIP contains `citadel/CitadelModule.gd` and `citadel/CitadelModule.tscn`. The installer automatically modifies `scripts/main.gd` **only after checking exact matching anchor lines** and makes the backup `scripts/main.gd.before_citadel_phase3` before doing so. It does not edit `scenes/editable_world.tscn`, `data/vocabulary.json`, existing music/audio, `main.tscn`, `project.godot`, or your installed `school/` directory.

If the installer prints `ERROR`, **stop** and show the message. Do not improvise edits to `main.gd`.

## Playtest

1. Open Godot with the Kurdlingo project and press **F5**.
2. Start your current game normally.
3. Press **F10** to teleport to the Citadel's approach stairs. You can also walk there directly because the Citadel is part of the same continuous world. Current site origin is (-235, 0, -167), northwest of Town toward History Museum, deliberately away from School V2 at (-70, 0, -215). This placement needs visual clearance checks.
4. Walk up the grand stairs to the raised terrace. Walk through the main gateway; enter houses, bazaar and museum without changing scenes.
5. Press **E** near a heritage object or the guide to inspect or talk. Press **H** near the Citadel to see objectives. Press **F10** again to return to where you started. **F8 and F9 remain School V2 shortcuts.**
6. Verify the existing town, original vocabulary, school gate/interior and saved progress still work. Check the Godot Debugger output for parser errors and any player/camera collisions.
7. If something is missing/blocked, please send a screenshot of the Godot **Debugger** errors and an in-game screenshot.

## Roadmap and known limitations

- The prototype uses hand-authored low-poly meshes, not licensed/downloaded Erbil asset packs. Expect to polish architectural accuracy and add distinctive arches, motifs, rugs, Kurdish clothing, historic details, roof access and true player-to-NPC conversation after playtesting.
- Decorative windows use blue panels on facades, not transparent window cutouts. Houses have open doorways. No animated doors or object pickup/drop interactions have been implemented for the new heritage objects.
- The museum roof does not yet automatically hide for third-person camera; inspect access and camera visibility. No AI API or live AI dialogue is built.
- Heritage objectives are interaction-triggered, not sophisticated object-action puzzles. Sorani labels and existing recordings are reused only from the established data; **no new translations or audio** were invented.
- The original Erbil Citadel located in the History Museum is left untouched; this module adds a much larger walkable Citadel elsewhere in the same city.
- With a large existing city plus School V2, performance and exact placement will need checking. Adjust only the `SITE` constant inside `citadel/CitadelModule.gd` if there is a collision with another landmark, after agreeing on the placement.
- Protect personal saves: the test will update live saves. For high-confidence save testing, use an isolated copy or back up your save directory first.
- **Do not run `tools/generate_editor_world.gd` against `scenes/editable_world.tscn`**; it overwrites the edited saved city scene.
- The package has passed only offline content/patching checks (run `python .\citadel_v3_preview\tools\validate_citadel_kit.py`). **Godot import, runtime and visible quality are unverified.**

## Undoing the install (if necessary)

1. Close Godot. Keep a backup of your current `scripts/main.gd` before doing further changes.
2. Restore `scripts/main.gd` from `scripts/main.gd.before_citadel_phase3` **only if there have been no other edits after installing Phase 3**.
3. Remove or temporarily rename the added `citadel` folder. Leave `school/` and `editable_world.tscn` alone.

Nothing was merged into `main`, and the GitHub repo was **not** updated from this chat; GitHub denied write permission. The ZIP is delivered to you for local installation.
