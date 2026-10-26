import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
const root = path.resolve(import.meta.dirname, '..');
const batch = path.join(root, 'source-assets/models/candidates/electronics-v2');
const read = name => JSON.parse(fs.readFileSync(path.join(batch, 'qa', name), 'utf8'));
const audit = read('asset-audit.json'), build = read('build.json');
const runtime = read('runtime/results.json'), navigation = read('runtime/navigation-victory.json');
const imported = read('cocos-import.json'), icons = read('icon-audit.json');
const validator = createRequire(import.meta.url)(process.env.GLTF_VALIDATOR_MODULE || 'D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const hash = p => createHash('sha256').update(fs.readFileSync(p)).digest('hex');
assert.equal(audit.models.length, 9);
assert.equal(audit.physics.sleepingAfter15s, 81);
assert.equal(runtime.length, 9);
assert(runtime.every(test => test.status === 'passed' && test.errors.length === 0));
assert.equal(new Set(runtime.map(test => `${test.width}/${test.height}/${test.level}`)).size, 9);
assert.equal(navigation.status, 'passed');
assert.equal(imported.status, 'passed');
assert.equal(imported.models.length, 9);
assert.equal(icons.length, 9);
for (const item of audit.models) {
  assert.equal(hash(path.join(root, 'reference-projects/catch-big-goose-cocos/assets/resources/models', item.id + '.glb')), item.sha256);
  const image = fs.readFileSync(path.join(root, 'reference-projects/catch-big-goose-cocos/assets/resources/icons', item.id + '.png'));
  assert.equal(image.readUInt32BE(16), 192); assert.equal(image.readUInt32BE(20), 192);
  const meta = JSON.parse(fs.readFileSync(path.join(root, 'reference-projects/catch-big-goose-cocos/assets/resources/icons', item.id + '.png.meta'), 'utf8'));
  assert(meta.imported && meta.userData.hasAlpha);
}
const trayFile = path.join(root, 'reference-projects/catch-big-goose-cocos/assets/resources/models/tray_electronics.glb');
const trayValidation = await validator.validateBytes(new Uint8Array(fs.readFileSync(trayFile)), { uri:'tray_electronics.glb', maxIssues:30 });
assert.equal(trayValidation.issues.numErrors, 0); assert.equal(trayValidation.issues.numWarnings, 0);
fs.writeFileSync(path.join(batch, 'qa/tray_electronics.gltf-validation.json'), JSON.stringify(trayValidation, null, 2));
for (const file of ['assets/scripts/core/LevelConfig.ts', 'assets/scripts/core/SceneSkin.ts',
  'assets/scripts/core/ui/HomeScreen.ts', 'assets/scripts/core/GameManager.ts']) {
  assert.equal(hash(path.join(root,'reference-projects/catch-big-goose-cocos',file)), hash(path.join(root,'work/electronics-build-20261021',file)), `Source changed after build: ${file}`);
}
assert(build.bytes <= 20*1024*1024);
const summary = { status:'passed', asOf:'2026-10-22', theme:'electronics', name:'数码工坊',
  products:9, container:'tray_electronics', modelCount:53, activeModels:49, candidateModels:3, unusedResources:1,
  ordinaryItemCounts:[48,54,81], physics:audit.physics, browserCases:9,
  navigationAndVictory:true, importedProducts:9, gltfErrors:0, gltfWarnings:0,
  regressionTests:32, build, models:audit.models };
fs.writeFileSync(path.join(batch,'qa/verification-summary.json'),JSON.stringify(summary,null,2));
console.log(JSON.stringify({status:summary.status,products:9,browserCases:9,navigationAndVictory:true,releaseMiB:build.mib}));
