// Code-authored vector sources designed for nine-slicing, not cropped concept art.
const fs=require('node:fs'),path=require('node:path');
const sharp=require('C:/Users/123/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=path.resolve(__dirname,'../..'),out=path.join(root,'projects/catch-big-goose-unity/Assets/Resources/Textures/ui-candy-v2'),sources=path.join(root,'source-assets/models/candidates/ui-candy-v2');
fs.mkdirSync(out,{recursive:true});fs.mkdirSync(sources,{recursive:true});
const palettes={yellow:['#fff572','#ffdc13','#f6b00b','#ae5704'],blue:['#6cf5ff','#08c8f0','#0592db','#075798'],coral:['#ffb78b','#ff795c','#ef5248','#a43132'],mint:['#bdffe0','#64dfad','#2dbd98','#167d73'],lavender:['#e9cdff','#bd91f5','#9362d9','#584391']};
async function main(){
  for(const [name,c] of Object.entries(palettes)){
    const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="256" height="192" viewBox="0 0 256 192"><defs>
    <linearGradient id="base" x2="0" y2="1"><stop stop-color="${c[2]}"/><stop offset="1" stop-color="${c[3]}"/></linearGradient>
    <linearGradient id="face" x2="0" y2="1"><stop stop-color="${c[0]}"/><stop offset=".28" stop-color="${c[1]}"/><stop offset="1" stop-color="${c[2]}"/></linearGradient>
    <linearGradient id="shine" x2="0" y2="1"><stop stop-color="white" stop-opacity=".95"/><stop offset=".45" stop-color="white" stop-opacity=".1"/><stop offset="1" stop-color="white" stop-opacity=".4"/></linearGradient></defs>
    <rect x="4" y="4" width="248" height="184" rx="48" fill="#fffdf4"/>
    <rect x="10" y="10" width="236" height="172" rx="42" fill="#61300d"/>
    <rect x="16" y="16" width="224" height="160" rx="36" fill="url(#base)"/>
    <rect x="18" y="16" width="220" height="142" rx="34" fill="url(#face)"/>
    <rect x="23" y="21" width="210" height="130" rx="29" fill="none" stroke="url(#shine)" stroke-width="4"/>
    </svg>`;
    fs.writeFileSync(path.join(sources,name+'-button.svg'),svg);
    const destination=['yellow','blue'].includes(name)?out:path.join(root,'source-assets/ui/home-stickers-v2/retired-color-variants');fs.mkdirSync(destination,{recursive:true});
    await sharp(Buffer.from(svg),{density:384}).resize(256,192,{kernel:'lanczos3'}).png().toFile(path.join(destination,name+'-button.png'));
  }
  const panel=`<svg xmlns="http://www.w3.org/2000/svg" width="256" height="192" viewBox="0 0 256 192"><defs><linearGradient id="rim" x2="0" y2="1"><stop stop-color="#fff7d7"/><stop offset="1" stop-color="#d5a46a"/></linearGradient><linearGradient id="inset" x2="0" y2="1"><stop stop-color="#fff8df"/><stop offset="1" stop-color="#ffecc1"/></linearGradient></defs><rect x="4" y="4" width="248" height="184" rx="36" fill="#fffdf6"/><rect x="9" y="9" width="238" height="174" rx="31" fill="#704019"/><rect x="14" y="14" width="228" height="164" rx="26" fill="url(#rim)"/><rect x="21" y="21" width="214" height="150" rx="19" fill="url(#inset)" stroke="#dcb780" stroke-width="2"/></svg>`;
  fs.writeFileSync(path.join(sources,'ivory-panel.svg'),panel);
  await sharp(Buffer.from(panel),{density:384}).resize(256,192,{kernel:'lanczos3'}).png().toFile(path.join(out,'ivory-panel.png'));
  fs.writeFileSync(path.join(sources,'contract.json'),JSON.stringify({version:3,source:'Code-authored SVG; high-density rasterization and Lanczos downsample',width:256,height:192,pixelsPerUnit:100,pixelsPerUnitMultiplier:2,borders:{...Object.fromEntries(Object.keys(palettes).map(k=>[k+'-button',[64,64,64,64]])),'ivory-panel':[48,48,48,48]},uiCompression:'RGBA32 lossless',filter:'Trilinear with mipmaps',note:'Corners and white/brown rims never enter the stretched center. Labels and prop illustrations remain separate.'},null,2));
  console.log('Six vector-authored production nine-slice surfaces created.');
}
main().catch(e=>{console.error(e);process.exit(1)});
