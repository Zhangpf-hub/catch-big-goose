// Preserve image_gen alpha and artwork; only resolution and lossless PNG encoding change.
const fs=require('node:fs'),path=require('node:path');
const sharp=require('C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=path.resolve(__dirname,'../..'),generated='C:/Users/123/.codex/generated_images/01a16bd0-8fc1-74a1-ac57-1e45c185e153';
const sources=path.join(root,'source-assets/ui/home-stickers-v2'),out=path.join(root,'projects/catch-big-goose-unity/Assets/Resources/Textures/home-stickers-v2');
const files={cta:['exec-8c8ec4ca-84c4-4e09-bb44-1cf66582c730.png',704],title:['exec-a987c30b-7281-4502-95d9-d003258de269.png',576],breakfast:['exec-bcfb92e6-47f9-453e-8559-bf6eb178c2bc.png',176],barbecue:['exec-34e1a0ed-20ed-4802-9b7d-faeca80fa38a.png',176],countryside:['exec-a77b7adf-07d8-4d5c-8161-5c914f3960da.png',176],grocery:['exec-bbf168a6-03c7-4f33-9a9a-9739b9a198ca.png',176],toys:['exec-ee5858e5-72b4-45af-8d79-5add35960632.png',176],settings:['exec-856fe091-ef62-4163-a6c4-5dfd9eff0f5a.png',128]};
async function main(){
  fs.mkdirSync(out,{recursive:true});let total=0;const assets=[];
  for(const[id,[file,width]]of Object.entries(files)){
    // Mascot-bearing UI has moved to duck-stickers-v3. Do not republish Shiba art.
    if(['title','cta','settings'].includes(id))continue;
    const master=path.join(sources,id+'-master.png');if(!fs.existsSync(master))fs.copyFileSync(path.join(generated,file),master);
    const data=await sharp(master).resize({width,kernel:'lanczos3'}).png({compressionLevel:9}).toBuffer();
    const meta=await sharp(data).metadata(),stats=await sharp(data).stats();if(!meta.hasAlpha||stats.channels[3].min!==0)throw Error('Missing transparent alpha '+id);
    fs.writeFileSync(path.join(out,id+'.bytes'),data);total+=data.length;assets.push({id,width:meta.width,height:meta.height,bytes:data.length,alpha:true});
  }
  fs.writeFileSync(path.join(sources,'runtime-contract.json'),JSON.stringify({assets,totalBytes:total,aspect:'Fixed aspect preserveAspect art; underlying nine-slice hit surface stays fixed. No stretching of illustration.',mipmaps:true,filter:'Trilinear',markNonReadable:true},null,2));
  console.log(JSON.stringify({assets,totalBytes:total}));
}
main().catch(e=>{console.error(e);process.exit(1)});
