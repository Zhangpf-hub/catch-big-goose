"""Create compact copies of both source clips for an on-demand WeChat subpackage."""
import hashlib, json, subprocess
from pathlib import Path
import imageio_ffmpeg

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'work/wechat-integration/media'

def main():
    DEST.mkdir(parents=True, exist_ok=True)
    files = []
    for name in ['Darkchaser-Battletide.mp4', 'Skycore-Reboot.f5800.mp4']:
        source, target = ROOT / 'source-assets/videos' / name, DEST / name
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-v', 'error', '-i', str(source),
            '-map', '0:v:0', '-map', '0:a:0?', '-vf', 'scale=854:480', '-c:v', 'libx264',
            '-preset', 'fast', '-threads', '4', '-crf', '27', '-maxrate', '650k', '-bufsize', '1300k',
            '-pix_fmt', 'yuv420p', '-profile:v', 'baseline', '-bf', '0', '-r', '30',
            '-c:a', 'aac', '-ac', '2', '-b:a', '64k', '-movflags', '+faststart', str(target)], check=True)
        files.append(dict(name=name, bytes=target.stat().st_size, sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
            sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest()))
    (DEST / 'manifest.json').write_text(json.dumps(dict(schemaVersion=1, files=files), indent=2), encoding='utf-8')
    (DEST / 'game.js').write_text('// On-demand local video assets.\n', encoding='utf-8')
    print('WeChat video assets: ' + str(sum(f['bytes'] for f in files)) + ' bytes')

if __name__ == '__main__': main()
