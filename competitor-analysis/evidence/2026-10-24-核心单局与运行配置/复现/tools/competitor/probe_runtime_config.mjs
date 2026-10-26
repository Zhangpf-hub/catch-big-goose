// Unchanged original bodies; dictionaries, hash and string library calls are fixtures.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import createWabt from '../../work/competitor-tools/wabt/index.js';
const out=path.resolve('work/competitor-runtime-trace/tests');fs.mkdirSync(out,{recursive:true});
const source='work/competitor-runtime-trace/primary-methods';
const selected=fs.readFileSync(`${source}/selected.wat`,'utf8');
const bodies=['j11647','j50925','j4622'].map(s=>fs.readFileSync(`${source}/${s}.watfrag`,'utf8'));
const symbols=[...new Set(bodies.join('\n').match(/\bcall (\$[^\s)]+)/g).map(s=>s.slice(5)))];
const importForms=selected.split(/(?=^  \()/m).filter(f=>f.startsWith('  (import '));
const imports=symbols.map(s=>importForms.find(f=>f.includes(`(func ${s} `)) || ` (import "fixture" "${s.slice(1)}" (func ${s} (type $t2)))\n`);
const text=`(module
 ${selected.split(/(?=^  \()/m).filter(f=>f.startsWith('  (type ')).join('')}
 ${imports.join('')}
 (import "fixture" "hash" (func $hash (param i32 i32) (result i32)))
 (memory (export "memory") 100)
 (table $primary.table 1 funcref) (elem (i32.const 0) $hash)
 (global $primary.global$0 (mut i32) (i32.const 6000000))
 (global $__wasm_split_waitTableId (mut i32) (i32.const 0))
 ${bodies.join('\n')}
 (export "ab" (func $j11647)) (export "listInt" (func $j50925)) (export "hotfix" (func $j4622)))`;
const wabt=await createWabt();const mod=wabt.parseWat('runtime-config.wat',text);mod.resolveNames();mod.validate();
const bytes=mod.toBinary({write_debug_names:true}).buffer;mod.destroy();
let mem,bucket=1,cached=0,found=true,currentString=0;
const strings=new Map();let nextString=1000000;
const put=(a,v)=>mem.setInt32(a,v,true);
const string=s=>{if(s===null)return 0;const id=nextString;nextString+=256;strings.set(id,s);put(id+8,s.length);return id;};
const implementations={j922(){},j923(){},j1040(dict){return dict===31000?Number(cached!==0):Number(found);},
 j1033(dict){return dict===31000?cached:50000;},j48358:()=>123,j935:()=>0,j1060:()=>70000,
 j24956(key,value){cached=value;},j4064:()=>0,j962:()=>0,j1120:()=>0,j1075(){},j1600:()=>0,j1277:()=>0,j1429(){},
 j3149(ptr){const list=strings.get(ptr).split(',');put(65000+12,list.length);list.forEach((s,i)=>put(65000+16+i*4,string(s)));return 65000;},
 j1399(ptr,out){const s=strings.get(ptr)?.trim()??'';const n=Number(s);const ok=/^[+-]?\d+$/.test(s)&&Number.isInteger(n)&&n>=-2147483648&&n<=2147483647;put(out,ok?n:0);return Number(ok);},
 j3816(out){put(out+4,currentString);},hash:()=>bucket-1};
const host={fixture:implementations,dependency:{}};
for (const form of imports){const m=form.match(/\(import "([^"]+)" "([^"]+)" \(func \$(\S+) /);host[m[1]][m[2]]=implementations[m[3]];assert(host[m[1]][m[2]],m[3]);}
const {instance}=await WebAssembly.instantiate(bytes,host);mem=new DataView(instance.exports.memory.buffer);
put(3951300,200000);put(200092,201000);put(201000,30000);put(201004,31000);put(30016,1);put(30024,0);
put(4111716,90000);put(70000,80000);put(80204,0);put(80208,0);
const rows=JSON.parse(fs.readFileSync('work/competitor-config-trace/serialized-verified/ABTestData.json','utf8'));
// Table wrapper is explicit rather than assuming every JSON file is a raw array.
const data=Array.isArray(rows)?rows:rows.dataArray;
assert(Array.isArray(data),Object.keys(rows));
const cases=[];
for(const row of data){const r=row._featurekey?row:(row.value??row);assert(r._featurekey);
 put(50012,r._isopen);put(50016,60000);put(50020,62000);
 put(60012,r._forkkeylist.length);put(62012,r._forkweightlist.length);
 r._forkkeylist.forEach((k,i)=>put(60016+4*i,91000+16*i));r._forkweightlist.forEach((w,i)=>put(62016+4*i,w));
 for(bucket=1;bucket<=100;bucket++){
  cached=0;found=true;let cumulative=0,index=-1;
  if(r._isopen===1)for(let i=0;i<r._forkweightlist.length;i++){if(r._forkweightlist[i]<1)continue;cumulative+=r._forkweightlist[i];if(bucket<=cumulative){index=i;break;}}
  const actual=instance.exports.ab(10000,0);assert.equal(actual,index<0?90000:91000+16*index);
  cases.push({feature:r._featurekey,enabled:r._isopen,bucket,weights:r._forkweightlist,forks:r._forkkeylist,index});
 }
}
// Cached assignment takes precedence over a subsequently disabled individual row.
cached=93000;put(50012,0);assert.equal(instance.exports.ab(10000,0),93000);
cached=0;put(50012,1);put(60012,1);put(62012,2);assert.equal(instance.exports.ab(10000,0),90000);
const parseCases=[];
for(const value of [null,'','-3','+4',' 5 ','bad','2147483648'])for(const fallback of [0,17]){
 currentString=string(value);put(50032,currentString);
 const expected=value===null||value===''?fallback:implementations.j1399(currentString,1000)?mem.getInt32(1000,true):0;
 const actual=instance.exports.hotfix(10000,10001,fallback,0);assert.equal(actual,expected);
 parseCases.push({value,fallback,hotfix:actual});
}
for(const value of ['4,5,6','4,bad,6',''])for(const index of [0,1,2,3]){
 put(50032,string(value));found=true;const entry=value.split(',')[index];
 const expected=entry&&/^[+-]?\d+$/.test(entry)?Number(entry):17;
 assert.equal(instance.exports.listInt(10000,index,17,0),expected);
}
fs.writeFileSync(path.join(out,'runtime-config.wasm'),bytes);
fs.writeFileSync(path.join(out,'ab-bucket-cases.json'),JSON.stringify(cases,null,2)+'\n');
fs.writeFileSync(path.join(out,'ab-bucket-cases.csv'),cases.map(c=>[c.enabled,c.bucket,c.weights.join(';'),c.index].join(',')).join('\n')+'\n');
fs.writeFileSync(path.join(out,'hotfix-parse-cases.json'),JSON.stringify(parseCases,null,2)+'\n');
const report={passed:true,originalBodies:['j11647','j50925','j4622'],abCases:cases.length,extraChecks:28,
 sha256:createHash('sha256').update(bytes).digest('hex'),
 scope:'Unchanged WASM control flow; config/memory fixtures and mocked dictionary/hash/string calls. Actual user hash, network loading, original Int32.TryParse internals and complete level initialization are not executed.'};
fs.writeFileSync(path.join(out,'runtime-config-probe.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
