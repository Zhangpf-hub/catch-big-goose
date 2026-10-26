// node audit_assets.mjs --project <root> --candidate <batch> --validator <module path>
// Uses the project's real hull sampler and JoltWorld; only Cocos math/platform objects are adapted.
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';

const args = Object.fromEntries(process.argv.slice(2).reduce((rows, item, index, all) => {
  if (item.startsWith('--')) rows.push([item.slice(2), all[index + 1]]);
  return rows;
}, []));
assert(args.project && args.candidate && args.validator, 'Require --project, --candidate and --validator');
const project = resolve(args.project), candidate = resolve(args.candidate);
const require = createRequire(import.meta.url);
const validator = require(resolve(args.validator));
const three = await import(pathToFileURL(join(project, 'node_modules/three/build/three.module.js')));
const { Vector3, Quaternion, Matrix4, Euler } = three;

function parseGLB(path) {
  const buffer = readFileSync(path);
  assert.equal(buffer.toString('ascii', 0, 4), 'glTF');
  assert.equal(buffer.readUInt32LE(4), 2);
  assert.equal(buffer.readUInt32LE(8), buffer.length);
  const jsonSize = buffer.readUInt32LE(12);
  const document = JSON.parse(buffer.subarray(20, 20 + jsonSize));
  const binStart = 20 + jsonSize;
  const bin = buffer.subarray(binStart + 8, binStart + 8 + buffer.readUInt32LE(binStart));
  function positions(index) {
    const a = document.accessors[index], view = document.bufferViews[a.bufferView];
    assert.equal(a.componentType, 5126);
    assert.equal(a.type, 'VEC3');
    assert(!a.sparse);
    const base = (a.byteOffset || 0) + (view.byteOffset || 0);
    const result = new Float32Array(a.count * 3);
    for (let i = 0; i < a.count; i++) for (let c = 0; c < 3; c++) {
      result[i * 3 + c] = bin.readFloatLE(base + i * (view.byteStride || 12) + c * 4);
    }
    return result;
  }
  const renderers = [];
  function walk(index, parent) {
    const n = document.nodes[index];
    const local = n.matrix ? new Matrix4().fromArray(n.matrix) : new Matrix4().compose(
      new Vector3().fromArray(n.translation || [0, 0, 0]),
      new Quaternion().fromArray(n.rotation || [0, 0, 0, 1]),
      new Vector3().fromArray(n.scale || [1, 1, 1]));
    const matrix = parent.clone().multiply(local);
    if (n.mesh !== undefined) {
      const primitives = document.meshes[n.mesh].primitives;
      const arrays = primitives.map(p => positions(p.attributes.POSITION));
      renderers.push({ node: { name: n.name, worldMatrix: matrix }, mesh: {
        struct: { primitives }, readAttribute: (sub) => arrays[sub],
      } });
    }
    for (const child of n.children || []) walk(child, matrix);
  }
  for (const node of document.scenes[document.scene || 0].nodes) walk(node, new Matrix4());
  const points = renderers.flatMap(r => r.mesh.struct.primitives.flatMap((_, index) => {
    const p = r.mesh.readAttribute(index), values = [];
    for (let i = 0; i < p.length; i += 3) values.push(new Vector3(p[i], p[i + 1], p[i + 2]).applyMatrix4(r.node.worldMatrix));
    return values;
  }));
  const bounds = [0, 1, 2].map(i => {
    const values = points.map(p => p.getComponent(i));
    return [Math.min(...values), Math.max(...values)];
  });
  const triangles = (document.meshes || []).reduce((t, m) => t + m.primitives.reduce((s, p) =>
    s + document.accessors[p.indices ?? p.attributes.POSITION].count / 3, 0), 0);
  return { buffer, document, renderers, bounds, metrics: {
    bytes: buffer.length, triangles, materials: document.materials?.length || 0,
    primitives: document.meshes.reduce((n, m) => n + m.primitives.length, 0),
    size: bounds.map(([a, b]) => b - a), center: bounds.map(([a, b]) => (a + b) / 2),
    sha256: createHash('sha256').update(buffer).digest('hex'),
  } };
}

class Vec3 extends Vector3 {
  static copy(out, v) { return out.copy(v); }
  static lerp(out, a, b, t) { return out.copy(a).lerp(b, t); }
  static transformMat4(out, p, m) { return out.copy(p).applyMatrix4(m); }
}
class Quat extends Quaternion {
  static copy(out, q) { return out.copy(q); }
  static slerp(out, a, b, t) { return out.copy(a).slerp(b, t); }
  static fromEuler(out, x, y, z) {
    return out.setFromEuler(new Euler(x * Math.PI / 180, y * Math.PI / 180, z * Math.PI / 180));
  }
}
class Mat4 extends Matrix4 {
  static invert(out, m) { return out.copy(m).invert(); }
  static multiply(out, a, b) { return out.multiplyMatrices(a, b); }
}

const { loadCore } = await import(pathToFileURL(join(project, 'tests/helpers/load-core.mjs')));
const JoltModule = await import(pathToFileURL(join(project, 'cocos/node_modules/jolt-physics/dist/jolt-physics.wasm-compat.js')));
const J = await JoltModule.default();
const warnings = [];
const qaConsole = { log: (...v) => console.log(...v), error: (...v) => warnings.push(v.join(' ')), warn: (...v) => warnings.push(v.join(' ')) };
const { JoltWorld, extractHullPoints } = loadCore('JoltWorld', {
  cc: { Node: class {}, Mesh: class {}, MeshRenderer: class {}, gfx: { AttributeName: { ATTR_POSITION: 'position' } },
    v3: (x = 0, y = 0, z = 0) => new Vec3(x, y, z), Vec3, Quat, Mat4, geometry: {} },
  modules: { './JoltLoader': { loadJolt: async () => J } }, globals: { console: qaConsole },
});

const baseline = readdirSync(join(project, 'cocos/assets/resources/models')).filter(f => f.endsWith('.glb'))
  .map(f => ({ id: f.slice(0, -4), ...parseGLB(join(project, 'cocos/assets/resources/models', f)).metrics }));
const files = readdirSync(join(candidate, 'models')).filter(f => f.endsWith('.glb') && !f.startsWith('tray_')).sort();
assert(files.length > 0, 'No candidates');
const rows = [];
const world = new JoltWorld();
await world.init(-9.81);
world.addStaticBox(new Vec3(0, -.10, 0), new Vec3(8, .20, 8), 0, .55, .02);
for (const [x, z, sx, sz] of [[-3, 0, .2, 6], [3, 0, .2, 6], [0, -3, 6, .2], [0, 3, 6, .2]]) {
  world.addStaticBox(new Vec3(x, 1.5, z), new Vec3(sx, 3, sz), 0, 1.25, .08);
}
const bodies = [];
for (const [index, file] of files.entries()) {
  const id = file.slice(0, -4), path = join(candidate, 'models', file);
  const parsed = parseGLB(path), { metrics, document } = parsed;
  const validation = await validator.validateBytes(new Uint8Array(parsed.buffer), { uri: file, maxIssues: 100 });
  writeFileSync(join(candidate, 'qa', `${id}.gltf-validation.json`), JSON.stringify(validation, null, 2));
  assert.equal(validation.issues.numErrors, 0, `${id}: glTF errors`);
  assert.equal(validation.issues.numWarnings, 0, `${id}: glTF warnings`);
  assert(Math.abs(Math.max(...metrics.size) - 1) < 1e-4, `${id}: maximum edge`);
  assert(Math.max(...metrics.center.map(Math.abs)) < 1e-4, `${id}: center`);
  assert(Math.min(...metrics.size) >= .08 && metrics.triangles <= 6000 && metrics.bytes <= 262144);
  assert.equal(metrics.materials, 1);
  assert.equal(metrics.primitives, 1);
  assert(!document.cameras && !document.animations && !document.skins);
  assert(!(document.extensionsRequired || []).length);
  for (const material of document.materials) {
    const pbr = material.pbrMetallicRoughness;
    assert.equal(pbr.metallicFactor, 0);
    assert((pbr.roughnessFactor ?? 1) >= .45 && (pbr.roughnessFactor ?? 1) <= .75);
    assert((material.alphaMode || 'OPAQUE') === 'OPAQUE' && !material.doubleSided);
    assert(!pbr.metallicRoughnessTexture && !material.normalTexture);
    assert(!(material.extensions && Object.keys(material.extensions).length));
  }
  const root = { worldMatrix: new Mat4(), updateWorldTransform() {}, getComponentsInChildren: () => parsed.renderers };
  const hull = extractHullPoints(root, .65);
  assert(hull.length >= 12);
  const settings = new J.ConvexHullShapeSettings();
  for (let i = 0; i < hull.length; i += 3) {
    const v = new J.Vec3(hull[i], hull[i + 1], hull[i + 2]);
    settings.mPoints.push_back(v);
    J.destroy(v);
  }
  settings.mMaxConvexRadius = .01;
  const result = settings.Create();
  assert(!result.HasError(), `${id}: Jolt convex hull failed`);
  J.destroy(result);
  J.destroy(settings);
  for (let copy = 0; copy < 9; copy++) {
    const node = { name: `${id}_${copy}`, isValid: true, setWorldPosition() {}, setWorldRotation() {} };
    const rotation = new Quat().setFromEuler(new Euler(.17 * copy, .37 * copy, .12 * copy));
    const key = world.spawn(node, { shape: { kind: 'hull', points: hull }, mass: .9,
      linearDamping: .06, angularDamping: .3, friction: 1.25, restitution: .08, useCCD: true,
      position: new Vec3((index - (files.length - 1) / 2) * Math.min(.83, 4.3 / files.length),
        1 + Math.floor(copy / 3) * .85, (copy % 3 - 1) * .85),
      rotation, linearVelocity: new Vec3(0, -2, 0), angularVelocity: new Vec3(.2, .3, .1) });
    bodies.push({ id, key });
  }
  rows.push({ id, ...metrics, validatorErrors: validation.issues.numErrors,
    validatorWarnings: validation.issues.numWarnings, hullPoints: hull.length / 3,
    convexHullPassed: true });
}
for (let step = 0; step < 1800; step++) {
  world.step(1 / 120);
  world.syncNodes(1);
  for (const { key, id } of bodies) {
    const p = new Vec3();
    assert(world.getPosition(key, p));
    assert([p.x, p.y, p.z].every(Number.isFinite) && p.y > -.1 && Math.abs(p.x) < 3.4 && Math.abs(p.z) < 3.4,
      `${id}: escaped container at step ${step}: ${p.toArray()}`);
  }
}
for (const row of rows) {
  const group = bodies.filter(b => b.id === row.id);
  row.sleepingAfter15s = group.filter(b => world.isAsleep(b.key)).length;
  assert.equal(row.sleepingAfter15s, 9, `${row.id}: pile failed to sleep`);
  for (const { key } of group) {
    const p = new Vec3(); world.getPosition(key, p);
    assert.equal(world.raycast({ o: new Vec3(p.x, 6, p.z), d: new Vec3(0, -1, 0) }, 10) > 0, true);
  }
}
const before = world.liveCount;
for (const { key } of bodies.filter(b => b.id === rows[0].id).slice(0, 3)) world.remove(key);
assert.equal(world.liveCount, before - 3);
for (let step = 0; step < 600; step++) world.step(1 / 120);
assert.deepEqual(warnings, []);
const report = { schemaVersion: 1, validationScope: 'GLB + Khronos validator + real project hull sampler and JoltWorld with Cocos math adapter',
  cocosEditorImport: 'separate verification required',
  physics: { engine: 'Jolt 1.1.0 WASM', bodyCount: bodies.length, simulatedSeconds: 20,
    fixedStep: 1 / 120, sleepingAfter15s: rows.reduce((n, row) => n + row.sleepingAfter15s, 0), containmentPassed: true, raycastPassed: true,
    removalPassed: true, warnings }, baseline, models: rows };
mkdirSync(join(candidate, 'qa'), { recursive: true });
writeFileSync(join(candidate, 'qa', 'asset-audit.json'), JSON.stringify(report, null, 2));
world.clearBodies(); world.clearStatics();
console.log(JSON.stringify({ status: 'PASS', models: rows, physics: report.physics }, null, 2));
