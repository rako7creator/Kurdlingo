# Vocabulary ID examples

Existing IDs confirmed in the public KurdLingo `data/vocabulary.json`: `book`, `carpet`, `tea`, `coffee`, `gate`, `chair`, `table`, `door`, `window`, `stairs`, `school`, `fountain`, `basket`, `house`, `lamp`, `plate`, `cup`, `spoon`, `daily_teapot`, `daily_museum_ticket`, `computer`, `desk`.

## Existing words

Click a learning Marker3D, set `word_id = carpet`, leave `english_override` empty, save. Press E next to it: the hub delegates to your game's original `inspect_word("carpet")`, which reuses existing Sorani and audio recordings without adding another vocabulary entry.

## New word (example)

`learn/custom_words.json` contains `custom_example_carpet_pattern` with a blank Sorani translation (pending review). Set marker `word_id` to this ID, fill translation and examples in either marker overrides or the custom JSON, save. Press E near it to open a new bilingual card. For English/Sorani audio, add a permitted `res://...wav` path to `audio_en`/`audio_ckb` and ensure the audio files exist. This custom vocabulary does not modify the original game's 1000 IDs or its statistics. The examples are illustrative; translations must be checked before publication.

## One caveat

The original city's `editable_world.tscn` includes legacy `word_id` references under persistent metadata. **Do not copy old learning objects with their existing IDs and assume it creates a new concept.** Add a `WorldWordMarker` to an original or new scene for new learning points instead.
