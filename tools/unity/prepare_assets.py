"""Snapshot the active Cocos resources into the Unity migration without changing the source."""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'projects/catch-big-goose-unity'
SOURCE = ROOT / 'reference-projects/catch-big-goose-cocos/assets/resources'


def main():
    for folder in ['Assets/Resources/Models', 'Assets/Resources/Icons', 'Assets/Resources/Textures',
                   'Assets/Resources/Audio', 'Assets/Resources/Data', 'Assets/Scripts',
                   'Assets/Editor', 'Assets/Scenes', 'Assets/StreamingAssets/Video',
                   'Packages', 'ProjectSettings', 'SourceAssets/Models']:
        (DEST / folder).mkdir(parents=True, exist_ok=True)
    config = (ROOT / 'reference-projects/catch-big-goose-cocos/assets/scripts/core/LevelConfig.ts').read_text(encoding='utf-8')
    skins = {
        'fruit': ('bg_redwood', 'basket_redwood', False, 1.35, 1.42),
        'antique': ('bg_jade', 'bowl_jade', True, 1.65, 1.65),
        'farm': ('bg_farm', 'basket_farm', False, 1.35, 1.42),
        'dessert': ('bg_dessert', 'tray_dessert', False, 1.35, 1.42),
        'electronics': ('bg_electronics', 'tray_electronics', False, 1.63, 1.63),
    }
    themes = []
    for match in re.finditer(r"id: '([^']+)', name: '([^']+)', skinId: '[^']+'[\s\S]*?family:\s*\[([^\]]+)\]", config):
        theme_id, name, raw = match.groups()
        ids = re.findall(r"'([^']+)'", raw)
        bg, container, circle, hx, hz = skins[theme_id]
        themes.append(dict(id=theme_id, name=name, items=ids, background=bg,
                           container=container, circular=circle, halfX=hx, halfZ=hz))
    assert len(themes) == 5 and all(len(t['items']) == 9 for t in themes), 'Theme snapshot incomplete'
    theme_file = DEST / 'Assets/Resources/Data/themes.json'
    # Unity has its own authorized pool extensions and weight evidence. A baseline
    # Cocos resource refresh must preserve these rather than silently revert to 9.
    existing = json.loads(theme_file.read_text('utf-8')) if theme_file.exists() else {'themes': []}
    for theme in themes:
        previous = next((t for t in existing['themes'] if t['id'] == theme['id']), None)
        if previous:
            theme['items'] += [i for i in previous['items'] if i not in theme['items']]
            for key in ['itemWeights', 'groupWeights', 'coreGroupWeights', 'coreWeightEvidence']:
                if key in previous:
                    value = previous[key]
                    if key != 'coreWeightEvidence' and value is not None:
                        if len(value) != len(previous['items']):
                            raise ValueError(f"{theme['id']}: truncated saved weights")
                        by_id = dict(zip(previous['items'], value))
                        if any(id not in by_id for id in theme['items']):
                            raise ValueError(f"{theme['id']}: new baseline IDs need explicit weights")
                        value = [by_id[id] for id in theme['items']]
                    theme[key] = value
    theme_file.write_text(
        json.dumps({'themes': themes}, ensure_ascii=False, indent=2), encoding='utf-8')
    snapshots = []
    for sub, target in [('models', 'SourceAssets/Models'), ('icons', 'Assets/Resources/Icons'),
                        ('textures', 'Assets/Resources/Textures'), ('audio', 'Assets/Resources/Audio')]:
        for path in (SOURCE / sub).rglob('*'):
            if not path.is_file() or path.suffix in ['.meta', '.md']:
                continue
            relative = path.relative_to(SOURCE / sub)
            dest = DEST / target / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            if path.suffix == '.m4a':
                import imageio_ffmpeg
                dest = dest.with_suffix('.ogg')
                subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-i', str(path), '-c:a', 'libvorbis', '-q:a', '4', str(dest)],
                               check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                shutil.copy2(path, dest)
            snapshots.append({'source': str(path.relative_to(ROOT)).replace('\\', '/'),
                              'target': str(dest.relative_to(DEST)).replace('\\', '/'),
                              'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                              'targetSha256': hashlib.sha256(dest.read_bytes()).hexdigest()})
    from convert_videos import main as convert_videos
    convert_videos()
    from bake_control_labels import main as bake_control_labels
    bake_control_labels()
    if (DEST / 'SourceAssets/Fonts/Chinese-full.otf').exists():
        from subset_ui_font import main as subset_ui_font
        subset_ui_font()
    (DEST / 'SourceAssets/source-manifest.json').write_text(
        json.dumps(snapshots, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'Prepared {len(themes)} themes, {len(snapshots)} resources and local videos')


if __name__ == '__main__':
    main()
