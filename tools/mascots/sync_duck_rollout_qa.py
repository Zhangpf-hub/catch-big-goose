"""Refresh only the live runtime/data snapshot after concurrent workspace edits."""
import json,hashlib,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];ACTIVE=ROOT/'projects/catch-big-goose-unity';OUT=ROOT/'work/duck-live-two-themes';QA=OUT/'isolated-unity'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for folder in ['Assets/Scripts','Assets/Resources/Data'] for p in (ACTIVE/folder).rglob('*') if p.is_file()]
snapshot={p.relative_to(ACTIVE).as_posix():sha(p) for p in files}
for rel in snapshot:
    target=QA/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ACTIVE/rel,target)
assert all(sha(ACTIVE/p)==h for p,h in snapshot.items()),'Runtime changed during synchronization'
(OUT/'source-snapshot.json').write_text(json.dumps({'activeRuntimeFiles':snapshot,'runtimeFilesChanged':False,'qaOnlyEditorChanges':['Independent output directory','Resource validation without unrelated editor dependencies']},indent=2),'utf8')
print('Refreshed',len(snapshot),'runtime/data files')
