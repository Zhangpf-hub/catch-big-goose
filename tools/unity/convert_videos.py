"""Create Windows/Unity-compatible H.264/AAC clips without changing source videos."""
import hashlib, json, subprocess
from pathlib import Path
import imageio_ffmpeg

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'projects/catch-big-goose-unity/Assets/StreamingAssets/Video'

def main():
    DEST.mkdir(parents=True, exist_ok=True)
    report = []
    for source in sorted((ROOT / 'source-assets/videos').glob('*.mp4')):
        target = DEST / source.name
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-v', 'error', '-i', str(source),
            '-map', '0:v:0', '-map', '0:a:0?', '-sn', '-dn', '-c:v', 'libx264', '-preset', 'fast',
            '-threads', '4', '-crf', '21', '-pix_fmt', 'yuv420p', '-profile:v', 'baseline', '-level:v', '4.0', '-bf', '0',
            '-r', '30', '-c:a', 'aac', '-ac', '2', '-b:a', '128k', '-movflags', '+faststart',
            '-video_track_timescale', '30000', str(target)], check=True)
        report.append(dict(source=str(source.relative_to(ROOT)), target=str(target.relative_to(ROOT / 'projects/catch-big-goose-unity')),
            sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
            targetSha256=hashlib.sha256(target.read_bytes()).hexdigest(),
            encoding='H.264 Baseline / no B frames / yuv420p / 30 fps / AAC when source has audio / faststart'))
        print('Converted ' + source.name, flush=True)
    (ROOT / 'projects/catch-big-goose-unity/SourceAssets/video-manifest.json').write_text(json.dumps(report, indent=2), encoding='utf-8')

if __name__ == '__main__':
    main()
