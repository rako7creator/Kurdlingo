# KurdLingo Phase 1 — completed, awaiting Phase 2 approval

Work stayed on `codex/phase-0-audit`. The initial working tree was clean.
Checkpoint: Git tag `phase1-baseline-cd422e7` at `cd422e7`.
An isolated copy and original SHA-256 manifest are retained under ignored
`build/phase1/`. Implementation changes remain uncommitted; nothing was merged.
No separate master development specification was found in the project folder;
this phase followed the explicitly authorised Phase 1 requirements.

## Changes

| File | Change |
| --- | --- |
| `scenes/editable_world.tscn` | Added UUID and role/key/collision metadata only. No original scene data, transforms, node order, geometry, or resources changed. |
| `data/world_legacy_bindings.json` | Frozen migration map from the checkpoint's actual word, NPC and seat references; supports older scene copies without running a generator. |
| `scripts/world_editor_layout.gd` | Binds directly to persistent saved identities; rejects duplicate/missing bindings; installs selective movement blockers. Reserves anonymous saved node names in memory to prevent runtime name collisions and shutdown leaks. |
| `scripts/main.gd` | Loads the saved world directly without building/discarding another city; uses checked progress storage; retains the existing FPS cap; adapts the existing instance-count check to saved batches. |
| `scripts/teacher_circle.gd` | Stops forcibly relocating the named bench; respects editor and user-save placements. |
| `scripts/progress_store.gd` | Checks staged writes, backup creation and replacement; retains previous valid `.bak`; recovers corrupt/missing primary saves from that backup. |
| `tools/verify_phase1.gd` | Binding reorder/index corruption, legacy fallback, duplicate/missing identity rejection, collision and save-failure/recovery tests. |
| `tools/verify_phase1_preservation.py` | Verifies original file hashes and metadata-only scene migration. |
| `tools/phase1_preservation.json` | Portable checkpoint hashes for original assets, data and scenes. |
| `tools/run_phase1_checks.py` | Creates/reuses a safe isolated test copy, separates user data, preserves copied editor cache, and runs parse/import, regression and gameplay checks. Rejects unexpected errors. |
| `EDITING-WORLD.md` | Documents persistent IDs, safe duplication, legacy fallback, collisions and isolated testing. |
| `PHASE1-REPORT.md` | This report. |

The city has 4,525 persistent top-level identities. Gameplay binding covers
1,000 words, 20 guardians, 20 rescue cells and 61 decorative seats, plus the
two existing vocabulary seats: 63 walking seats in total.

Existing building blockers now block walking: 19 existing colliders reused.
400 existing trees and 62 streetlights receive simple trunk/pole colliders;
their broad camera blockers remain. Small decorations and flower petals were
not given individual colliders. Physics tests verified movement-layer ray hits
and character-capsule blocking on representative buildings, trees and poles.

Save version 3, vocabulary IDs, progress keys, missions, options and object-layout
format remain compatible. A failed replacement reports a warning and leaves
staged `.tmp` data available instead of silently discarding it.

## Verification

Tested with installed Godot 4.7.2. All game launches used isolated project copies
with separate custom user-data directories. Existing personal saves were not
loaded or written. The city generator was not executed.

- Original baseline integrated gameplay self-test: PASS.
- Final clean-session editor parse/import: PASS, exit 0, no unexpected errors.
- Final Phase 1 regression suite: PASS, exit 0. It reverses saved node order and
  replaces numeric indices with -1 while checking every vocabulary reference
  and transform. It also verifies legacy binding, error rejection and save
  recovery/failed replacement. Deliberate negative tests emit expected errors.
- Final integrated gameplay self-test: PASS, exit 0, no runtime/shutdown errors.
  Covers vocabulary/audio, drag/drop/reset, quizzes, progress, guardians,
  sentence missions, teacher narration, sitting, jetpack, scooter and podcasts.
- Preservation: PASS. All 8,844 original files remain; all unchanged files match
  their checkpoint hashes. Removing only added metadata from the saved scene
  reproduces its original byte hash. All original vocabulary/data/audio/models
  are unchanged.
- `git diff --check`: PASS.
- Two comparable headless scene-load-plus-ready runs: baseline 8.035/7.900 s;
  candidate 6.477/7.010 s. About 15% faster on average in these samples.
  These are startup measurements, not GPU frame-rate or visual-quality results.

Final combined test logs:
`build/phase1/phase1-results-abb11ed73b79429a96ff365c3f937680/`.

Repeat safely:

```powershell
python tools/run_phase1_checks.py --godot 'C:/path/to/godot_console.exe'
```

The runner creates a new ignored test copy and unique user-data directory.
It does not invoke the generator, export, delete files, or write Git metadata.

## Remaining risks and manual checks

The original saved scene contains 34 MultiMesh flower batches with zero-filled
buffers. Reopening both saved scenes through the copied old editor session also
produced MultiMesh transform/color reload errors in the unchanged baseline.
A fresh isolated editor session parses/imports cleanly. These existing buffers
were preserved exactly; no flower geometry was regenerated. Instance-count
checks do not establish that those flower batches are visible.

Legacy fallback is for historical indexed scene copies. New editing should keep
the persistent metadata; copied objects require fresh UUIDs. Duplicate learning
identities are rejected explicitly rather than arbitrarily choosing a copy.

Save-failure testing uses a blocked destination directory; it does not simulate
power loss, full disks or every Windows file-lock condition. A retained `.tmp`
after failure may need manual recovery. `.bak` holds the previous valid save,
not necessarily the most recent interrupted session.

In Godot, preferably using an isolated test copy first:

1. Open `main.tscn`, run F5, and confirm the city, lighting, flag and object
   placements match the editor. Check flower borders visually; record any
   MultiMesh errors rather than regenerating the world.
2. Walk against skyline buildings and tree trunks; confirm foliage remains
   passable and routes, curbs and the bridge remain usable. Check camera
   behaviour while walking, riding and flying near these obstacles.
3. Inspect several words in different districts; test a guardian, story mission,
   pickup/drop/reset, teacher chair and podcast sofa.
4. Check the story-circle bench/pupil spacing. The bench now honours its saved
   scene/user placement instead of the previous forced runtime relocation.
5. In the isolated copy, save progress and move an object, quit, reopen, and
   confirm both persist. Inspect the `.bak` alongside the test save.
6. Confirm the debugger has no new errors during play and normal shutdown.

The existing city was not rebuilt, replaced or deleted. All 1,000 vocabulary
entries and all original English/Sorani recordings are preserved. No Citadel,
school expansion or unrelated gameplay redesign was added. Phase 2 has not
started and requires approval.
