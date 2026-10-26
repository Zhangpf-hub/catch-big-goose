import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
const root=path.resolve(process.argv[2]??'source-assets/models/candidates/mobile-runtime-20261024');
const validator=createRequire(import.meta.url)('D:/开发/tools/gltf-audit/node_modules/gltf-validator');
const results=[];
for(const m of JSON.parse(fs.readFileSync(path.join(root,'batch-results.json'),'utf8'))){
 const file=path.join(root,m.id,m.id+'.glb'),raw=fs.readFileSync(file);
 const length=raw.readUInt32LE(12),g=JSON.parse(raw.subarray(20,20+length).toString());
 const primitives=g.meshes.flatMap(x=>x.primitives),faces=primitives.reduce((n,p)=>n+g.accessors[p.indices].count/3,0);
 const issue=await validator.validateBytes(new Uint8Array(raw),{uri:m.id+'.glb',maxIssues:100});
 const valid=g.meshes.length===1&&primitives.length===1&&g.materials.length===1&&faces===m.triangles&&m.materials===1&&
  fs.existsSync(path.join(root,m.id,'albedo.png'))&&Math.abs(Math.max(...m.normalizedDimensions)-1)<.0001&&issue.issues.numErrors===0&&issue.issues.numWarnings===0;
 results.push({id:m.id,passed:valid,triangles:faces,sha256:createHash('sha256').update(raw).digest('hex'),issues:issue.issues});
}
const expected=JSON.parse(fs.readFileSync(path.join(root,'batch-results.json'),'utf8')).length;
const report={passed:expected>0&&results.length===expected&&results.every(x=>x.passed),models:results};
fs.writeFileSync(path.join(root,'validation.json'),JSON.stringify(report,null,2));
console.log(JSON.stringify({passed:report.passed,models:results.length,failed:results.filter(x=>!x.passed).map(x=>({id:x.id,issues:x.issues}))}));
if(!report.passed)process.exitCode=1;
