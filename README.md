# KurdLingo 0.9 — school and city learning adventure

Extract the Windows ZIP and open KurdLingo.exe. No engine installation, internet connection or speech service is needed to play.

There are 1,124 English–Sorani vocabulary entries across 21 districts. The existing 1,000 words, teacher's 17 stories and sentence missions remain available.

## New school

The academy stands east (right) of the Discovery / cosmos area. Use M > School to travel to its garden, or follow the connected school road. Walk through the wide central entrance and enter the eight named rooms: Library, English classroom, Science laboratory, Computer laboratory, Administration, Teachers room, Art and music, and Cafeteria and wellbeing. The central hall has indoor garden trees, benches, student art and display objects. The building has a clock tower, pitched roofs, stone masonry, textured timber counters and tile floors. Roof cutaway and camera collision preserve the indoor view; rooms still have visible ceilings.

124 school vocabulary entries (107 English terms new to the overall catalog) are placed on working desks, counters and furniture, with recognizable original stylized models and Kenney props at human scale. Every new word has English and Sorani pronunciation. Press E or click a nearby object to learn it; the journal and school guardian support practice. Small objects retain drag-and-drop interaction.

## One podcast studio by the flag

The former ten studio sets have been replaced by one shared studio south of the flag. Podcast Plaza fast travel now arrives beside this studio. Its 50 media vocabulary objects are in the compact adjoining learning area.

Press E beside the sofa to sit and choose any of the ten long episodes. The hosts use two expressive Chatterbox Turbo synthesized voice identities, with conversational pauses and occasional chuckles. The recordings retain the model's watermark. These are generated voices, not live human podcast recordings. Sorani subtitles and an English line follow the conversation; sentence cue timing is estimated within short generated chunks. Pause, replay, choose another episode, stop, stand up, and continue listening while walking. Settings provides separate podcast and music volume.

## Travel controls

- WASD / arrows: walk or steer. Shift: run.
- F: unfold or fold the scooter on the ground.
- Space while riding: jump without dismounting.
- Shift while riding: faster boost, with a rechargeable battery, mint trail and camera effect.
- Hold Space while walking: use the jetpack. F dismounts the scooter first.
- Right mouse drag: turn the camera; mouse wheel: zoom.
- E: nearby word, teacher, chair, or studio interaction.
- M: map and fast travel. P: podcast selection. T: sentence story missions.
- J: journal. Q: practice. Settings: volume, display scale, moved-object reset.

16 moving citizens use town, school corridor and entrance-garden routes. They animate their footsteps and wait near the player.

## Editing and language review

The editable source ZIP is a Godot 4.7.2 project containing scripts, models, all generated audio and bilingual JSON data. Open project.godot, allow imports to finish, then press F5. Install matching export templates to make another Windows build. Git LFS is configured for large audio/model/font files.

data/vocabulary.json is the live vocabulary catalog. Vocabulary-review.csv includes all words; KurdLingo-School-Review.csv isolates the 124 school additions. CSVs are review copies. Text changes also require replacing the matching pronunciation WAV. data/podcasts.json contains the episode transcripts and cues.

The Sorani additions and pronunciation remain drafts for native-speaker review. The user's selected pronunciation of ئاو is preserved. See LICENSE.txt and THIRD-PARTY-NOTICES.md for the noncommercial Sorani voice terms and third-party credits.

Local progress is carried into the new PC build. The shareable ZIP contains no personal save.
