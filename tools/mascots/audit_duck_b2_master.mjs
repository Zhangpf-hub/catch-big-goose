import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
const root=path.resolve('source-assets/models/candidates/duck-series-v1/master-b2');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const entries=[['static','models/duck-b2-master/duck-b2-master.glb'],['rig','models/duck-b2-master-rig.glb']];
const results=[];
for(const [kind,file] of entries){
 const raw=fs.readFileSync(path.join(root,file));
 const g=JSON.parse(raw.subarray(20,20+raw.readUInt32LE(12)).toString());
 const p=g.meshes.flatMap(m=>m.primitives), tris=p.reduce((n,x)=>n+g.accessors[x.indices].count/3,0);
 const v=await validator.validateBytes(new Uint8Array(raw),{uri:file,maxIssues:100});
 const checks={oneMesh:g.meshes.length===1,onePrimitive:p.length===1,oneMaterial:g.materials.length===1,triangleLimit:tris<=6000,byteLimit:raw.length<=262144,uv:p.every(x=>x.attributes.TEXCOORD_0!==undefined),noErrors:v.issues.numErrors===0,noWarnings:v.issues.numWarnings===0};
 if(kind==='static'){
   checks.noSkin=!g.skins;checks.noAnimations=!g.animations;
   checks.roundtripGeometry=JSON.parse(fs.readFileSync(path.join(root,'qa/duck-b2-master-geometry.json'))).passed;
 }else{
   checks.oneSkin=g.skins?.length===1;checks.threeClips=g.animations?.length===3;
   checks.clipNames=['duck_idle','duck_greet','duck_click'].every(n=>g.animations.some(a=>a.name===n));
   const rt=JSON.parse(fs.readFileSync(path.join(root,'qa/rig-roundtrip-validation.json')));
   checks.roundtripVertexMotion=rt.roundtripVertexMotionPassed&&rt.allClipsReturnToRest;
   checks.currentMotionEvidence=rt.sourceSha256===createHash('sha256').update(raw).digest('hex');
 }
 const result={kind,file,triangles:tris,bytes:raw.length,withinPreferred4000TriangleTarget:tris<=4000,sha256:createHash('sha256').update(raw).digest('hex'),checks,passed:Object.values(checks).every(Boolean),issues:v.issues};
 results.push(result);
}
const report={passed:results.every(r=>r.passed),models:results,artApproval:false,unityImported:false};
fs.writeFileSync(path.join(root,'qa/glb-validation.json'),JSON.stringify(report,null,2));
console.log(JSON.stringify(report));if(!report.passed)process.exitCode=1;
