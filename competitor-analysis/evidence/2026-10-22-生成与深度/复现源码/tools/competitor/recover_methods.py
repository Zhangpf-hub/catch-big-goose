"""Map IL2CPP pointers through the real WASM table, reject signature mismatches.

Build a small, non-executable analysis module for WABT decompilation. Dependencies
remain imports; this is not recovered C# and does not run any game code.
"""
import argparse
import json
import re
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--wat', type=Path, required=True)
    ap.add_argument('--script', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--deep', action='store_true', help='Also inspect state transitions, height frontier and random initialization')
    a = ap.parse_args()
    methods = json.loads(a.script.read_text(encoding='utf-8'))['ScriptMethod']
    lines = a.wat.read_text(encoding='utf-8').splitlines(True)
    forms, block = [], []
    for line in lines[1:]:
        if line.startswith('  ('):
            if block:
                forms.append(''.join(block))
            block = [line]
        else:
            block.append(line)
    if block:
        forms.append(''.join(block).removesuffix(')\n'))
    types, imports, env, functions, elements = [], [], [], {}, {}
    signatures = {}
    for form in forms:
        if form.startswith('  (type '):
            types.append(form)
            name = form.split()[1]
            result = re.findall(r'\(result (\w+)\)', form)
            params = re.findall(r'\(param ([^)]+)\)', form)
            signatures[name] = (result[0][0] if result else 'v') + ''.join(v[0] for v in ' '.join(params).split())
        elif form.startswith('  (import '):
            imports.append(form)
        elif form.startswith(('  (global ', '  (memory ', '  (table ')):
            env.append(form)
        elif form.startswith('  (func '):
            functions[form.split()[1]] = form
        elif form.startswith('  (elem '):
            start = int(re.search(r'i32.const (\d+)', form)[1])
            # Identifiers may contain another '$'; whitespace is the actual delimiter.
            names = form.split(' func ', 1)[1].strip().removesuffix(')').split()
            elements.update({start + i: name for i, name in enumerate(names)})
    method_names = {}
    for method in methods:
        if method['Address'] in elements:
            method_names.setdefault(elements[method['Address']], method['Name'])
    wanted = {'CreateLevel', 'CreateUnitObj', 'CheckRigid', 'CheckVisible', 'GetDynamicVisibleHeight',
              'GetMainLevelABOffsetTypeCount', 'GetMainLevelABOffsetGroupCount', 'GetTriple', 'GetUnit',
              'GetTimeABIndex', 'GetObjSize'}
    selected = []
    for m in methods:
        cls, name = m['Name'].split('$$', 1)
        if ((cls == 'LevelManager' and name in wanted)
            or ('LevelManager.<LoopCreateObj>' in cls and name == 'MoveNext')
            or ('LevelManager.<LoopOptimization>' in cls and name == 'MoveNext')
            or (cls == 'ValueManager' and name.startswith('GetWeight'))
            or ('Kunpo.KFakeRandom<' in cls and name in {'RollIndex', 'RealRandomRollIndex', 'AllocPro', 'CalProToAlloc'})
            or (a.deep and cls == 'LevelManager' and name in {'.ctor', 'CheckAllRigidAndVisible', 'CheckObjMaxHeight', 'CaculateMaxHeight', 'SetMinTouchHeight', 'GetMinTouchHeight', 'SetMaxHeight', 'GetMaxHeight'})
            or (a.deep and cls == 'ObjectUnit' and name in {'.ctor', 'HideRigid', 'SetRigid', 'SetVisible', 'CanBeSelect', 'FinishCreate', 'SetBaseValue'})
            or (a.deep and 'Kunpo.KFakeRandom<' in cls and name in {'.ctor', 'AddItem', 'Check', 'RemoveItem', 'Roll'})
            or (a.deep and 'KFakeRandom.Data<' in cls and name == '.ctor')):
            selected.append(dict(m))
    chosen, mapping, rejected = {}, [], []
    for method in selected:
        symbol = elements.get(method['Address'])
        body = functions.get(symbol, '')
        if not body:
            continue
        type_name = re.search(r'\(type (\S+)\)', body)[1]
        signature = signatures[type_name]
        if signature != method['TypeSignature'] or symbol.startswith('$redir_'):
            rejected.append(dict(name=method['Name'], expected=method['TypeSignature'], actual=signature,
                                 reason='Signature mismatch or unresolved split stub; not interpreted'))
            continue
        chosen[symbol] = body
        method.update(wasmSymbol=symbol, signatureVerified=True, bodyRecovered=True)
        mapping.append(method)
    dependencies = set()
    for body in chosen.values():
        dependencies.update(re.findall(r'\bcall (\$[^\s)]+)', body))
    extra_imports = []
    for symbol in sorted(dependencies - set(chosen)):
        if symbol in functions:
            type_name = re.search(r'\(type (\S+)\)', functions[symbol])[1]
            readable = method_names.get(symbol, symbol[1:])
            readable = re.sub(r'[^a-zA-Z0-9_]', '_', readable)
            extra_imports.append(f'  (import "dependency" "{readable}" (func {symbol} (type {type_name})))\n')
    module = '(module\n' + ''.join(types + imports + extra_imports + env + list(chosen.values())) + ')\n'
    a.output.mkdir(parents=True, exist_ok=True)
    (a.output / 'selected.wat').write_text(module, encoding='utf-8')
    (a.output / 'method-map.json').write_text(json.dumps(mapping, ensure_ascii=False, indent=2), encoding='utf-8')
    (a.output / 'rejected-methods.json').write_text(json.dumps(rejected, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Recovered compiled bodies with matching WASM signatures:', len(mapping))


if __name__ == '__main__':
    main()
