import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
const root=path.resolve('source-assets/models/candidates/duck-series-v1/model-review-b2');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const results=[];
for(const id of ['duck-eggtart','duck-steelcup','duck-numberblock']){
 const raw=fs.readFileSync(path.join(root,'models',id,id+'.glb'));
 const jsonLength=raw.readUInt32LE(12);
 const g=JSON.parse(raw.subarray(20,20+jsonLength).toString());
 const binary=raw.subarray(20+jsonLength+8);
 const prim=g.meshes.flatMap(m=>m.primitives);
 const triangles=prim.reduce((n,p)=>n+g.accessors[p.indices].count/3,0);
 const v=await validator.validateBytes(new Uint8Array(raw),{uri:id+'.glb',maxIssues:100});
 const geometry=JSON.parse(fs.readFileSync(path.join(root,'qa',id+'-geometry.json')));
 const images=g.images.map(i=>{const b=g.bufferViews[i.bufferView];const p=binary.subarray(b.byteOffset??0,(b.byteOffset??0)+b.byteLength);return {mime:i.mimeType,width:p.readUInt32BE(16),height:p.readUInt32BE(20)};});
 const checks={oneMesh:g.meshes.length===1,onePrimitive:prim.length===1,oneMaterial:g.materials.length===1,preferredTriangles:triangles>=2000&&triangles<=4000,maximumTriangles:triangles<=6000,bytes:raw.length<=262144,noSkin:!g.skins,noAnimation:!g.animations,uv:prim.every(p=>p.attributes.TEXCOORD_0!==undefined),textures256:images.every(i=>i.width===256&&i.height===256&&i.mime==='image/png'),noErrors:v.issues.numErrors===0,noWarnings:v.issues.numWarnings===0,roundtripGeometry:geometry.passed};
 const report={id,passed:Object.values(checks).every(Boolean),checks,triangles,bytes:raw.length,sha256:createHash('sha256').update(raw).digest('hex'),images,issues:v.issues,unityImported:false};
 fs.writeFileSync(path.join(root,'qa',id+'-glb-validation.json'),JSON.stringify(report,null,2));results.push(report);
}
const summary={passed:results.every(r=>r.passed),models:results,artApproved:false,physicsRuntimeVerified:false};
fs.writeFileSync(path.join(root,'qa/glb-validation.json'),JSON.stringify(summary,null,2));
console.log(JSON.stringify(summary));if(!summary.passed)process.exitCode=1;
