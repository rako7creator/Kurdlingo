from pathlib import Path
import json,wave,time
from piper import PiperVoice,SynthesisConfig
import onnxruntime as ort

root=Path(__file__).resolve().parent
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--voice',type=Path,required=True);parser.add_argument('--project',type=Path,default=root.parent);args=parser.parse_args()
project=args.project
rows=[r for r in json.loads((project/'data/vocabulary.json').read_text(encoding='utf8')) if r.get('region')=='School']
options=ort.SessionOptions();options.intra_op_num_threads=4;options.inter_op_num_threads=1
for language,model in [('en','english-ljspeech')]:
 output=project/'assets/audio'/language;output.mkdir(parents=True,exist_ok=True)
 voice=PiperVoice.load(str(args.voice))
 voice.session=ort.InferenceSession(str(args.voice),sess_options=options,providers=['CPUExecutionProvider'])
 config=SynthesisConfig(speaker_id=0,length_scale=1.04,noise_scale=0.55,noise_w_scale=0.65)
 start=time.time()
 for index,row in enumerate(rows):
  path=output/(row['id']+'.wav')
  if path.exists():continue
  with wave.open(str(path),'wb') as wav:
   voice.synthesize_wav(row[language]+'.',wav,syn_config=config)
  if index%20==0:print(language,index+1,'/',len(rows),round(time.time()-start,1),'seconds',flush=True)
 print(language,'completed',flush=True)

