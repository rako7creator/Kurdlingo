---
license: cc-by-nc-4.0
language: [ckb]
pipeline_tag: text-to-speech
library_name: piper
pretty_name: Vekol Piper edge (ckb)
tags: [kurdish, sorani, central-kurdish, ckb, tts, text-to-speech, speech, piper, vits, onnx, edge]
---
# Vekol Piper edge (ckb)
Piper (VITS) 22.05 kHz ONNX edge model for Central Kurdish (Sorani). Runs on CPU / edge devices.

By Revge / Vekol ( ڕێڤگە / ڤەکۆڵ ).

## Training data
Resumed from a Central Kurdish base, then trained on the Vekol voice plus teacher-distilled audio, with weak-letter balanced oversampling.

| Stage | Data | Hours | Clips |
|---|---|---|---|
| Base | DB1 + DB2 (Central Kurdish corpora) | 27.33 h | 11,694 |
| Fine-tune — real | Vekol voice | ~59 min | 397 sentences |
| Fine-tune — distilled | teacher (Vekol) | ~3 h | ~1,500 |

Weak letters (گ ڤ ح غ) are oversampled ×2; long-text tail-hallucination fixed in inference.

## Usage
`model.onnx` + `model.onnx.json` with the Piper runtime, or the included `vekol_tts.py` helper.
