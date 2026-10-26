"""Encode actual development-player camera frames; no invented game footage."""
from pathlib import Path
import json,subprocess,sys,hashlib,statistics
import imageio_ffmpeg
root=Path(__file__).resolve().parents[2]
frames=Path(sys.argv[1]).resolve();dest=Path(sys.argv[2]).resolve();dest.parent.mkdir(parents=True,exist_ok=True)
files=sorted(frames.glob('*.png'))
if len(files)<2:raise SystemExit('Not enough recorded frames')
times=[p.stat().st_mtime_ns/1e9 for p in files]
durations=[max(.001,times[i+1]-times[i]) for i in range(len(files)-1)]
durations.append(statistics.median(durations))
concat=dest.with_suffix('.ffconcat')
def quoted(p):return "'"+p.as_posix().replace("'","'\\''")+"'"
lines=['ffconcat version 1.0']
for p,d in zip(files,durations):lines.extend(['file '+quoted(p),'duration '+format(d,'.6f')])
lines.append('file '+quoted(files[-1]));concat.write_text('\n'.join(lines)+'\n',encoding='utf-8')
subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-y','-v','error','-safe','0','-f','concat','-i',str(concat),'-fps_mode','vfr','-c:v','libx264','-crf','20','-preset','fast','-pix_fmt','yuv420p','-movflags','+faststart',str(dest)],check=True)
report=dict(frames=len(files),durationSeconds=sum(durations),variableFrameRate=True,silent=True,timestampSource='Original synchronous PNG write timestamps; no fixed-8-fps speed-up',source=str(frames),output=str(dest),sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),scope='Actual native development-player camera frames. Recording runs excluded from performance claims; exact opening timing is in acceptance JSON.')
dest.with_suffix('.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
