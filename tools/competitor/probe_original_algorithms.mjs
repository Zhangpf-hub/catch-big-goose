// Execute only five recovered scalar/state functions in a memory-only WASM sandbox.
// Host imports model Unity RNG and IL2CPP list/field access; no game initialization,
// network, filesystem, wx APIs or other gameplay functions are exposed to the module.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import assert from 'node:assert/strict';
import createWabt from '../../competitor-analysis/artifacts/competitor-tools/wabt/index.js';

const source = path.resolve(process.argv[2] || 'competitor-analysis/artifacts/competitor-deep');
const output = path.resolve(process.argv[3] || 'competitor-analysis/artifacts/competitor-algorithm-tests');
fs.mkdirSync(output, { recursive: true });
const names = ['$j22249', '$j18335', '$j95576', '$j95581', '$j95582'];
const wat = fs.readFileSync(path.join(source, 'selected.wat'), 'utf8');
const forms = wat.split(/(?=^  \()/m);
const bodies = names.map(n => {
  const body = forms.find(f => f.startsWith(`  (func ${n} `));
  assert(body, n);
  return body.replace(/\(type \$t\d+\)/, '').trimEnd();
});
// Only these two original functions use type t8 for generic dispatch.
const moduleText = `(module
 (type $t8 (func (param i32 i32 i32 i32 i32)))
 (import "host" "init" (func $j922 (param i32)))
 (import "host" "range" (func $j1305 (param f32 f32 i32) (result f32)))
 (import "host" "type" (func $j926 (param i32 i32) (result i32)))
 (import "host" "count" (func $j954 (param i32 i32 i32) (result i32)))
 (import "host" "get" (func $j1263 (param i32 i32 i32 i32) (result i32)))
 (import "host" "setSum" (func $j43257 (param i32 i32 f32 i32)))
 (import "host" "getSum" (func $j4080 (param i32 i32 i32) (result f32)))
 (memory (export "memory") 80)
 (global $__wasm_split_waitTableId (mut i32) (i32.const 0))
 (table $primary.table 2 funcref)
 (func $dispatch (type $t8) (param i32) (param $mi i32) (param $obj i32) (param i32) (param i32)
   local.get $mi i32.const 6000 i32.eq
   if local.get $obj local.get $mi call $j95581
   else local.get $obj local.get $mi call $j95582 end)
 (elem (i32.const 1) $dispatch)
 ${bodies.join('\n')}
 (export "depth" (func $j22249))
 (export "linear" (func $j18335))
 (export "roll" (func $j95576))
)`;
const wabt = await createWabt();
const parsed = wabt.parseWat('isolated-original.wat', moduleText);
parsed.resolveNames(); parsed.validate();
const binary = parsed.toBinary({ write_debug_names: true }).buffer;
parsed.destroy();
fs.writeFileSync(path.join(output, 'isolated-original.wasm'), binary);
let unit = .5, data = [], sums = [];
const instance = await WebAssembly.instantiate(binary, { host: {
  init() {}, range: (min, max) => Math.fround(min + Math.fround((max - min) * unit)),
  type: () => 10000,
  count: () => data.length,
  get: (_fn, _mi, _list, i) => data[i],
  setSum: (_list, i, value) => { sums[i] = value; }, getSum: (_list, i) => sums[i],
} });
const api = instance.instance.exports, mem = new DataView(api.memory.buffer);
const i32 = (p, v) => mem.setInt32(p, v, true), f32 = (p, v) => mem.setFloat32(p, v, true);
// Runtime-class math epsilon used by Mathf.Approximately in the original function.
i32(3958628, 14000); i32(14000 + 92, 15000); f32(15000, 1.401298464324817e-45);
const cases = [];
for (const [left, right] of [[1, 1], [0, 1], [.2, 1], [.5, 2]])
  for (let i = 0; i <= 100; i++) {
    unit = i / 100;
    const result = api.linear(-2, 3, left, right, 0);
    assert(Number.isFinite(result)); cases.push(['linear', left, right, unit, result]);
  }
for (let i = 0; i <= 100; i++) for (const mul of [.75, 1]) {
  const top = i / 40;
  f32(1024 + 348, 2); f32(1024 + 264, top); f32(1024 + 340, .4); f32(1024 + 344, .6);
  cases.push(['depth', top, mul, 0, api.depth(1024, 1, mul, 0)]);
}
const traces = [];
let negativeProbabilityStates = 0;
for (const weights of [[.25, .5, .25], [.25, .25, .25, .25], [0, .5, .5], [1]]) {
  const obj = 1024, klass = 5000, context = 8000, fields = 12000;
  new Uint8Array(api.memory.buffer, obj, 64).fill(0);
  i32(obj + 8, 20000); i32(obj + 12, 21000);
  for (const mi of [4096, 6000, 7000]) { i32(mi, 0); i32(mi + 8, 1); i32(mi + 16, klass); }
  i32(klass + 96, context); i32(context + 32, 9000); i32(context + 40, 9100);
  i32(context + 92, 6000); i32(context + 96, 7000);
  i32(10000 + 64, fields);
  for (let index = 0; index < 4; index++) {
    i32(fields + 12 + index * 20, 8 + index * 4);
    i32(fields + 8 + index * 20, 16000); i32(16000 + 20, 0);
  }
  data = weights.map((w, index) => {
    const pointer = 30000 + index * 64;
    f32(pointer + 8, w); f32(pointer + 12, w); f32(pointer + 16, 0); i32(pointer + 20, 0);
    return pointer;
  });
  sums = [];
  let state = 104729;
  for (let turn = 0; turn < 512; turn++) {
    state ^= state << 13; state ^= state >>> 17; state ^= state << 5;
    unit = Math.fround((state >>> 0) / 4294967296);
    const index = api.roll(obj, 4096);
    assert(index >= 0 && index < weights.length);
    const probabilities = data.map(p => mem.getFloat32(p + 12, true));
    assert(probabilities.every(p => Number.isFinite(p)),
      JSON.stringify({ weights, turn, index, probabilities, transfer: mem.getFloat32(obj + 24, true), hits: data.map(p => mem.getInt32(p + 20, true)) }));
    if (probabilities.some(p => p < 0 || p > 1)) negativeProbabilityStates++;
    traces.push([weights.join(';'), unit, index, probabilities.join(';'), data.map(p => mem.getInt32(p + 20, true)).join(';')]);
  }
}
fs.writeFileSync(path.join(output, 'original-cases.csv'), cases.map(r => r.join(',')).join('\n'));
fs.writeFileSync(path.join(output, 'original-weight-traces.csv'), traces.map(r => r.join(',')).join('\n'));
fs.writeFileSync(path.join(output, 'wasm-probe.json'), JSON.stringify({
  passed: true, numericCases: cases.length, weightDraws: traces.length,
  directHelperOutOfRangeStates: negativeProbabilityStates,
  caveat: 'RollIndex is invoked directly. This probe does not model Roll/Check/RemoveItem call lifecycle and does not prove a defect in the shipped game.',
  moduleSha256: createHash('sha256').update(binary).digest('hex'),
  scope: 'Five original WASM bodies; Unity RNG, IL2CPP field descriptors and list access are host test adapters. Not full-game execution.',
}, null, 2));
console.log(`Original WASM probe: ${cases.length} numeric cases, ${traces.length} weighted draws`);
