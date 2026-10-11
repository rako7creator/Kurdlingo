# Third-party notices and provenance

## Earthlingo reference

This game is independently implemented. No Earthlingo source code, extracted game data, artwork, maps, character models, music, or recordings are included.

Research references:

- [Official Steam description](https://store.steampowered.com/app/1071240/Earthlingo/)
- [Official website](https://earthlingo.io/)
- [Official teaser, visually inspected](https://www.youtube.com/watch?v=bz1TXjvv7XM)
- [Developer's gameplay updates](https://steamcommunity.com/app/1071240/allnews/)
- [Developer's 2020 explanation that purchased models/code prevented opening the source](https://www.reddit.com/r/LearnJapanese/comments/en301d/)

Reference observations: third-person alien/jetpack exploration, low-poly town and household objects, object-associated vocabulary, audio pronunciation, word cards, retention challenges, and robot/human rescue objectives. The reference materials are not licensed assets in this project.

## Godot Engine

Godot 4.7.2 official Windows runtime, MIT license. [Godot license and third-party notices](https://godotengine.org/license/). The Windows executable includes the official release export template.

## Kenney 3D models

Kenney's Creative Commons Zero (CC0) models:

- [City Kit (Suburban)](https://kenney.nl/assets/city-kit-suburban)
- [City Kit (Commercial)](https://kenney.nl/assets/city-kit-commercial)
- [Furniture Kit](https://kenney.nl/assets/furniture-kit)
- [Food Kit](https://kenney.nl/assets/food-kit)
- [Nature Kit](https://kenney.nl/assets/nature-kit)
- [Car Kit](https://kenney.nl/assets/car-kit)

Pack license texts are retained in `licenses/`. Some city materials are tinted for this game. The alien, people, robot, and `custom/*` / `new/*` props are original procedural meshes.

## Fonts

Noto Sans and Noto Sans Arabic, SIL Open Font License 1.1. [Google Fonts sources](https://github.com/google/fonts). The font license is included in `licenses/`.

## Sorani synthesized speech

Model: [aranemini/central-kurdish-tts](https://huggingface.co/aranemini/central-kurdish-tts), `model-audiobook-female.pt`, F5-TTS native Central Kurdish (Sorani) female audiobook speaker. Published reference audio and transcript were used with ASOSoft normalization and Kurdish G2P. No unrelated speaker's voice was supplied. The authors state that narrators permitted research use of their recordings and voices.

Authors: Mohammad Mohammadamini, Meysam Shamsi, Marie Tahon. “Central Kurdish Text-to-Speech and Its Application in Speech-to-Text Translation,” LREC 2026, pp. 664–673, DOI 10.63317/4hfwowidu34u. Work developed at LIUM, Le Mans University, and TTS4All / JSALT 2025. The complete model card, restrictions and citation are retained in `licenses/Sorani-F5-model-README.md`.

Model terms: **CC BY-NC-ND 4.0; noncommercial educational/research use only; no redistribution of modified weights.** This personal learning build is noncommercial. Model weights are not distributed, modified or otherwise; the game contains pre-generated audio. Seek separate rights or replace the voice before commercial publication.

Generation: F5-TTS 1.1.22, official matching model config/vocabulary, Vocos mel-24kHz vocoder, 32 inference steps, matching published speaker prompt, 24kHz 16-bit PCM. Audio edges are trimmed without time stretching or pitch shifting. `water.wav` uses the user's selected pronunciation B (`aw .`, 48 steps). Every other word remains unreviewed. Synthesized output is not a human actor's recording.

The prior Vekol voice is used only in the separately provided old/new comparison WAV; its retained attribution is Vekol / Revge, Darvan Shvan, CC BY-NC 4.0. It is no longer the game's default speech.

## Cozy soundtrack

Five tracks total about 17 minutes and repeat continuously. Tracks are licensed CC0 by their uploader:

- The Cynic Project / cynicmusic.com / pixelsphere.org: [Vaporware](https://opengameart.org/content/calm-piano-1-vaporware), [Lifewave 2k](https://opengameart.org/content/calm-ambient-3-lifewave-2k), [Another August](https://opengameart.org/content/another-august), [November Snow](https://opengameart.org/content/november-snow).
- Yoiyami: [First Light Particles](https://opengameart.org/content/first-light-particles-%E2%80%93-cc0-atmospheric-pianoambient-track).

Independent volume/mute and speech ducking are implemented by the game. Music source/license links are included in `licenses/Music-CC0.md`.

## English synthesized speech

Model: [Piper en_US-ljspeech-high](https://huggingface.co/rhasspy/piper-voices/tree/main/en/en_US/ljspeech/high). Single US English female voice trained from scratch on the [LJ Speech dataset](https://keithito.com/LJ-Speech-Dataset/), identified as public-domain data by the model card. The model card is included in `licenses/`. Each recording was generated from the English entry with sentence punctuation appended. The model weights are not shipped.

## Development synthesis tools

Piper 1.8.0 / OHF-Voice piper1-gpl (GPL-3.0) and ONNX Runtime were used offline during development. Their code and binary runtimes are not distributed with the game; only resulting audio files are included. [Piper source](https://github.com/OHF-Voice/piper1-gpl).

## Vocabulary

The bilingual catalog was authored for this project as a draft. It was not extracted from Earthlingo or claimed to be professionally reviewed. Every row's `reviewed` field starts as false. Review spelling, object associations, regional variants, and pronunciation before educational or public release.

## 0.8 additional assets and podcast voices

Kenney Train Kit, Watercraft Kit, Pirate Kit, Survival Kit and Space Kit assets are CC0; pack license texts are retained in licenses/. Subject-specific daily props, scooter and studio assembly are original procedural meshes.

Podcast conversations are original educational scripts, spoken by synthetic Piper LJ Speech and Lessac voices. The Lessac model card and its dataset/license links are included in licenses/English-podcast-guest-model-card.txt. These are synthesized voices, not recordings of live podcast hosts. Sorani subtitles are project-authored drafts requiring native-speaker review. Sentence cue times are estimated from word lengths within each recorded paragraph.
