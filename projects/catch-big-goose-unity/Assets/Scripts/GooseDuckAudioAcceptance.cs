#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseDuckAudioAcceptance:MonoBehaviour
    {
        [Serializable] sealed class Report
        {public bool passed;public int homeClicks,duckPicks,screenDuckPicks,apiDuckPicks;public float mixPeak;public List<string> checks=new List<string>(),errors=new List<string>(),pickedIds=new List<string>();}
        readonly Report report=new Report();GooseGame game;string output;bool done;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)] static void Early()
        {if(Environment.GetCommandLineArgs().Contains("-duckAudioQa")){GooseSave.IsQa=true;GooseSave.Sound=true;GooseSave.Onboarded=true;}}
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-duckAudioQa"))new GameObject("DuckAudioAcceptance").AddComponent<GooseDuckAudioAcceptance>();}
        void Check(bool ok,string message){(ok?report.checks:report.errors).Add(message);Debug.Log("[DuckAudioQA] "+ok+" "+message);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-duckAudioOutput")+1];Directory.CreateDirectory(output);
            StartCoroutine(Watchdog());yield return null;game=GooseGame.Instance;game.GoHome();
            float deadline=Time.realtimeSinceStartup+100;
            while(!game.HomeStage.Ready&&Time.realtimeSinceStartup<deadline)yield return null;
            Check(game.HomeStage.Ready,"Homepage mascot ready");if(!game.HomeStage.Ready){Finish();yield break;}
            var audio=game.DuckAudio;
            foreach(string id in new[]{"duck","goose","duck-eggpancake","ref_goose_farmer"})Check(GooseDuckAudio.IsDuckItem(id),id+" selects duck audio");
            foreach(string id in new[]{null,"corn","ref_bowl","rubber-duck-poster"})Check(!GooseDuckAudio.IsDuckItem(id),(id??"null")+" does not select duck audio");
            game.LoadDuckReviewCatalog();Check(game.DuckReviewThemes.SelectMany(t=>t.items).All(GooseDuckAudio.IsDuckItem),"Every duck review model routes to quack");
            var capture=game.MainCamera.gameObject.AddComponent<GooseDuckMixCapture>();capture.Begin();
            var heard=new HashSet<string>();
            for(int i=0;i<3;i++)
            {
                int before=audio.PlayedCount;var point=game.HomeStage.Camera.WorldToScreenPoint(game.HomeStage.DuckMascot.Skin.bounds.center);
                Check(game.HomeStage.TryReactAtScreenPosition(point),"Homepage duck hit "+i);
                Check(audio.PlayedCount==before+1&&audio.ActiveVoices>0,"Home click plays one actual voice "+i);
                Check(game.HomeStage.DuckMascot.CurrentAction=="duck_click","Home sound accompanies click animation");
                heard.Add(audio.LastClipName);report.homeClicks++;yield return new WaitForSeconds(.65f);
            }
            Check(heard.Count==3,"Three different quack phrases rotate");
            int count=audio.PlayedCount;
            Check(!game.HomeStage.TryReactAtScreenPosition(Vector2.zero)&&audio.PlayedCount==count,"Background tap is silent");
            var background=game.HomeStage.Camera.pixelRect.min+new Vector2(3,3);
            Check(!game.HomeStage.TryReactAtScreenPosition(background)&&audio.PlayedCount==count,"Empty corner inside home viewport is silent");
            for(int i=0;i<12;i++)
            {
                var point=game.HomeStage.Camera.WorldToScreenPoint(game.HomeStage.DuckMascot.Skin.bounds.center);
                Check(game.HomeStage.TryReactAtScreenPosition(point),"Rapid home duck tap "+i);report.homeClicks++;
                Check(audio.ActiveVoices<=GooseDuckAudio.VoiceLimit,"Voice pool bounded "+i);yield return new WaitForSeconds(.04f);
            }
            Check(audio.PlayedCount==count+12,"Every accepted rapid tap gets a quack");
            game.ToggleSound();yield return null;count=audio.PlayedCount;game.HomeStage.React();
            Check(audio.ActiveVoices==0&&audio.PlayedCount==count,"Mute stops current calls and blocks new home call");
            game.ToggleSound();game.SetPaused(true);game.PlaySound("quack");Check(audio.PlayedCount==count,"Paused call is silent");game.SetPaused(false);
            yield return new WaitForSeconds(.5f);report.mixPeak=capture.Save(Path.Combine(output,"runtime-home-mix.wav"));
            Check(report.mixPeak>.01f&&report.mixPeak<.98f,"Captured actual listener mix is audible and not clipped");Destroy(capture);
            for(int theme=0;theme<3;theme++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(1);game.BeginRound(false);
                deadline=Time.realtimeSinceStartup+100;while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                Check(game.SpawnComplete,"Formal round ready "+game.Theme.id);if(!game.SpawnComplete){Finish();yield break;}
                yield return new WaitForSeconds(.5f);
                var ids=game.Remaining.Where(i=>GooseDuckAudio.IsDuckItem(i.Id)).GroupBy(i=>i.Id)
                    .OrderByDescending(g=>g.Max(i=>i.transform.position.y)).Select(g=>g.Key).Take(theme<2?4:1).ToArray();
                foreach(string id in ids)
                {
                    int removed=game.Removed;
                    for(int n=0;n<3;n++)
                    {
                        Vector2 point;var item=Visible(id,out point);
                        int before=audio.PlayedCount;
                        if(item)
                        {
                            Check(game.BeginPointer(point,724),id+" pointer selection begins");
                            Check(audio.PlayedCount==before,"Selection preview is silent before commit");
                            Check(game.EndPointer(point,724),id+" pointer selection commits");report.screenDuckPicks++;
                        }
                        else
                        {
                            // Exercise the same accepted-pick event used by the
                            // match tool, without pretending a buried item is tappable.
                            item=game.Remaining.FirstOrDefault(i=>i.Id==id&&!i.Frozen);
                            Check(item,id+" remains in the production inventory");if(!item){Finish();yield break;}
                            if(!item.DepthVisible)Check(!game.Pick(item)&&audio.PlayedCount==before,"Hidden manual selection is silent");
                            Check(game.Pick(item,true),id+" accepted selection API commits");report.apiDuckPicks++;
                        }
                        Check(item.Picked&&audio.PlayedCount==before+1,id+" accepted selection plays exactly one quack");
                        Check(audio.ActiveVoices>0&&audio.LastClipName.StartsWith("duck-quack-"),id+" actual source uses new asset");
                        game.Pick(item,true);Check(audio.PlayedCount==before+1,"Rejected duplicate selection is silent");
                        report.duckPicks++;if(!report.pickedIds.Contains(id))report.pickedIds.Add(id);yield return new WaitForSeconds(.65f);
                    }
                    yield return new WaitForSeconds(.3f);
                    Check(game.Removed==removed+3,id+" still commits a normal three-item match");
                }
                Check(ids.Length==(theme<2?4:1),game.Theme.id+" required duck types present");
                // Ordinary pieces retain their own feedback.
                var ordinary=game.Remaining.FirstOrDefault(i=>!GooseDuckAudio.IsDuckItem(i.Id)&&!i.Frozen);
                count=audio.PlayedCount;Check(ordinary&&game.Pick(ordinary,true),"Ordinary selection accepted");
                Check(audio.PlayedCount==count,"Ordinary item does not quack");yield return new WaitForSeconds(.6f);
            }
            Check(report.pickedIds.Count(id=>id.StartsWith("duck-"))==8,"All eight deployed duck models emit the accepted-selection sound");
            Check(report.screenDuckPicks>=3,"Visible ducks exercise actual press/release selection");
            Check(report.pickedIds.Any(id=>id.StartsWith("ref_goose_")),"Legacy theme duck also uses new call");
            game.GoHome();Finish();
        }
        bool ScreenPoint(GooseItem item,out Vector2 point)
        {
            point=default;if(game.Busy||!item.DepthVisible||item.Frozen)return false;
            var b=item.VisualBounds;for(int k=0;k<27;k++){var p=b.center+Vector3.Scale(b.extents,new Vector3((k%3-1)*.7f,(k/3%3-1)*.7f,(k/9-1)*.7f));var s=game.MainCamera.WorldToScreenPoint(p);
                if(game.FindSelectableAtScreenPosition(s)==item){point=s;return true;}}
            return false;
        }
        GooseItem Visible(string id,out Vector2 point)
        {
            point=default;
            foreach(var item in game.Remaining.Where(i=>i.Id==id).OrderByDescending(i=>i.transform.position.y))if(ScreenPoint(item,out point))return item;
            return null;
        }
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(420);report.errors.Add("Acceptance timed out");Finish();}
        void Finish(){if(done)return;done=true;report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);}
    }
    public sealed class GooseDuckMixCapture:MonoBehaviour
    {
        float[] buffer;int used,channels=2;volatile bool recording;
        public void Begin(){buffer=new float[AudioSettings.outputSampleRate*2*10];used=0;recording=true;}
        void OnAudioFilterRead(float[] data,int channelCount)
        {if(!recording||buffer==null)return;channels=channelCount;int count=Math.Min(data.Length,buffer.Length-used);Array.Copy(data,0,buffer,used,count);used+=count;}
        public float Save(string path)
        {
            recording=false;float peak=0;int sampleCount=used,size=sampleCount*2;
            using(var writer=new BinaryWriter(File.Create(path)))
            {
                writer.Write(System.Text.Encoding.ASCII.GetBytes("RIFF"));writer.Write(36+size);writer.Write(System.Text.Encoding.ASCII.GetBytes("WAVEfmt "));writer.Write(16);
                writer.Write((short)1);writer.Write((short)channels);writer.Write(AudioSettings.outputSampleRate);writer.Write(AudioSettings.outputSampleRate*channels*2);writer.Write((short)(channels*2));writer.Write((short)16);
                writer.Write(System.Text.Encoding.ASCII.GetBytes("data"));writer.Write(size);
                for(int i=0;i<sampleCount;i++){peak=Mathf.Max(peak,Mathf.Abs(buffer[i]));writer.Write((short)(Mathf.Clamp(buffer[i],-1,1)*32767));}
            }
            return peak;
        }
    }
}
#endif
