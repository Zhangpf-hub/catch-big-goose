import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
const root=path.resolve('source-assets/models/candidates/duck-series-v1/model-review-v1');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const results=[];
for(const id of ['duck-eggtart','duck-steelcup','duck-numberblock']){
  const raw=fs.readFileSync(path.join(root,'models',id,id+'.glb'));
  const g=JSON.parse(raw.subarray(20,20+raw.readUInt32LE(12)).toString());
  const primitives=g.meshes.flatMap(m=>m.primitives);
  const triangles=primitives.reduce((n,p)=>n+g.accessors[p.indices].count/3,0);
  const validation=await validator.validateBytes(new Uint8Array(raw),{uri:id+'.glb',maxIssues:100});
  const geometry=JSON.parse(fs.readFileSync(path.join(root,'qa',id+'-geometry.json')));
  const checks={oneMesh:g.meshes.length===1,onePrimitive:primitives.length===1,oneMaterial:g.materials.length===1,triangles:triangles<=6000,bytes:raw.length<=256*1024,noAnimation:!g.animations,noSkin:!g.skins,uv:primitives.every(p=>p.attributes.TEXCOORD_0!==undefined),noErrors:validation.issues.numErrors===0,noWarnings:validation.issues.numWarnings===0,roundtripGeometry:geometry.passed};
  const report={id,passed:Object.values(checks).every(Boolean),checks,triangles,bytes:raw.length,sha256:createHash('sha256').update(raw).digest('hex'),issues:validation.issues};
  fs.writeFileSync(path.join(root,'qa',id+'-glb-validation.json'),JSON.stringify(report,null,2));results.push(report);
}
const result={passed:results.every(r=>r.passed),models:results};
fs.writeFileSync(path.join(root,'qa/glb-validation.json'),JSON.stringify(result,null,2));
console.log(JSON.stringify(result));if(!result.passed)process.exitCode=1;
