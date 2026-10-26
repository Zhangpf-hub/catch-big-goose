import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
const folder = path.resolve(process.argv[2]);
const validator = createRequire(import.meta.url)(process.env.GLTF_VALIDATOR_MODULE || 'D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const manifest = JSON.parse(fs.readFileSync(path.join(folder, 'manifest.json'), 'utf8'));
const results = [];
for (const model of manifest.models) {
  const file = path.join(folder, 'models', model.id, `${model.id}.glb`), raw = fs.readFileSync(file);
  const result = await validator.validateBytes(new Uint8Array(raw), { uri: `${model.id}.glb`, maxIssues: 100 });
  results.push({ id: model.id, bytes: raw.length, sha256: createHash('sha256').update(raw).digest('hex'), issues: result.issues });
}
const report = { passed: results.every(r => r.issues.numErrors === 0 && r.issues.numWarnings === 0), models: results };
fs.writeFileSync(path.join(folder, 'gltf-validation.json'), JSON.stringify(report, null, 2) + '\n');
console.log('Reference GLBs:', results.length, 'errors:', results.reduce((s, r) => s + r.issues.numErrors, 0), 'warnings:', results.reduce((s, r) => s + r.issues.numWarnings, 0));
if (!report.passed) process.exitCode = 1;
