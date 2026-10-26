// Built-in image_gen edits; preserve alpha and fixed aspect, lossless runtime encoding.
const fs=require('node:fs'),path=require('node:path');
const sharp=require('C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=path.resolve(__dirname,'../..'),generated='C:/Users/123/.codex/generated_images/01a16bd0-8fc1-74a1-ac57-1e45c185e153';
const source=path.join(root,'source-assets/ui/duck-stickers-v3'),runtime=path.join(root,'projects/catch-big-goose-unity/Assets/Resources/Textures/duck-stickers-v3');
const files={title:['exec-9b12318a-9d2a-4b69-a09a-475a35429bea.png',576],cta:['exec-08b52db9-5239-4af6-8139-24aad9693543.png',704],settings:['exec-2e72829c-c781-4ec6-b709-8a3f0f8ec299.png',128]};
async function main(){
 fs.mkdirSync(source,{recursive:true});fs.mkdirSync(runtime,{recursive:true});const assets=[];
 for(const[id,[file,width]]of Object.entries(files)){
  const master=path.join(source,id+'-master.png');if(!fs.existsSync(master))fs.copyFileSync(path.join(generated,file),master);
  const data=await sharp(master).resize({width,kernel:'lanczos3'}).png({compressionLevel:9}).toBuffer();
  const m=await sharp(data).metadata(),stats=await sharp(data).stats();if(!m.hasAlpha||stats.channels[3].min!==0)throw Error('No true alpha '+id);
  fs.writeFileSync(path.join(runtime,id+'.bytes'),data);assets.push({id,width:m.width,height:m.height,bytes:data.length,alpha:true});
  const old=path.join(root,'projects/catch-big-goose-unity/Assets/Resources/Textures/home-stickers-v2',id+'.bytes');
  const archive=path.join(source,'retired-shiba-runtime');fs.mkdirSync(archive,{recursive:true});
  for(const p of [old,old+'.meta'])if(fs.existsSync(p))fs.renameSync(p,path.join(archive,path.basename(p)));
 }
 fs.writeFileSync(path.join(source,'runtime-contract.json'),JSON.stringify({version:'DUCKBRAND3',brand:'抓鸭子',identity:'Approved duck-series-v1 B2',assets,loading:'Assets/loading-art/duck-loading.jpg',previous:'home-stickers-v2; five theme stickers kept',filter:'Trilinear with mipmaps',aspect:'PreserveAspect, stable hit surface; no anisotropic stretch'},null,2));
 const loadingMaster=path.join(source,'loading-master.png');if(!fs.existsSync(loadingMaster))fs.copyFileSync(path.join(generated,'exec-298ed722-7a67-4ebc-8b28-2168389e9e69.png'),loadingMaster);
 const loadingOut=path.join(root,'projects/catch-big-goose-unity/Assets/loading-art');fs.mkdirSync(loadingOut,{recursive:true});
 await sharp(loadingMaster).resize(768,1152,{kernel:'lanczos3'}).jpeg({quality:90,chromaSubsampling:'4:4:4'}).toFile(path.join(loadingOut,'duck-loading.jpg'));
 console.log(JSON.stringify({assets,totalBytes:assets.reduce((s,a)=>s+a.bytes,0),loading:'Assets/loading-art/duck-loading.jpg'}));
}
main().catch(e=>{console.error(e);process.exit(1)});
