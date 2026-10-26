// Validate selected compiled bodies without instantiating the game module.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import createWabt from '../../work/competitor-tools/wabt/index.js';

const folder = path.resolve(process.argv[2] || 'work/competitor-deep');
const methods = JSON.parse(fs.readFileSync(path.join(folder, 'method-map.json'), 'utf8'));
const wabt = await createWabt();
const parsed = wabt.parseWat('selected.wat', fs.readFileSync(path.join(folder, 'selected.wat'), 'utf8'));
parsed.resolveNames();
parsed.validate();
const binary = parsed.toBinary({ write_debug_names: true }).buffer;
parsed.destroy();
if (!WebAssembly.validate(binary)) throw new Error('Engine WASM validation failed');
fs.writeFileSync(path.join(folder, 'selected.wasm'), binary);
const report = {
  passed: true, methodCount: methods.length, uniqueFunctionBodies: new Set(methods.map(m => m.wasmSymbol)).size,
  signatureMatched: methods.every(m => m.signatureVerified && m.bodyRecovered),
  bytes: binary.length, sha256: createHash('sha256').update(binary).digest('hex'),
  scope: 'WABT names/types/control flow and JS engine validation only; dependency imports are unresolved and the module is not instantiated.'
};
fs.writeFileSync(path.join(folder, 'selected-validation.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
