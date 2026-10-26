"""Keep the licensed full font outside Resources and embed only game UI glyphs."""
import hashlib, json, shutil, sys
from pathlib import Path
sys.path.insert(0, 'D:/开发/tools/unity-asset-python')
from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[2]
FONT = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Fonts/Chinese.otf'
FULL = ROOT / 'projects/catch-big-goose-unity/SourceAssets/Fonts/Chinese-full.otf'

def main():
    FULL.parent.mkdir(parents=True, exist_ok=True)
    if not FULL.exists(): shutil.copy2(FONT, FULL)
    shutil.copy2(FONT.parent / 'OFL.txt', FULL.parent / 'OFL.txt')
    text = ''.join(p.read_text(encoding='utf-8-sig') for p in (ROOT / 'projects/catch-big-goose-unity/Assets/Scripts').glob('*.cs'))
    for p in (ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Data').glob('*.json'):
        text += json.dumps(json.loads(p.read_text(encoding='utf-8-sig')), ensure_ascii=False)
    required = {ord(c) for c in text if ord(c) >= 32} | set(range(32, 127))
    report = make_subset(FULL, FONT, required, 'Goose UI CJK', 'GooseUICJK-Regular')
    bold_source = FULL.parent / 'Chinese-Bold-full.otf'
    if bold_source.exists():
        report['bold'] = make_subset(bold_source, FONT.parent / 'Chinese-Bold.otf', required, 'Goose UI CJK Bold', 'GooseUICJK-Bold')
        report['bold']['upstream'] = 'https://github.com/notofonts/noto-cjk/blob/main/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Bold.otf'
    (ROOT / 'work/wechat-integration/font-subset.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print('UI font: ' + str(report['sourceBytes']) + ' -> ' + str(report['targetBytes']) + ' bytes; ' + str(len(required)) + ' glyphs')
    if 'bold' in report: print('True bold UI font: ' + str(report['bold']['targetBytes']) + ' bytes')

def make_subset(source, target, required, family, postscript):
    font = TTFont(source, recalcTimestamp=False)
    supported = set(font.getBestCmap())
    missing = sorted(required - supported)
    if missing: raise RuntimeError('Source font lacks UI glyphs: ' + str(missing))
    options = subset.Options()
    options.recalc_timestamp = False
    processor = subset.Subsetter(options=options); processor.populate(unicodes=required); processor.subset(font)
    names = {1: family, 2: 'Regular', 3: postscript + '-1', 4: family,
             6: postscript, 16: family, 17: 'Regular'}
    for identifier, value in names.items():
        for record in list(font['name'].names):
            if record.nameID == identifier:
                font['name'].setName(value, identifier, record.platformID, record.platEncID, record.langID)
        font['name'].setName(value, identifier, 3, 1, 0x409)
    if 'CFF ' in font:
        font['CFF '].cff.fontNames = [postscript]
        top = font['CFF '].cff.topDictIndex[0]
        top.FamilyName = family; top.FullName = family
    font.save(target)
    check = TTFont(target)
    assert required <= set(check.getBestCmap())
    return dict(source=str(source.relative_to(ROOT)), sourceBytes=source.stat().st_size,
        target=str(target.relative_to(ROOT)), targetBytes=target.stat().st_size, glyphs=len(required),
        sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(), targetSha256=hashlib.sha256(target.read_bytes()).hexdigest(),
        license='SIL OFL 1.1; copyright/license tables preserved; derived family renamed ' + family)

if __name__ == '__main__': main()
