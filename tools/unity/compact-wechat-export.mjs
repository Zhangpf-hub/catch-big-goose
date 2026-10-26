import fs from 'node:fs';
import path from 'node:path';
import {transform} from 'esbuild';

const directory=path.resolve(process.argv[2]);
if(!fs.existsSync(path.join(directory,'project.config.json')))throw Error('Expected an exported WeChat project');
let before=0,after=0,files=0;
function walk(folder){return fs.readdirSync(folder,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(folder,e.name)):[path.join(folder,e.name)]);}
for(const file of walk(directory).filter(f=>f.endsWith('.js'))){
  // Leave manager configuration readable for SDK tooling and export audits.
  if(['game.js','unity-namespace.js'].includes(path.relative(directory,file).replaceAll('\\','/')))continue;
  const source=fs.readFileSync(file,'utf8');before+=Buffer.byteLength(source);
  const result=await transform(source,{sourcefile:file,target:'esnext',minifyWhitespace:true,
    minifyIdentifiers:false,minifySyntax:false,treeShaking:false,legalComments:'inline',charset:'utf8'});
  const notices=source.match(/^\/\/[^\r\n]*(?:copyright|license)[^\r\n]*$/gim)??[];
  const leading=source.match(/^\s*(\/\*[\s\S]*?\*\/)/)?.[1];
  if(leading&&/copyright|license/i.test(leading))notices.push(leading);
  const retained=notices.filter(s=>!result.code.includes(s));
  const output=(retained.length?retained.join('\n')+'\n':'')+result.code;
  fs.writeFileSync(file,output);after+=Buffer.byteLength(output);files++;
}
console.log(JSON.stringify({files,beforeBytes:before,afterBytes:after,savedBytes:before-after,
  policy:'AST whitespace compaction only; identifiers, syntax optimizations, videos and textures unchanged; license notices retained'}));
