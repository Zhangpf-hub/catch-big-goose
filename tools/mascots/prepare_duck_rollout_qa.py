"""Snapshot the current runtime into an independent Unity QA/build workspace."""
import json,hashlib,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];ACTIVE=ROOT/'projects/catch-big-goose-unity';OUT=ROOT/'work/duck-live-two-themes';QA=OUT/'isolated-unity'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    files=[p for folder in ['Assets/Scripts','Assets/Resources/Data'] for p in (ACTIVE/folder).rglob('*') if p.is_file()]
    snapshot={p.relative_to(ACTIVE).as_posix():sha(p) for p in files}
    for folder in ['Assets','ProjectSettings']:
        shutil.copytree(ACTIVE/folder,QA/folder,dirs_exist_ok=True,ignore=shutil.ignore_patterns('Editor','Editor.meta') if folder=='Assets' else None)
    (QA/'Packages').mkdir(exist_ok=True)
    manifest=json.loads((ROOT/'work/duck-b2-gameplay-qa/Packages/manifest.json').read_text('utf-8-sig'))
    (QA/'Packages/manifest.json').write_text(json.dumps(manifest,indent=2),'utf-8')
    editor=QA/'Assets/Editor';editor.mkdir(exist_ok=True)
    shutil.copy2(ACTIVE/'Assets/Editor/GoosePlayerNetworkPolicy.cs',editor/'GoosePlayerNetworkPolicy.cs')
    source=(ACTIVE/'Assets/Editor/GooseDuckRolloutBuild.cs').read_text('utf-8')
    source=source.replace('Path.GetFullPath("../../work/duck-live-two-themes")','@"'+str(OUT)+'"')
    source=source.replace('GooseProjectSetup.Audit();','')
    (editor/'GooseDuckRolloutBuild.cs').write_text(source,'utf-8')
    assert all(sha(ACTIVE/p)==h for p,h in snapshot.items()),'Runtime changed during QA snapshot'
    (OUT/'source-snapshot.json').write_text(json.dumps({'activeRuntimeFiles':snapshot,'runtimeFilesChanged':False,'qaOnlyEditorChanges':['Independent output directory','Resource model validation instead of unrelated project-setup dependencies']},indent=2),'utf-8')
    print('Independent Unity snapshot ready:',len(snapshot),'runtime files')
if __name__=='__main__':main()
