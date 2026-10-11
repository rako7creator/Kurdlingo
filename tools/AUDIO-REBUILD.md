# Optional audio generation

All audio required to play or edit the game is already included. Generation is an optional development step; it is not part of the game runtime.

## Podcasts

Install the official Chatterbox Turbo package and dependencies in a separate Python environment. Download the official MIT-licensed ResembleAI/chatterbox-turbo checkpoint files to a folder outside the repository. This model needs several GB of memory; CUDA is recommended for rebuilding all ten long episodes.

Run from the project root:

```sh
python tools/generate_expressive_podcasts.py --model-dir /path/to/chatterbox-turbo --device cuda
```

The script generates short spoken turns with two included synthetic reference WAVs, saves a backup of the current episodes/audio in .audio-work/, caches finished chunks, recomputes caption timing and episode durations, then replaces the generated podcast audio and data when all ten episodes finish. Generated audio keeps Chatterbox's watermark. If you edit transcripts after a generation attempt, remove the corresponding cached paragraph/chunk files before resuming; do not reuse stale speech.

## School English words

Install Piper and ONNX Runtime in a separate environment. Download the Piper en_US-ljspeech-high ONNX model and its matching .onnx.json configuration outside the repository, then run:

```sh
python tools/generate_school_english.py --voice /path/to/english-ljspeech.onnx
```

Existing clips are skipped. Remove only the clip you intend to regenerate after a text change.

## School Sorani words

The included PCM WAVs use the published Central Kurdish F5 audiobook model with its matching config, vocabulary and speaker prompt. Model weights are not included. Follow the model author's published inference setup and the restrictions in licenses/Sorani-F5-model-README.md. Use ASOSoft normalization/G2P and the existing voice-review instructions. Preserve assets/audio/ckb/water.wav, which contains the user's approved ئاو pronunciation. Native-speaker review is required for new pronunciations.

## Reimport

After changing audio, let Godot reimport the WAVs and run the game/self-test before exporting. JSON contains live transcripts; CSV review copies do not directly change playback.
