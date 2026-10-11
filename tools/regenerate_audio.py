"""Optional English-only developer tool. Sorani uses F5-TTS; see regenerate_sorani.py. Install piper-tts in a separate Python environment.

Run with: python tools/regenerate_audio.py --models path/to/model/folder
Models are development inputs, not part of the shipped runtime.
Sorani audio is noncommercial-only; see THIRD-PARTY-NOTICES.md.
"""
from pathlib import Path
import argparse, json, wave
from piper import PiperVoice, SynthesisConfig

parser = argparse.ArgumentParser()
parser.add_argument('--models', type=Path, required=True)
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
entries = json.loads((project/'data/vocabulary.json').read_text(encoding='utf8'))
for language, filename in [('en','english-ljspeech.onnx')]:
    model = args.models/filename
    if not model.exists():
        raise SystemExit(f'Missing {model}. Model URLs and licenses are in the notices.')
    voice = PiperVoice.load(str(model))
    config = SynthesisConfig(speaker_id=0, length_scale=1.04,
                             noise_scale=0.55, noise_w_scale=0.65)
    folder = project/'assets/audio'/language
    folder.mkdir(parents=True, exist_ok=True)
    for entry in entries:
        with wave.open(str(folder/(entry['id']+'.wav')), 'wb') as wav:
            voice.synthesize_wav(entry[language]+'.', wav, syn_config=config)
    print(language, len(entries), 'recordings generated')
