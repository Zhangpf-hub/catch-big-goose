import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';import {createHash} from 'node:crypto';
const root=path.resolve('assets-3d/candidates/reference-look-20261025');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const rows=[];const expected=JSON.parse(fs.readFileSync(path.join(root,'batch.json'),'utf8')).length;
for(const m of JSON.parse(fs.readFileSync(path.join(root,'results.json'),'utf8'))){
 const raw=fs.readFileSync(path.join(root,m.id,m.id+'.glb'));
 const report=await validator.validateBytes(new Uint8Array(raw),{uri:m.id+'.glb',maxIssues:30});
 const digest=file=>createHash('sha256').update(fs.readFileSync(path.join(root,m.id,file))).digest('hex');
 rows.push({id:m.id,passed:report.issues.numErrors===0&&report.issues.numWarnings===0&&m.triangles<=4000&&m.materials<=4&&m.parts===m.materials&&m.glbRoundtrip,triangles:m.triangles,materials:m.materials,parts:m.parts,sha256:createHash('sha256').update(raw).digest('hex'),fbxSha256:digest(m.id+'.fbx'),materialSha256:digest('materials.json'),issues:report.issues});
}
const result={passed:rows.length===expected&&rows.every(x=>x.passed),models:rows};fs.writeFileSync(path.join(root,'validation.json'),JSON.stringify(result,null,2));
console.log(JSON.stringify({passed:result.passed,models:rows.length,failed:rows.filter(x=>!x.passed)}));if(!result.passed)process.exitCode=1;
