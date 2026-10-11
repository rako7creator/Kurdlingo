# Speech development tools

The game already contains all recordings and never runs these tools. Rebuilding speech is optional and needs a separate Python environment and CUDA-enabled PyTorch. Use the model's noncommercial terms and published matching reference speaker.

English: install `piper-tts` and obtain `en_US-ljspeech-high.onnx` plus its matching JSON configuration. Run `python tools/regenerate_audio.py --models <folder>`; it regenerates English only.

Sorani: install `f5-tts`, `asosoft`, `pyyaml`, `soundfile` and CUDA-compatible `torch`/`torchaudio` in a separate environment. Download these files from https://huggingface.co/aranemini/central-kurdish-tts into one model directory:

- model-audiobook-female.pt
- F5TTS_v1_Base.yaml
- vocab.txt
- prompt-audiobook-female.wav
- prompt-audiobook-female.txt

Run `python tools/regenerate_sorani.py --model-dir <folder> --force`. The first run fetches the Vocos vocoder and creates a local inference cache to avoid loading training optimizer state into GPU memory. Neither original nor cached model weights are part of this project or licensed for modified redistribution. Optional training/UI dependencies of F5-TTS are not used by this script. Use the official package installation instructions if its Windows dependencies require setup.

`data/pronunciation-overrides.json` contains the user's approved water correction. Each other word is normalized by ASOSoft Kurdish G2P. Generation uses deterministic seeds and 32 diffusion steps; water uses 48. Recorded output is 24kHz / 16-bit PCM, without pitch shift or time stretching.

Prefer consenting native human recordings for final pronunciation accuracy. Put a WAV at `recordings/ckb/<word_id>.wav` beside the exported executable to replace one word immediately without building or running a speech model.
