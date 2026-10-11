---
language:
- ckb
license: cc-by-nc-nd-4.0
library_name: f5-tts
tags:
- text-to-speech
- tts
- kurdish
- central-kurdish
- sorani
- speech-synthesis
- low-resource
- f5-tts
---

# F5-TTS Central Kurdish

This repository contains three **Central Kurdish (Sorani Kurdish) Text-to-Speech (TTS)** models based on the **F5-TTS** architecture. The models were developed to provide high-quality speech synthesis for a low-resource language and support applications such as speech generation, voice cloning, speech translation, and data augmentation.

The models were developed within the **TTS4All initiative at the JSALT 2025 workshop**, whose objective is to facilitate the rapid development of speech synthesis systems for low-resource languages using publicly available resources.

The repository includes three single-speaker F5-TTS models trained on different datasets and speaking styles.

## Available Models

| Model | Speaker | Training Data | Duration |
|---------|---------|---------|---------|
| **audiobook-F** (`model-audiobook-female.pt`) | Female | Audiobook recordings | 10h54m |
| **audiobook-M** (`model-audiobook-male.pt`) | Male | Audiobook recordings | 10h51m |
| **studio-M** (`model-studio-male.pt`) | Male | Studio-recorded speech | 13h35m |

### audiobook-F (Female)

A female voice trained on audiobook recordings narrated by a native Central Kurdish speaker. This model achieved the highest overall subjective quality among the evaluated systems and provides highly natural speech synthesis suitable for general-purpose applications.

### audiobook-M (Male)

A male voice trained on audiobook recordings from a different speaker and domain. The model provides natural speech synthesis while preserving the speaking style and prosody found in audiobook narration.

### studio-M (Male)

A male voice trained on professionally recorded studio speech from the Giganet dataset. This model achieved the highest objective signal-quality metrics and is particularly suitable for applications requiring very clean speech generation.

## Evaluation

The models were evaluated using both objective and subjective metrics on multiple Central Kurdish speech synthesis scenarios, including in-domain text, code-switching, news, expressions and idioms, and prosodic variability.

### Subjective Evaluation (MOS)

A Mean Opinion Score (MOS) evaluation was conducted with 88 native speakers and 3,101 ratings.

| System | Natural Speech MOS | TTS MOS |
|----------|----------|----------|
| audiobook-F | **4.42** | **4.08** |
| audiobook-M | 4.34 | 4.01 |
| studio-M | 4.40 | 4.06 |

The audiobook-F model achieved the highest overall subjective score among the evaluated Central Kurdish TTS systems.

### Objective Evaluation

| Model | Predicted MOS | DF | Average CER |
|----------|----------|----------|----------|
| audiobook-F | ~4.36 | ~0.99 | ~3.7% |
| audiobook-M | ~4.38 | ~0.95 | ~4.7% |
| studio-M | ~4.43 | ~0.92 | ~5.6% |

All models maintain strong intelligibility and naturalness while achieving very low recognition error rates.

### Downstream Speech Translation

The models were also used to generate synthetic speech for training Central Kurdish → English speech translation systems.

Using synthetic speech generated from the three voices, a Whisper Large V3 speech translation model achieved:

| Evaluation Set | BLEU |
|----------|----------|
| Asosoft | 27.23 |
| FLEURS | 18.50 |

These results demonstrate the usefulness of the developed TTS models beyond speech synthesis, particularly for developing speech technologies in low-resource languages.

## Usage

Each model can be used with the provided `infer.py` script together with the corresponding prompt audio and prompt transcription files. Example prompt recordings and generated outputs are included in the repository for reproducibility and demonstration purposes.

## License

This repository is released under the **CC BY-NC-ND 4.0** license.

### Restrictions

- Commercial use is **strictly prohibited**.
- The models may only be used for research, educational, and other non-commercial purposes.
- Redistribution of modified versions is not permitted under the license terms.
- Users must comply with the license conditions of the accompanying datasets and resources.

## Citation

If you use these models, datasets, or any accompanying resources in your research, please cite:

```bibtex
@inproceedings{mohammadamini-etal-2026-central,
  title = {Central Kurdish Text-to-Speech and Its Application in Speech-to-Text Translation},
  author = {Mohammadamini, Mohammad and Shamsi, Meysam and Tahon, Marie},
  booktitle = {Proceedings of the Fifteenth Language Resources and Evaluation Conference (LREC 2026)},
  month = {May},
  year = {2026},
  pages = {664--673},
  address = {Palma, Mallorca, Spain},
  publisher = {European Language Resources Association (ELRA)},
  editor = {Piperidis, Stelios and Bel, Núria and van den Heuvel, Henk and Ide, Nancy and Krek, Simon and Toral, Antonio},
  doi = {10.63317/4hfwowidu34u}
}
```

```bibtex
@inproceedings{mohammadamini2026iwslt,
  title        = {LIUM Submission for IWSLT 2026 Low-Resource Speech Translation Track},
  author       = {Mohammad Mohammadamini and Marie Tahon},
  year         = {2026},
  howpublished = {Proceedings of the International Conference on Spoken Language Translation (IWSLT) 2026},
}
```

## Acknowledgements

This work was developed within the **TTS4All project at the JSALT 2025 workshop** and at **LIUM, Le Mans University**.

We thank the audiobook writers and narrators for granting permission to use their recordings and voices for research purposes. The curated datasets and models were created to support the development of speech technologies for low-resource languages.