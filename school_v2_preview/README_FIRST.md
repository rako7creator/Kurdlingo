# KurdLingo School V2 — much bigger, two-storey redesign

This upgrades the **earlier Phase 2 school kit** to resemble the large courtyard school concept you approved. It is a **candidate implementation**, not a verified in-game result. The repository's public branch `codex/phase-0-audit` was inspected, but the linked GitHub connector refused write access (HTTP 403), so **nothing has been committed or pushed for you**.

## What's improved in V2

- **126 x 104 game-unit school** (4 connected wings) on a **162 x 148 campus**; significantly larger than the previous ~32 x 28 box.
- Two floors with full-sized stairs (24 shallow risers each), open courtyard, entrance portico, roof trims, glass window openings, fences, trees, pathways and basketball areas.
- 16 school rooms, with 127 vocabulary object placements from the existing JSON, improved varied low-poly furniture shapes, 4 NPC placeholders, school conversations, 10 mission definitions and English/Sorani vocabulary-card integration.
- The first-floor walking surfaces are intentionally interrupted above the stair shafts.
- Roof visual is hidden while in the school to help third-person camera navigation. Collision roof remains.
- Old city, 1,000 canonical vocabulary IDs, audio paths and `editable_world.tscn` are **not** modified by the package itself.

## Upload to your GitHub Codespace

1. First, **save or commit your own uncommitted changes**, especially any existing school work, so they aren't lost. Stay on `codex/phase-0-audit`.
2. Download the ZIP from ChatGPT to your computer.
3. Open your GitHub Codespace at `https://zany-broccoli-g99wgw54vx7cw5w.github.dev/`.
4. Drag the ZIP into the VS Code Explorer inside the **Kurdlingo project root** (the folder containing `project.godot`).
5. Open the Codespace **Terminal** and run these commands:

```bash
unzip -o KurdLingo_School_V2_Design.zip -d .
python3 tools/apply_school_patch.py
```

6. The integration script makes a `.before_school_phase2` copy of `scripts/main.gd` **on first integration**. If the previous school kit is already integrated, it will say `School already appears integrated` and skip patching; the school files are already replaced by ZIP extraction.
7. Review **Source Control → Changes**. Confirm `scenes/editable_world.tscn` and `data/vocabulary.json` have not changed as a result of this kit.
8. Commit when satisfied; **do not merge into main** until Godot gameplay tests succeed.

## Run the school

1. Open `project.godot` in Godot 4.7.2, select `main.tscn` and press **F5**.
2. Start playing. Press **F8** (debug) to warp to the **existing original school gateway** near `(-57, 0, -68)`.
3. Press **E** near the gateway. You will appear in front of the big campus, with the school in view.
4. Walk to the main entrance at local +Z, enter reception, visit the courtyard and walk the two stair flights to level two.
5. **E** near doors, NPCs and classroom objects to interact. **F9** shows the school missions while inside.
6. To leave, press **E** near the main entrance hallway at campus coordinates around `(-70, 0, -173)`. This returns you to the original school gateway.

## Status and known limits

- **Godot 4.7.2 wasn't installed in the ChatGPT environment, so I couldn't run an engine parse or visualize actual gameplay.** The structural JSON/package checks passed, but actual doors, stairs, camera collisions and site overlaps still need testing.
- Some furniture is still simplified low-poly procedural geometry; the concept art is a design target, **not a guaranteed screenshot match**.
- Real glass panes are transparent visually; doors rotate on `E` but do not yet have animation/audio.
- Some object labels have no approved Sorani translation yet. These are marked pending; existing mapped words still use the original system's audio and XP.
- The new site is set to `(-70, 0, -215)` near the central/northern connection, **not** at the old small school coordinate. This allows a big building without deleting the original school object. Check the site's suitability before accepting its placement; other city objects may overlap.
- The older small school gate/model remains. The old tiny campus should no longer be used after replacing the V1 module files.
- Mobile optimisation, AI NPCs and detailed all-object gameplay are **not done**.

## Safety

No scene regeneration. The project and city belong to you and your collaborator. Do not run `tools/generate_editor_world.gd`, do not discard a friend's work, and do not move work onto `main` without both reviewing it.
