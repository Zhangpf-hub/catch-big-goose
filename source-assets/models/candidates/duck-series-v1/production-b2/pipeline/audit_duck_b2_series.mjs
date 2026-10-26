import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
const root=path.resolve('source-assets/models/candidates/duck-series-v1/production-b2');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const spec=JSON.parse(fs.readFileSync(path.join(root,'design-spec.json')));
const results=[];
for(const {id} of spec.models){
 const raw=fs.readFileSync(path.join(root,'models',id,id+'.glb'));
 const len=raw.readUInt32LE(12),g=JSON.parse(raw.subarray(20,20+len));
 const binary=raw.subarray(28+len),prim=g.meshes.flatMap(m=>m.primitives);
 const triangles=prim.reduce((n,p)=>n+g.accessors[p.indices].count/3,0);
 const v=await validator.validateBytes(new Uint8Array(raw),{uri:id+'.glb',maxIssues:100});
 const geometry=JSON.parse(fs.readFileSync(path.join(root,'qa',id+'-geometry.json')));
 const identity=JSON.parse(fs.readFileSync(path.join(root,'qa',id+'-mother-identity.json')));
 const images=g.images.map(i=>{const b=g.bufferViews[i.bufferView],p=binary.subarray(b.byteOffset??0,(b.byteOffset??0)+b.byteLength);return {width:p.readUInt32BE(16),height:p.readUInt32BE(20),mime:i.mimeType};});
 const checks={oneMesh:g.meshes.length===1,onePrimitive:prim.length===1,oneMaterial:g.materials.length===1,triangleTarget:triangles>=2000&&triangles<=4000,bytes:raw.length<=262144,noSkin:!g.skins,noAnimation:!g.animations,uv:prim.every(p=>p.attributes.TEXCOORD_0!==undefined),atlas:images.every(i=>i.width===256&&i.height===256),noErrors:v.issues.numErrors===0,noWarnings:v.issues.numWarnings===0,geometry:geometry.passed,motherPreserved:identity.headRegenerated===false&&identity.faceRigidShapeChecksBeforeAccessoryLod.every(p=>p.maximumPairwiseDistanceChange<1e-5)};
 if(['duck-eggtart','duck-steelcup','duck-numberblock'].includes(id))checks.approvedBytesUnchanged=raw.equals(fs.readFileSync(path.resolve(root,'../model-review-b2/models',id,id+'.glb')));
 const r={id,passed:Object.values(checks).every(Boolean),checks,triangles,bytes:raw.length,sha256:createHash('sha256').update(raw).digest('hex'),images,issues:v.issues};
 fs.writeFileSync(path.join(root,'qa',id+'-glb-validation.json'),JSON.stringify(r,null,2));results.push(r);
}
const report={passed:results.length===20&&results.every(r=>r.passed),models:results,approvedMotherAndFirstThree:true,remainingSeventeenArtIndividuallyApproved:false,unityImportVerified:false};
fs.writeFileSync(path.join(root,'qa/glb-validation.json'),JSON.stringify(report,null,2));
console.log(JSON.stringify({passed:report.passed,models:results.length,triangles:results.map(r=>[r.id,r.triangles]),failures:results.filter(r=>!r.passed)}));if(!report.passed)process.exitCode=1;
