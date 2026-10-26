import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const source=fs.readFileSync(path.join(root,'projects/catch-big-goose-unity/Assets/Plugins/WebGL/GooseWeChatNativeVideo.jslib'),'utf8');
const checks=[];
function setup(options={}) {
  const library={},replies=[],pending=[],videos=[];
  const context={LibraryManager:{library},mergeInto:Object.assign,UTF8ToString:v=>v,
    SendMessage:(receiver,method,data)=>replies.push({receiver,method,...JSON.parse(data)}),setTimeout:fn=>pending.push(fn)};
  if(!options.noApi)context.wx={getWindowInfo:()=>({windowWidth:390,windowHeight:844}),createVideo:config=>{
    if(options.createError)throw Error('create failed');
    const video={config,handlers:{},destroyed:0,play(){this.handlers.onPlay?.();},pause(){this.handlers.onPause?.();},stop(){},destroy(){this.destroyed++;}};
    for(const name of ['Play','Pause','TimeUpdate','Ended','Error']){
      video['on'+name]=fn=>video.handlers['on'+name]=fn;
      video['off'+name]=fn=>{if(video.handlers['on'+name]===fn)delete video.handlers['on'+name];};
    }
    videos.push(video);return video;
  }};
  vm.runInNewContext(source,context);context.GooseNativeVideo=library.$GooseNativeVideo;
  return {library,replies,pending,videos,flush:()=>{while(pending.length)pending.shift()();}};
}
let t=setup();t.library.GoosePlayWechatVideo('wxfile://usr/hash.mp4',7,'GooseGame',0);let video=t.videos[0];
assert.equal(video.config.src,'wxfile://usr/hash.mp4');assert.equal(video.config.width,390);assert.equal(video.config.controls,false);assert.equal(video.config.enableProgressGesture,false);
assert.equal(t.replies[0].type,'play');checks.push('Native video starts with seeking disabled and no Unity texture allocation');
video.handlers.onTimeUpdate({position:9.8,duration:10});const ended=video.handlers.onEnded;ended();ended();
assert.equal(t.replies.filter(r=>r.type==='ended').length,1);assert.equal(video.destroyed,0);t.flush();assert.equal(video.destroyed,1);
checks.push('Natural end reports once and native destruction is deferred outside its callback');
t=setup();t.library.GoosePlayWechatVideo('local',8,'GooseGame',1);video=t.videos[0];const stale=video.handlers.onEnded;
assert.equal(video.config.muted,true);t.library.GooseStopWechatVideo(8);stale();assert.equal(t.replies.filter(r=>r.type==='ended').length,0);t.flush();
checks.push('Early close invalidates ended callbacks and cannot grant a reward');
t=setup();t.library.GoosePlayWechatVideo('local',9,'GooseGame',0);t.videos[0].handlers.onEnded();assert.equal(t.replies.at(-1).type,'error');checks.push('Ended without actual progress is rejected');
t=setup();t.library.GoosePlayWechatVideo('one',10,'GooseGame',0);const old=t.videos[0].handlers.onTimeUpdate;
t.library.GoosePlayWechatVideo('two',11,'GooseGame',0);old({position:10,duration:10});t.library.GooseStopWechatVideo(10);
assert.equal(t.replies.filter(r=>r.requestId===10&&r.type==='time').length,0);assert.equal(t.videos[1].destroyed,0);
t.videos[1].handlers.onTimeUpdate({position:10,duration:10});t.videos[1].handlers.onEnded();t.flush();assert.equal(t.replies.filter(r=>r.type==='ended').length,1);
checks.push('Rapid reopen rejects stale events and an old close cannot destroy the new session');
t=setup();t.library.GoosePlayWechatVideo('local',12,'GooseGame',0);t.videos[0].handlers.onError({errMsg:'decode failed'});assert.equal(t.replies.at(-1).type,'error');t.flush();assert.equal(t.videos[0].destroyed,1);checks.push('Decoder failure reports an error and releases the native player');
for(const option of [{noApi:true},{createError:true}]){t=setup(option);assert.doesNotThrow(()=>t.library.GoosePlayWechatVideo('local',13,'GooseGame',0));assert.equal(t.replies.at(-1).type,'error');}
checks.push('Unsupported API and creation errors are caught instead of escaping into the game');
const report={passed:true,scope:'Native WeChat API protocol mocked in Node; physical iPhone playback still requires a device check',checks};
fs.mkdirSync(path.join(root,'work/home-gm-video-20261025'),{recursive:true});fs.writeFileSync(path.join(root,'work/home-gm-video-20261025/native-video-bridge-tests.json'),JSON.stringify(report,null,2));
console.log(`${checks.length} native video lifecycle checks passed`);
