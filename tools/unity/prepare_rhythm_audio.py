"""Original rubbery groove with an A/B variation; --music-only preserves all SFX."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import wave

import imageio_ffmpeg
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Audio'
WORK=ROOT/'work/music-variation-20261025/audio'
SR=44100
BPM=140
BEAT=60/BPM
RNG=np.random.default_rng(2026102504)

def save(path,data):
    with wave.open(str(path),'wb') as file:
        file.setnchannels(1 if data.ndim==1 else data.shape[1]);file.setsampwidth(2);file.setframerate(SR)
        file.writeframes((np.clip(data,-.999,.999)*32767).astype('<i2').tobytes())

def add(buf,data,at,gain=1,pan=0):
    indices=(np.arange(len(data))+round(at*SR))%len(buf)
    for channel,level in enumerate(((1-pan)**.5,(1+pan)**.5)):
        np.add.at(buf[:,channel],indices,data*gain*level*.7071)

def note(midi,duration,bass=False):
    t=np.arange(round(duration*SR))/SR;frequency=440*2**((midi-69)/12)
    # A tiny pitch fall gives a rubbery "dup" rather than a sustained bell.
    phase=2*np.pi*frequency*(t+.10*.018*(1-np.exp(-t/.018)))
    signal=np.sin(phase)+.30*np.sin(phase*2)+.12*np.sin(phase*3)+.045*np.sin(phase*5)
    envelope=np.minimum(t/.004,1)*np.minimum((duration-t)/.018,1)*np.exp(-t*(13 if not bass else 10))
    return np.tanh(signal*1.25)*envelope

def noise(duration,cutoff=3400):
    n=round(duration*SR);f=np.fft.rfftfreq(n,1/SR)
    spectrum=np.fft.rfft(RNG.normal(size=n))
    spectrum*=np.exp(-(f/cutoff)**6)*(1-np.exp(-(f/600)**4))
    data=np.fft.irfft(spectrum,n);return data/max(np.max(np.abs(data)),1e-9)

def compose():
    global RNG
    RNG=np.random.default_rng(2026102504)
    buf=np.zeros((round(16*4*BEAT*SR),2))
    # Keep the original two-bar hook and rhythm section. Four-bar A/B phrases
    # alternate, with a short answer/turnaround rather than an exact restart.
    hook=[(0,67),(.5,67),(.75,72),(1.5,67),(2,64),(2.5,64),(2.75,67),(3.5,64),
          (4,67),(4.5,67),(4.75,72),(5.5,67),(6,64),(6.5,67),(7,64),(7.5,60)]
    lift=[(beat,69 if beat==4.75 else midi) for beat,midi in hook]
    variation=[(0,72),(.5,74),(1,76),(1.75,74),(2.5,72),(3,67),(3.5,69),
               (4,72),(4.75,69),(5.5,67),(6,64),(6.5,67),(7,69),(7.5,67)]
    answer=[(0,76),(.5,74),(1,72),(1.75,69),(2.5,67),(3,69),(3.5,72),
            (4,74),(4.75,72),(5.5,69),(6,67),(6.5,64),(7,67),(7.5,60)]
    reprise=[(beat,76 if beat==.5 else 74 if beat==1 else midi) for beat,midi in variation]
    turnaround=[(0,72),(.5,69),(.75,67),(1.5,64),(2,67),(2.5,69),(2.75,72),(3.5,69),
                (4,67),(4.5,64),(4.75,67),(5.5,72),(6,69),(6.5,67),(7,64),(7.5,60)]
    phrases=[hook,lift,variation,answer,hook,lift,reprise,turnaround]
    kick_t=np.arange(round(.15*SR))/SR
    kick=np.sin(2*np.pi*(58*kick_t+1.1*(1-np.exp(-kick_t/.012))))*np.exp(-27*kick_t)*np.minimum(kick_t/.003,1)
    for section,phrase in enumerate(phrases):
        start=section*8*BEAT
        is_variation=section in (2,3,6,7)
        for beat,midi in phrase:
            add(buf,note(midi,.15 if is_variation else .13),start+beat*BEAT,.235 if is_variation else .25,-.10)
        for bar in range(2):
            at=start+bar*4*BEAT
            for beat,midi in [(0,36),(.75,48),(1.5,43),(2,36),(2.75,48),(3.5,43)]:
                add(buf,note(midi,.17,True),at+beat*BEAT,.32,.06)
            for beat in range(4):add(buf,kick,at+beat*BEAT,.24)
            for beat in (1,3):
                t=np.arange(round(.11*SR))/SR
                clap=noise(.11,3000)*np.exp(-35*t)*np.minimum(t/.003,1)
                add(buf,clap,at+beat*BEAT,.15,.12)
            for step in range(8):
                t=np.arange(round(.045*SR))/SR
                hat=noise(.045,3900)*np.exp(-100*t)*np.minimum(t/.002,1)
                add(buf,hat,at+step*.5*BEAT,.065 if step%2 else .030,-.20 if step%2 else .20)
            # Short offbeat organ chops reinforce the same C groove.
            for beat in (.5,1.5,2.5,3.5):
                for midi in (60,64,67):add(buf,note(midi,.075),at+beat*BEAT,.026,.25)
    buf*=min(.82/np.max(np.abs(buf)),.175/np.sqrt(np.mean(buf**2)))
    return buf

def describe(data):
    return dict(seconds=len(data)/SR,peak=float(np.max(np.abs(data))),rms=float(np.sqrt(np.mean(data**2))))

def main():
    global WORK
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--music-only',action='store_true',help='Regenerate BGM only; leave all existing sound effects untouched')
    parser.add_argument('--output-dir',type=Path,default=WORK)
    args=parser.parse_args();WORK=args.output_dir.resolve()
    WORK.mkdir(parents=True,exist_ok=True)
    bgm=compose();save(WORK/'bgm-loop.wav',bgm)
    ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run([ffmpeg,'-y','-v','error','-i',str(WORK/'bgm-loop.wav'),'-c:a','libvorbis','-q:a','5',str(OUT/'bgm.ogg')],check=True)
    music_report=dict(version='MUSIC2',bpm=BPM,bars=16,form='A-B-A-B2: four bars per phrase',
        variationStartsSeconds=[16*BEAT,48*BEAT],bgm=describe(bgm),
        musicProvenance='Original A/B melody variation; original 140 BPM rubbery timbre, kick, syncopated bass and organ retained',
        bgmSha256=hashlib.sha256((OUT/'bgm.ogg').read_bytes()).hexdigest(),
        musicOnly=args.music_only)
    if args.music_only:
        (WORK/'audio-audit.json').write_text(json.dumps(music_report,ensure_ascii=False,indent=2),encoding='utf8')
        print(json.dumps(music_report,ensure_ascii=False,indent=2));return
    reference=ROOT/'competitor-analysis/artifacts/competitor-audio-20261025/S_ToolShake.m4a'
    decoded=subprocess.run([ffmpeg,'-v','error','-i',str(reference),'-f','f32le','-ac','1','-ar',str(SR),'-'],check=True,capture_output=True).stdout
    shake=np.frombuffer(decoded,dtype='<f4').astype(np.float64)
    # Remove codec priming/trailing silence only; retain the reference timbre.
    active=np.flatnonzero(np.abs(shake)>.002)
    shake=shake[max(0,int(active[0])-160):min(len(shake),int(active[-1])+400)]
    shake*=.82/max(np.max(np.abs(shake)),1e-9)
    save(OUT/'shake.wav',shake)
    save(WORK/'reference-shake.wav',shake)
    demo=np.tile(bgm,(2,1))*.28
    for at,gain in ((2,.90),(2.16,.76),(2.36,.64),(2.58,.48)):
        index=round(at*SR);demo[index:index+len(shake)]+=shake[:,None]*gain*.7071
    save(WORK/'gameplay-audio-preview.wav',demo)
    report=dict(**music_report,shake=describe(shake),
                shakeProvenance='Local competitor S_ToolShake extracted from the supplied cache; reference timbre retained for this comparison build. Burst timing is project adaptation.',
                referenceSha256=hashlib.sha256(reference.read_bytes()).hexdigest(),
                files={name:hashlib.sha256((OUT/name).read_bytes()).hexdigest() for name in ('bgm.ogg','shake.wav')})
    (WORK/'audio-audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps(report,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
