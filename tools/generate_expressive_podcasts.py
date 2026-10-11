import os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]/'.audio-work'
ROOT.mkdir(exist_ok=True)
import argparse
parser=argparse.ArgumentParser()
parser.add_argument('--project',type=Path,default=Path(__file__).resolve().parents[1])
parser.add_argument('--model-dir',type=Path,required=True)
parser.add_argument('--device',default='cuda',choices=['cpu','cuda'])
args=parser.parse_args()
os.environ['HF_HOME']=str(ROOT/'podcast-hf-cache');os.environ['HF_HUB_DISABLE_XET']='1'
os.environ['TEMP']=str(ROOT/'tmp');os.environ['TMP']=os.environ['TEMP'];os.environ['TQDM_DISABLE']='1'
import torch,torchaudio,soundfile as sf,numpy as np,json,time,re,shutil
def load_pcm(path,*args,**kwargs):
 a,sr=sf.read(path,always_2d=True,dtype='float32');return torch.from_numpy(a.T.copy()),sr
torchaudio.load=load_pcm
from chatterbox.tts_turbo import ChatterboxTurboTTS
from tqdm.auto import tqdm
# Disable per-token progress; retain one concise completion line per paragraph.
(ROOT/'tmp').mkdir(exist_ok=True)
PROJECT=args.project.resolve()
backup=ROOT/'podcasts-before09';backup.mkdir(exist_ok=True)
if not (backup/'podcasts.json').exists():shutil.copy2(PROJECT/'data/podcasts.json',backup/'podcasts.json');shutil.copytree(PROJECT/'assets/audio/podcasts',backup/'audio',dirs_exist_ok=True)
episodes=json.loads((PROJECT/'data/podcasts.json').read_text(encoding='utf8'))
cache=ROOT/'podcasts-expressive09';cache.mkdir(exist_ok=True)
torch.set_num_threads(4);torch.set_float32_matmul_precision('high');torch.manual_seed(42)
print('Loading Chatterbox Turbo ·',args.device,flush=True)
model=ChatterboxTurboTTS.from_local(args.model_dir,device=args.device)
voices={}
for speaker in ['host','guest']:
 prompt=PROJECT/'assets/audio/podcast_reference'/(speaker+'.wav')
 model.prepare_conditionals(str(prompt),norm_loudness=False);voices[speaker]=model.conds
print('Two synthetic voice identities prepared',flush=True)
start=time.time();done=0
for episode in episodes:
 total=0
 for si,segment in enumerate(episode['segments']):
  target=cache/(segment['id']+'.wav');metadata=cache/(segment['id']+'.json')
  if target.exists() and metadata.exists():
   saved=json.loads(metadata.read_text(encoding='utf8'));segment.update(saved);total+=saved['duration'];done+=1;continue
  # Short natural turns also prevent the model's token limit truncating a paragraph.
  captions=segment.get('captions') or [dict(en=segment['en'],ckb=segment['ckb'],start=0)]
  groups=[];group=[];count=0
  for caption in captions:
   words=len(caption['en'].split())
   if group and count+words>43:groups.append(group);group=[];count=0
   group.append(caption);count+=words
  if group:groups.append(group)
  clips=[];new_captions=[];offset=0
  for gi,group in enumerate(groups):
   text=' '.join(c['en'] for c in group)
   reaction='[chuckle] ' if episode['id'] in ['movie_night','music_festival','creative_project'] and si==5 and gi==0 else ''
   chunk_file=cache/(segment['id']+f'-chunk{gi}.wav')
   if not chunk_file.exists():
    model.conds=voices[segment['speaker']]
    torch.manual_seed(4200+done*7+gi)
    audio=model.generate(reaction+text,temperature=.7,repetition_penalty=1.2).squeeze().cpu().numpy()
    if len(audio)/model.sr<max(1,len(text.split())*.11):raise RuntimeError('Suspiciously short audio: '+segment['id'])
    # Preserve the neural watermark; normalize loudness without changing pitch.
    peak=float(np.max(np.abs(audio)));audio=audio*.88/max(peak,.88)
    sf.write(chunk_file,audio,model.sr,subtype='PCM_16')
   audio,sr=sf.read(chunk_file,dtype='float32');duration=len(audio)/sr
   weights=sum(len(c['en'].split()) for c in group);word_offset=0
   for caption in group:
    new_captions.append(dict(en=caption['en'],ckb=caption['ckb'],start=round(offset+word_offset/weights*duration,3)));word_offset+=len(caption['en'].split())
   clips.append(audio);clips.append(np.zeros(int(sr*.16),dtype='float32'));offset+=duration+.16
  sf.write(target,np.concatenate(clips),model.sr,subtype='PCM_16')
  saved=dict(duration=round(offset,3),captions=new_captions,voice_model='Chatterbox Turbo',voice_reference='Synthetic Piper '+segment['speaker'])
  metadata.write_text(json.dumps(saved,ensure_ascii=False,indent=2),encoding='utf8');segment.update(saved);total+=offset;done+=1
  print('PARAGRAPH',done,'/280',segment['id'],round(offset,1),'sec ·',round((time.time()-start)/60,1),'min elapsed',flush=True)
 episode['duration']=round(total,2)
 print('EPISODE COMPLETE',episode['id'],round(total/60,2),'minutes',flush=True)
(cache/'podcasts.json').write_text(json.dumps(episodes,ensure_ascii=False,indent=2),encoding='utf8')
assert all(e['duration']>360 for e in episodes)
for episode in episodes:
 for segment in episode['segments']:shutil.copy2(cache/(segment['id']+'.wav'),PROJECT/'assets/audio/podcasts'/(segment['id']+'.wav'))
shutil.copy2(cache/'podcasts.json',PROJECT/'data/podcasts.json')
print('ALL TEN EXPRESSIVE PODCASTS INSTALLED',round(sum(e['duration'] for e in episodes)/60,2),'minutes',flush=True)
