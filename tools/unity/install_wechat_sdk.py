"""Embed a pinned official WXSDK checkout, with minimal Unity 2022 assembly adaptation."""
import hashlib, json, shutil, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'work/wechat-integration/wxsdk-upstream'
DEST = ROOT / 'projects/catch-big-goose-unity/Packages/com.qq.weixin.minigame'
COMMIT = '915d4bf4f60ef0cd1c29316a8d67257185d609a7'

def main():
    actual = subprocess.check_output(['git', '-C', str(SOURCE), 'rev-parse', 'HEAD'], text=True).strip()
    if actual != COMMIT: raise RuntimeError('Unexpected SDK revision')
    entries = []
    for source in SOURCE.rglob('*'):
        relative = source.relative_to(SOURCE)
        if '.git' in relative.parts or not source.is_file(): continue
        target = DEST / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        data = source.read_bytes()
        original = hashlib.sha256(data).hexdigest()
        patch = None
        if relative.as_posix() == 'Editor/WxWasmSDKEditor.asmdef':
            doc = json.loads(data)
            doc['references'] = [x for x in doc['references'] if x != 'Unity.InstantGame.Editor']
            data = (json.dumps(doc, indent=2) + '\n').encode()
            patch = 'Remove optional InstantGame assembly reference; this editor has no InstantGame package.'
        elif relative.as_posix() == 'Runtime/WxWasmSDKRuntime.asmdef':
            doc = json.loads(data); doc['references'] = ['Unity.ugui']
            data = (json.dumps(doc, indent=2) + '\n').encode()
            patch = 'Resolve uGUI by assembly name instead of missing upstream project GUID.'
        target.write_bytes(data)
        entries.append(dict(path=relative.as_posix(), upstreamSha256=original,
                            installedSha256=hashlib.sha256(data).hexdigest(), patch=patch))
    report = dict(repository='https://github.com/wechat-miniprogram/minigame-tuanjie-transform-sdk',
                  commit=COMMIT, files=entries)
    (ROOT / 'work/wechat-integration/wxsdk-install.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Embedded official WXSDK: ' + str(len(entries)) + ' files, commit ' + COMMIT)

if __name__ == '__main__': main()
