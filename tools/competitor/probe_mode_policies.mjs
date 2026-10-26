// Execute three unchanged mode-policy bodies. Static fields, config lookups and
// list access are host fixtures; this does not run complete mode initialization.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import createWabt from '../../competitor-analysis/artifacts/competitor-tools/wabt/index.js';

const source = path.resolve('competitor-analysis/artifacts/competitor-config-trace/methods');
const output = path.resolve('competitor-analysis/artifacts/competitor-20261023-tests');
fs.mkdirSync(output, { recursive: true });
const wat = fs.readFileSync(path.join(source, 'selected.wat'), 'utf8');
const forms = wat.split(/(?=^  \()/m);
const names = ['$j94024', '$j94025', '$j94031'];
const bodies = names.map(n => forms.find(f => f.startsWith(`  (func ${n} `)).trimEnd());
const types = forms.filter(f => f.startsWith('  (type ')).join('');
const text = `(module
${types}
 (import "host" "init" (func $j922 (param i32)))
 (import "host" "classInit" (func $j923 (param i32)))
 (import "host" "common" (func $j3510 (param i32 i32) (result i32)))
 (import "host" "pvp" (func $j21443 (param i32) (result i32)))
 (import "host" "groupBattle" (func $j5748 (param i32) (result i32)))
 (import "host" "getItem" (func $j947 (param i32 i32 i32) (result i32)))
 (memory (export "memory") 100)
 ${bodies.join('\n')}
 (export "target" (func $j94024))
 (export "fast" (func $j94025))
 (export "time" (func $j94031))
)`;
const wabt = await createWabt();
const module = wabt.parseWat('mode-policies.wat', text);
module.resolveNames(); module.validate();
const binary = module.toBinary({ write_debug_names: true }).buffer;
module.destroy();
let groupBattle = 0;
const { instance } = await WebAssembly.instantiate(binary, { host: {
  init() {}, classInit() {}, common: () => 900, pvp: () => 120,
  groupBattle: () => groupBattle, getItem: () => 40000
} });
const memory = new DataView(instance.exports.memory.buffer);
const put = (at, value) => memory.setInt32(at, value, true);
const metadata = JSON.parse(fs.readFileSync('competitor-analysis/artifacts/competitor-config-trace/dumper/script.json', 'utf8')).ScriptMetadata;
const statics = {};
['LevelManager', 'EndlessLevelMa', 'SeasonLevelMa', 'ConfigManager', 'GroupBattleManager', 'PVPManager'].forEach((name, i) => {
  const slot = metadata.find(m => m.Name === `${name}_TypeInfo`).Address;
  const type = 200000 + i * 4096, fields = type + 512;
  put(slot, type); put(type + 92, fields); statics[name] = fields;
});
put(10000 + 16, 20000); put(20000 + 24, 30000);
put(40000 + 56, 50000); put(50000 + 16, 180);
const modes = { MainLevel: 0, OneScreenBattle: 1, TeachScene: 2, OnlineBaseGame: 3,
  NewYearLevel: 4, FruitSpLevel: 5, BaseSpLevel: 6, PVPGame: 7,
  MonopolyMiniGame: 8, SeasonLevel: 9, SpModeLevel: 10, EndlessLevel: 20 };
const cases = [];
for (const [name, code] of Object.entries(modes)) for (let endless = 0; endless < 4; endless++) for (let season = 0; season < 4; season++) {
  put(statics.LevelManager + 12, code); put(statics.EndlessLevelMa + 12, endless); put(statics.SeasonLevelMa + 20, season);
  const expectedTarget = Number(code === 20 && endless === 0 || code === 9 && season === 0);
  const expectedFast = Number(Boolean(expectedTarget) || code === 9 && season === 3);
  const expectedTime = code === 3 ? 900 : code === 7 ? 120 : 180;
  const target = instance.exports.target(10000, 0), fast = instance.exports.fast(10000, 0), time = instance.exports.time(10000, 0);
  assert.equal(target, expectedTarget); assert.equal(fast, expectedFast); assert.equal(time, expectedTime);
  cases.push({ mode: name, code, endlessWinType: endless, seasonWinType: season, target, fast, time });
}
groupBattle = 1;
let extraChecks = 0;
for (const code of [0, 1, 9, 20]) for (const time of [0, 60]) {
  put(statics.LevelManager + 12, code); put(statics.GroupBattleManager + 24, time);
  assert.equal(instance.exports.time(10000, 0), Math.max(1, time)); extraChecks++;
}
fs.writeFileSync(path.join(output, 'mode-policies.wasm'), binary);
fs.writeFileSync(path.join(output, 'mode-policy-cases.json'), JSON.stringify(cases, null, 2) + '\n');
const report = { passed: true, originalMethodBodies: names, modeConfigurations: cases.length,
  checks: cases.length * 3 + extraChecks, sha256: createHash('sha256').update(binary).digest('hex'),
  scope: 'Original target/fast-create/time routing helpers only. 900/120/180 are host sentinels, not recovered runtime durations. Mode initialization, networking and scene play are not executed.' };
fs.writeFileSync(path.join(output, 'mode-policy-probe.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
