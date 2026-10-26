"""Package real QA camera captures at their recorded timing; no synthetic frames."""
import argparse
import json
from pathlib import Path

from PIL import Image


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    folder = args.directory.resolve()
    report = json.loads((folder / 'surface-acceptance.json').read_text('utf-8-sig'))
    assert report['completed'] and report['passed'], 'Only a completed camera run can be packaged'
    rows = report['clipFrames']
    assert len(rows) >= 20
    frames = [Image.open(folder / 'clip-before.png').convert('RGB')]
    durations = [500]
    previous = 0.0
    for index, row in enumerate(rows):
        frame = Image.open(folder / row['file']).convert('RGB')
        assert frame.size == frames[0].size
        frames.append(frame)
        if index + 1 < len(rows):
            duration = max(.02, rows[index + 1]['seconds'] - row['seconds'])
        else:
            duration = .8
        durations.append(round(duration * 1000))
        assert row['seconds'] >= previous
        previous = row['seconds']
    frames[0].save(folder / 'shake-moderate.gif', save_all=True,
                   append_images=frames[1:], duration=durations, loop=0, optimize=False)
    # Six unaltered captures in one sheet make the horizontal displacement and
    # final arrangement reviewable without relying on an animated preview.
    indices = [0, 2, 5, 9, 14, len(frames) - 1]
    width, height = frames[0].size
    sheet = Image.new('RGB', (width * 3, height * 2), 'white')
    for slot, index in enumerate(indices):
        sheet.paste(frames[index], (slot % 3 * width, slot // 3 * height))
    sheet.save(folder / 'shake-frame-sheet.jpg', quality=92)
    (folder / 'clip-timing.json').write_text(json.dumps(dict(
        build=report['build'], source='Actual native production-camera captures; synthetic 1.6g phone input',
        phoneFootage=False, frames=len(frames), durationMs=durations,
        timing='Recorded real-time intervals, with a 500ms before and 800ms final hold; no acceleration'),
        ensure_ascii=False, indent=2), 'utf-8')
    print(json.dumps(dict(frames=len(frames), gif=str(folder / 'shake-moderate.gif'))))


if __name__ == '__main__':
    main()
