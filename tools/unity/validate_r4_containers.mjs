import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';import{createHash}from'node:crypto';
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const root=path.resolve('source-assets/models/candidates/r4-scenes-20261025/containers');const rows=[];
for(const model of JSON.parse(fs.readFileSync(path.join(root,'geometry-report.json'),'utf8'))){
 const file=path.join(root,model.id,model.id+'.glb'),raw=fs.readFileSync(file);
 const result=await validator.validateBytes(new Uint8Array(raw),{uri:model.id+'.glb',maxIssues:30});
 rows.push({...model,sha256:createHash('sha256').update(raw).digest('hex'),bytes:raw.length,issues:result.issues,passed:result.issues.numErrors===0&&result.issues.numWarnings===0&&model.triangles<=8000&&model.materials<=2});
}
const report={passed:rows.length===5&&rows.every(x=>x.passed),scope:'Static circular containers, separate 8000-triangle/2-material budget; gameplay collisions are analytic primitives.',models:rows};
fs.writeFileSync(path.join(root,'validation.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));if(!report.passed)process.exitCode=1;
