"""Compact public configuration evidence and split-table edges; no user values."""
import hashlib
import json
import re
from pathlib import Path
from recover_methods import read_forms

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/competitor-runtime-trace'
SCRIPT = json.loads((ROOT / 'work/competitor-config-trace/dumper/script.json').read_text('utf-8'))

def write(name, data):
    (WORK / name).write_text(json.dumps(data, ensure_ascii=False, indent=2), 'utf-8')

def main():
    slots, types = {}, {}
    modules = [('primary', ROOT / 'work/competitor-config-trace/main-402.wat'),
               ('secondary', ROOT / 'work/competitor-config-trace/secondary-402.wat')]
    for module, path in modules:
        signatures = {}
        for form in read_forms(path):
            if form.startswith('  (type '):
                signatures[form.split()[1]] = re.sub(r'\$t\d+', '', form).strip()
            elif form.startswith('  (func '):
                symbol = form.split()[1]
                types[module, symbol] = signatures[re.search(r'\(type (\S+)\)', form)[1]]
                if module == 'primary' and symbol == '$j3816':
                    (WORK / 'GetHotFixData-sret.watfrag').write_text(form, 'utf-8')
            elif form.startswith('  (elem '):
                start = int(re.search(r'i32.const (\d+)', form)[1])
                names = form.split(' func ', 1)[1].strip().removesuffix(')').split()
                for i, symbol in enumerate(names):
                    # Secondary active elements overwrite split stubs at the same slot.
                    slots[start + i] = dict(module=module, symbol=symbol)
    names = {}
    for m in SCRIPT['ScriptMethod']:
        names.setdefault(m['Address'], []).append(m['Name'])
    edges = []
    for module, _ in modules:
        for p in (WORK / f'{module}-methods').glob('*.watfrag'):
            lines = p.read_text('utf-8').splitlines()
            for i, line in enumerate(lines):
                if 'call_indirect' not in line or i == 0:
                    continue
                # Only literal immediately preceding the call is statically resolved.
                match = re.fullmatch(r'\s*i32.const (\d+)\s*', lines[i-1])
                if not match:
                    continue
                slot = int(match[1]); target = slots.get(slot)
                if not target:
                    continue
                edges.append(dict(callerModule=module, caller=p.stem, line=i+1,
                                  slot=slot, target=target, aliases=names.get(slot, []),
                                  evidence='literal table index immediately before call_indirect; no dynamic dispatch inference'))
    write('constant-table-call-edges.json', edges)
    write('patch-slot-identification.json', [dict(slot=s, target=slots.get(s), aliases=names.get(s, []),
        limitation='Cache index list proves index presence only; not proof of executed patch body') for s in [47221, 92122]])
    raw = json.loads((WORK/'runtime-objects/ServerFileCreate-135.json').read_text('utf-8'))
    fields = {k:v for k,v in raw.items() if k not in ['serializationData', '_path'] and not k.startswith('m_')}
    write('bundled-server-config.json', fields)
    print(json.dumps(dict(patch=[dict(slot=s,names=names.get(s,[])) for s in [47221,92122]],
                         constantEdges=len(edges), bundledFields=fields), ensure_ascii=True))

if __name__ == '__main__':
    main()
