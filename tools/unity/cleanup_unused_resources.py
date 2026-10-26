"""Delete the audited legacy assets from the active project, with a recovery ZIP."""
import hashlib
import json
import zipfile
from pathlib import Path
from audit_unused_resources import ASSETS, PROJECT, OUT, build_plan


def main():
    plan=build_plan()
    if plan['serializedReferenceBlockers']:
        raise RuntimeError(json.dumps(plan['serializedReferenceBlockers'],ensure_ascii=False))
    archive=OUT/'deleted-legacy-resources.zip'
    if archive.exists():raise RuntimeError('Cleanup archive already exists; do not run deletion twice')
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'cleanup-plan.json').write_text(json.dumps(plan,ensure_ascii=False,indent=2),encoding='utf8')
    asset_root=ASSETS.resolve()
    targets=[];files=set()
    for row in plan['candidates']:
        path=(PROJECT/row['path']).resolve()
        if not path.is_relative_to(asset_root) or path==asset_root:raise RuntimeError('Unsafe deletion target '+str(path))
        if path.is_symlink():raise RuntimeError('Symlink deletion refused '+str(path))
        targets.append(path)
        for file in path.rglob('*') if path.is_dir() else [path]:
            if file.is_file():
                if not file.resolve().is_relative_to(asset_root):raise RuntimeError('Nested path outside Assets')
                files.add(file)
        meta=Path(str(path)+'.meta')
        if meta.exists():files.add(meta)
    # Metadata inventories should describe the remaining runtime resources.
    inventories={}
    for name,key in [('reference-material-models.json','models'),('item-presentation.json','items')]:
        path=ASSETS/'Resources/Data'/name;data=json.loads(path.read_text(encoding='utf8'))
        inventories[path]=data
    with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED) as bundle:
        for path in sorted(files):bundle.write(path,path.relative_to(PROJECT).as_posix())
        for path in inventories:bundle.write(path,path.relative_to(PROJECT).as_posix())
    # Verify the recovery copy before removing a single active file.
    with zipfile.ZipFile(archive) as bundle:
        for path in files:
            if hashlib.sha256(path.read_bytes()).digest()!=hashlib.sha256(bundle.read(path.relative_to(PROJECT).as_posix())).digest():
                raise RuntimeError('Archive verification failed '+str(path))
    removed=[dict(path=p.relative_to(PROJECT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in sorted(files)]
    for path in sorted(files,key=lambda p:len(p.parts),reverse=True):path.unlink()
    for target in sorted(targets,key=lambda p:len(p.parts),reverse=True):
        if target.is_dir():
            for child in sorted(target.rglob('*'),key=lambda p:len(p.parts),reverse=True):
                if child.is_dir():child.rmdir()
            target.rmdir()
    required=set(plan['requiredModelIds'])
    inventory_changes=[]
    for path,data in inventories.items():
        key='models' if 'models' in data else 'items';before=len(data[key]);data[key]=[row for row in data[key] if row['id'] in required]
        path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
        inventory_changes.append(dict(path=path.relative_to(PROJECT).as_posix(),before=before,after=len(data[key])))
    result=dict(removedFiles=len(removed),removedSourceBytes=sum(x['bytes'] for x in removed),
                unusedModelIds=plan['unusedModelIds'],removed=removed,inventoryChanges=inventory_changes,
                recoveryArchive=str(archive.relative_to(OUT)),serializedReferenceBlockers=[])
    (OUT/'deleted-resources.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps({k:result[k] for k in ['removedFiles','removedSourceBytes','unusedModelIds','inventoryChanges']},ensure_ascii=False,indent=2))


if __name__=='__main__':main()
