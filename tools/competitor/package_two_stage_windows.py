"""Create a portable archive from the isolated, frozen native release."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib,json
ROOT=Path(__file__).resolve().parents[2];WORK=ROOT/'work/two-stage-20261025'
source=WORK/'frozen-project/unity/Builds/Windows'
target=WORK/'CatchGoose-TwoStage-20261025-Windows.zip'
assert (source/'CatchGoose.exe').is_file()
with ZipFile(target,'w',ZIP_DEFLATED,compresslevel=6) as archive:
    for file in sorted(source.rglob('*')):
        if file.is_file():archive.write(file,'CatchGoose/'+file.relative_to(source).as_posix())
with ZipFile(target) as archive:assert archive.testzip() is None
report=dict(path=target.relative_to(ROOT).as_posix(),bytes=target.stat().st_size,sha256=hashlib.sha256(target.read_bytes()).hexdigest(),source=source.relative_to(ROOT).as_posix())
(WORK/'windows-archive.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf8')
print('Portable Windows archive:',report['bytes'],'bytes; all entries verified.')
