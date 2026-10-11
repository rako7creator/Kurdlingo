import os
from pathlib import Path
import argparse
parser=argparse.ArgumentParser(description="Rebuild offline Sorani speech using the published noncommercial F5 model")
parser.add_argument('--model-dir',type=Path,required=True)
parser.add_argument('--force',action='store_true',help='Replace existing recordings')
args=parser.parse_args()
BASE=args.model_dir.resolve()
PROJECT=Path(__file__).resolve().parents[1]
os.environ['HF_HOME']=str(BASE/'hf-cache');os.environ['MPLCONFIGDIR']=str(BASE/'mpl');os.environ['TEMP']=str(BASE.parent/'tmp');os.environ['TMP']=os.environ['TEMP']
import sys,json,time,re
import torch,torchaudio,soundfile as sf,numpy as np,yaml,asosoft
# PCM WAV input avoids optional ffmpeg / torchcodec DLLs on Windows.
def pcm_load(path,*args,**kwargs):
 a,sr=sf.read(path,dtype='float32',always_2d=True);return torch.from_numpy(a.T.copy()),sr
def pcm_save(path,tensor,sr,*args,**kwargs):sf.write(path,tensor.detach().cpu().numpy().T,sr,subtype='PCM_16')
torchaudio.load=pcm_load;torchaudio.save=pcm_save
from f5_tts.model import DiT
from f5_tts.infer.utils_infer import load_model,load_vocoder,preprocess_ref_audio_text,infer_process
import urllib.request
v=BASE/'vocoder';v.mkdir(exist_ok=True)
for name in ['config.yaml','pytorch_model.bin']:
 if not (v/name).exists():urllib.request.urlretrieve('https://huggingface.co/charactr/vocos-mel-24khz/resolve/main/'+name,v/name)
print('CUDA:',torch.cuda.get_device_name(),flush=True)
torch.set_num_threads(4)
if not (BASE/'inference-female.pt').exists():
 checkpoint=torch.load(BASE/'model-audiobook-female.pt',map_location='cpu',weights_only=True,mmap=True)
 torch.save({'ema_model_state_dict':checkpoint['ema_model_state_dict']},BASE/'inference-female.pt')
 del checkpoint
# This local inference cache must not be included in distributions.
config=yaml.safe_load((BASE/'F5TTS_v1_Base.yaml').read_text(encoding='utf8'))
model=load_model(DiT,config['model']['arch'],str(BASE/'inference-female.pt'),vocab_file=str(BASE/'vocab.txt'),device='cuda')
vocoder=load_vocoder(is_local=True,local_path=str(v),device='cuda')
def norm(text):
 t=asosoft.Normalize(text,changeInitialR=True,deepUnicodeCorrectios=True,additionalUnicodeCorrections=True)
 t=asosoft.NormalizePunctuations(t,seprateAllPunctuations=True)
 t=asosoft.KurdishG2P(t).replace('ˈ','')
 for a,b in {'ẍ':'χ','ƹ':'¿','ḧ':'ḥ'}.items():t=t.replace(a,b)
 return t
ref,text=preprocess_ref_audio_text(str(BASE/'prompt-audiobook-female.wav'),norm((BASE/'prompt-audiobook-female.txt').read_text(encoding='utf8')))
refdur=sf.info(ref).duration
project=PROJECT;rows=json.loads((project/'data/vocabulary.json').read_text(encoding='utf8'))

output=project/'assets/audio/ckb';output.mkdir(exist_ok=True)
start=time.time()
for i,row in enumerate(rows):
 path=output/(row['id']+'.wav')
 if path.exists() and not args.force:continue
 overrides=json.loads((project/'data/pronunciation-overrides.json').read_text(encoding='utf8'))
 spoken=overrides.get(row['id'],norm(row['ckb']+'.'))
 torch.manual_seed(2026 if row["id"]=="water" else 42+i)
 audio,sr,_=infer_process(ref,text,spoken,model,vocoder,device='cuda',nfe_step=48 if row["id"]=="water" else 32,fix_duration=refdur+(2.2 if row["id"]=="water" else max(1.4,min(3.2,0.16*len(spoken)))),show_info=lambda *a:None,progress=None)
 # Trim only silent edges; keep articulation and a 90ms replay gap.
 frames=np.where(np.abs(audio)>0.006)[0]
 if len(frames):audio=audio[max(0,frames[0]-int(sr*.08)):min(len(audio),frames[-1]+int(sr*.12))]
 peak=float(np.max(np.abs(audio)))
 if peak<.01:raise RuntimeError('Nearly silent output '+row['id'])
 audio=audio*(0.8/max(peak,0.8))
 sf.write(path,audio,sr,subtype='PCM_16')
 print(i+1,'/',len(rows),row['id'],round(len(audio)/sr,2),'sec',round(time.time()-start,1),'elapsed',flush=True)
