"""Encode actual Unity captures at their recorded wall-clock timestamps."""
import argparse
import json
import shutil
import subprocess
from pathlib import Path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    root = args.output.resolve()
    ffmpeg = shutil.which('ffmpeg')
    if not ffmpeg:
        import imageio_ffmpeg
        ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    results = []
    for record in sorted(root.glob('*-frames.json')):
        data = json.loads(record.read_text(encoding='utf-8-sig'))
        frames = data['frames']
        if not frames:
            continue
        rows = ['ffconcat version 1.0']
        for i, frame in enumerate(frames):
            delta = frames[i + 1]['time'] - frame['time'] if i + 1 < len(frames) else .12
            assert delta > 0 and "'" not in frame['file']
            rows.extend(["file '" + frame['file'] + "'", f'duration {delta:.6f}'])
        rows.append("file '" + frames[-1]['file'] + "'")
        concat = root / (data['name'] + '.ffconcat')
        concat.write_text('\n'.join(rows) + '\n', encoding='utf-8')
        target = root / (data['name'] + '.mp4')
        subprocess.run([ffmpeg, '-hide_banner', '-loglevel', 'warning', '-y', '-safe', '0',
                        '-f', 'concat', '-i', str(concat), '-fps_mode', 'vfr', '-c:v', 'libx264',
                        '-crf', '21', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(target)], check=True)
        results.append(dict(file=target.name, frames=len(frames), seconds=frames[-1]['time'] - frames[0]['time'], bytes=target.stat().st_size))
    order = ['truck-pass-demo.mp4', 'sale-demo.mp4', 'tray-revive-demo.mp4', 'timeout-revive-demo.mp4']
    if all((root / name).exists() for name in order):
        combined = root / 'reward-flow-demo.ffconcat'
        combined.write_text('ffconcat version 1.0\n' + ''.join("file '" + name + "'\n" for name in order), encoding='utf-8')
        subprocess.run([ffmpeg, '-hide_banner', '-loglevel', 'warning', '-y', '-safe', '0', '-f', 'concat',
                        '-i', str(combined), '-fps_mode', 'vfr', '-c:v', 'libx264', '-crf', '21', '-pix_fmt', 'yuv420p',
                        '-movflags', '+faststart', str(root / 'reward-flow-demo.mp4')], check=True)
    report = dict(source='Actual Unity frame captures; timestamp-preserving VFR encoding; no audio track',
                  gameplayWait='Checkpoint wait shortened by development-only parameters; full real videos retained', videos=results)
    (root / 'demo-videos.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False))

if __name__ == '__main__':
    main()
