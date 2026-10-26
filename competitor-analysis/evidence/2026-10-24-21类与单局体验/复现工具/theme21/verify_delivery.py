"""Check frozen evidence, source-value bindings and active documentation links."""
import hashlib
import json
import re
from pathlib import Path
from urllib.parse import unquote
from catalog import ROOT

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):return json.loads(path.read_text('utf-8-sig'))

def main():
    evidence=ROOT/'竞品分析/证据/2026-10-24-21类与单局体验'
    source=ROOT/'work/competitor-config-trace/serialized-verified/LevelData.json'
    weights=read(evidence/'配置/权重来源.json');assert digest(source)==weights['sourceSha256']
    records=read(source)['dataArray'];count=0
    for b in weights['bindings']:
        row=records[b['sourceRow']]
        assert row['_index']==b['sourceIndex'] and row['_gametype']==b['sourceGameType'] and row['_level']==b['sourceLevel']
        assert row['_height']==b['sourceHeight'] and row['_sumcount']==b['sourceNormalCount']
        assert row['_namelist'][b['sourceOrdinal']]==b['sourceName']
        assert row['_othertypeweight'][b['sourceOrdinal']]==b['weight'];count+=1
    themes=read(ROOT/'unity/Assets/Resources/Data/themes.json')['themes']
    for theme in themes:
        assert len(set(theme['items']))==len(theme['items'])==21
        for id,w in zip(theme['items'],theme['coreGroupWeights']):
            assert next(b['weight'] for b in weights['bindings'] if b['id']==id and b['theme']==theme['id'])==w
    manifest=read(evidence/'文件校验.json')
    for row in manifest:assert digest(evidence/row['path'])==row['sha256'],row['path']
    for row in read(evidence/'资源/运行资源哈希.json'):assert digest(ROOT/row['path'])==row['sha256'],row['path']
    for row in read(evidence/'验证汇总.json')['release']:assert digest(ROOT/row['path'])==row['sha256'],row['path']
    links=0;broken=[]
    for file in (ROOT/'竞品分析').glob('*.md'):
        for target in re.findall(r'(?<!!)\[[^\]]+\]\(([^)]+)\)',file.read_text('utf-8')):
            target=unquote(target.strip('<>')).split('#')[0]
            if not target or re.match(r'^[a-z]+://',target):continue
            path=(file.parent/target).resolve()
            if not path.exists():broken.append((file.name,target))
            links+=1
    assert not broken,broken
    print(json.dumps(dict(passed=True,sourceBindings=count,evidenceFiles=len(manifest),activeLocalLinks=links),ensure_ascii=False))

if __name__=='__main__':main()
