#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseHomeShakeAcceptance:MonoBehaviour
    {
        [Serializable] class Row
        {
            public string theme;public int stock,affected,moved,turned,dynamicBefore,awakeAfter,recoveryAfter,visibilityChanges,hideViolations,floorCorrections;
            public float minHullY=100,maxRise,maxTravel,maxHorizontalImpulse,maxVerticalImpulse,p95ms;
        }
        [Serializable] class Report
        {
            public string build=GooseRuntimePerformance.BuildId,scope="Actual native mobile profile, synthetic sensor/button input. Phone FPS not measured.";
            public bool passed;public List<string> checks=new List<string>(),errors=new List<string>();public List<Row> shakes=new List<Row>();
            public float lightDifference,shadowDifference;
            public int homeShadowResolution,homeShadowCascades;
        }
        readonly Report report=new Report();GooseGame game;string output,part;bool done;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseHomeShakeQa")>=0)new GameObject("HomeShakeAcceptance").AddComponent<GooseHomeShakeAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string s,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception)report.errors.Add(s+"\n"+stack);}
        void Check(bool ok,string s){(ok?report.checks:report.errors).Add(s);}
        IEnumerator WaitHome(){float until=Time.realtimeSinceStartup+60;while(!game.HomeStage.Ready&&Time.realtimeSinceStartup<until)yield return null;Check(game.HomeStage.Ready,"home ready");yield return new WaitForSecondsRealtime(.65f);}
        IEnumerator Spawn(){float until=Time.realtimeSinceStartup+90;while(!game.SpawnComplete&&Time.realtimeSinceStartup<until)yield return null;Check(game.SpawnComplete,"spawn ready");yield return new WaitForSeconds(2);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-gooseHomeShakeOutput")+1];int at=Array.IndexOf(args,"-gooseHomeShakePart");part=at>=0?args[at+1]:"all";Directory.CreateDirectory(output);
            GooseSave.IsQa=true;yield return null;game=GooseGame.Instance;StartCoroutine(Watchdog());
            if(part!="shake")yield return Home();if(part!="home")yield return Shake();game.GoHome();Finish();
        }
        IEnumerator Home()
        {
            game.GoHome();yield return WaitHome();int table=game.HomeStage.Table.GetInstanceID();
            foreach(var size in new[]{new Vector2Int(360,640),new Vector2Int(390,844),new Vector2Int(430,932)})
            {
                Screen.SetResolution(size.x,size.y,false);yield return new WaitForSecondsRealtime(.3f);
                for(int theme=0;theme<game.Themes.Length;theme++)
                {
                    game.SelectTheme(theme);yield return WaitHome();game.HomeStage.FreezeAnimationForQa=true;
                    Check(game.HomeStage.Table.GetInstanceID()==table,"same furniture survives theme "+theme);
                    var bounds=GooseGame.BoundsOf(game.HomeStage.Table);Check(Mathf.Abs(bounds.size.x-4.6f)<.01f&&Mathf.Abs(bounds.max.y-GooseHomeStage.TableTop)<.01f,"table dimensions and contact height");
                    Check(game.HomeStage.KeyLight.enabled&&game.HomeStage.KeyLight.cullingMask==(1<<28),"isolated home light");
                    report.homeShadowResolution=game.HomeStage.KeyLight.shadowCustomResolution;report.homeShadowCascades=QualitySettings.shadowCascades;
                    Check(report.homeShadowResolution==1024&&report.homeShadowCascades>=0&&report.homeShadowCascades<=1,$"explicit 1024 unsplit home shadow map ({report.homeShadowResolution}/{report.homeShadowCascades})");
                    Check(QualitySettings.antiAliasing==2,"mobile 2x MSAA retained");
                    string file=Path.Combine(output,game.Theme.id+"-home-"+size.x+".png");GooseFrameCapture.Save(file);
                    if(theme==0&&size.x==390)
                    {
                        var key=game.HomeStage.KeyLight;game.HomeStage.SetShadowsForQa(false);yield return null;string flat=Path.Combine(output,"home-no-shadow.png");GooseFrameCapture.Save(flat);
                        game.HomeStage.SetShadowsForQa(true);yield return null;string shadow=Path.Combine(output,"home-shadow.png");GooseFrameCapture.Save(shadow);report.shadowDifference=Difference(flat,shadow);
                        key.intensity=0;yield return null;string unlit=Path.Combine(output,"home-fill-only.png");GooseFrameCapture.Save(unlit);key.intensity=.9f;report.lightDifference=Difference(unlit,shadow);
                        Check(report.shadowDifference>.0001f,"actual shadow pixels differ");Check(report.lightDifference>.003f,"actual direct lighting differs");
                    }
                }
            }
            game.HomeStage.Camera.enabled=false;yield return null;Check(!game.HomeStage.KeyLight.enabled,"suspended view turns off home light");game.HomeStage.Camera.enabled=true;yield return null;Check(game.HomeStage.KeyLight.enabled,"view restore recovers home light");
            int mats=Resources.FindObjectsOfTypeAll<Material>().Length;
            for(int i=0;i<10;i++){game.SelectTheme(i%5);yield return WaitHome();}
            yield return null;Check(Resources.FindObjectsOfTypeAll<Material>().Length<=mats+6,"theme switches do not accumulate runtime materials");game.HomeStage.FreezeAnimationForQa=false;
        }
        IEnumerator Shake()
        {
            Screen.SetResolution(390,844,false);game.InstantPicksForQa=true;
            for(int theme=0;theme<game.Themes.Length;theme++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(1);game.BeginRound(false);yield return Spawn();
                Check(game.LastOpeningCached,"material changes retain validated opening cache "+theme);
                Check(!game.HomeStage.KeyLight.enabled,"home light absent in gameplay "+theme);
                yield return Measure(300,true);
                yield return Reduce(69);
                var template=game.Remaining.First();var extras=new List<GooseItem>();
                for(int i=0;i<2;i++)
                {var item=game.CreateItem(template.Id);item.transform.localScale=template.transform.localScale;item.transform.position=new Vector3((i==0?-.3f:.3f),2.1f,.88f);item.DepthReady=true;extras.Add(item);}
                yield return new WaitForSeconds(3);yield return Measure(71,false);
                game.Forget(extras[0]);Destroy(extras[0].gameObject);yield return new WaitForSeconds(2);yield return Measure(70,false);
                game.Forget(extras[1]);Destroy(extras[1].gameObject);yield return new WaitForSeconds(2);yield return Measure(69,false);
                yield return Reduce(18);yield return Measure(18,false);yield return Reduce(3);yield return Measure(3,false);
            }
        }
        IEnumerator Reduce(int count)
        {
            while(game.Remaining.Count()>count)
            {var triple=game.Remaining.GroupBy(x=>x.Id).First(x=>x.Count()>=3).Take(3).ToArray();foreach(var item in triple)game.Pick(item,true);yield return null;}
            yield return new WaitForSeconds(3);
        }
        IEnumerator Measure(int count,bool sensor)
        {
            var items=game.Remaining.ToArray();Check(items.Length==count,"fixture inventory "+count);
            var baseline=items.ToDictionary(x=>x,x=>x.Body.position.y);int hidden=items.Count(x=>!x.DepthVisible&&x.Body.isKinematic);
            int changes=items.Sum(x=>x.VisibilityChanges),violations=items.Sum(x=>x.ProtectedHideViolations),repairs=items.Sum(x=>x.FloorCorrections);
            var row=new Row{theme=game.Theme.id,stock=count,dynamicBefore=items.Count(x=>!x.Body.isKinematic)};int accepted=game.Shake.Accepted;
            if(sensor)
            {game.Shake.ResetSensor();float t=Time.unscaledTime;for(int i=0;i<8;i++)game.Shake.Sample(Vector3.forward,t+i*.06f);game.Shake.Sample(new Vector3(5,0,1),t+.54f);game.Shake.Sample(new Vector3(-5,0,1),t+.60f);}
            else game.Shake.Request(new Vector3(1,0,.35f));
            Check(game.Shake.Accepted==accepted+1,"one accepted shake "+count);Check(!game.Shake.Request(Vector3.right),"cooldown "+count);
            var frames=new List<float>();float until=Time.time+4;
            while(Time.time<until)
            {
                yield return new WaitForEndOfFrame();frames.Add(Time.unscaledDeltaTime*1000);
                foreach(var item in items)
                {row.minHullY=Mathf.Min(row.minHullY,GooseColliderGeometry.MinY(item.SelectionCollider));row.maxRise=Mathf.Max(row.maxRise,item.Body.position.y-baseline[item]);}
            }
            var motion=game.Shake.LastMotion;Check(motion!=null,"motion completed "+count);
            if(motion!=null){row.affected=motion.affected;row.moved=motion.moved;row.turned=motion.turned;row.maxTravel=motion.maxTravel;row.maxHorizontalImpulse=motion.maxAddedHorizontal;row.maxVerticalImpulse=motion.maxAddedVertical;}
            row.visibilityChanges=items.Sum(x=>x.VisibilityChanges)-changes;row.hideViolations=items.Sum(x=>x.ProtectedHideViolations)-violations;row.floorCorrections=items.Sum(x=>x.FloorCorrections)-repairs;
            row.awakeAfter=items.Count(x=>!x.Body.isKinematic&&!x.Body.IsSleeping());row.recoveryAfter=items.Count(x=>x.PhysicsRecoveryActive);frames.Sort();row.p95ms=frames[(int)((frames.Count-1)*.95f)];
            Check(game.Remaining.Count()==count,"stock conserved "+count);Check(row.affected<=48,"bounded surface cohort "+count);
            var profile=GooseInteractionProfile.Current;
            Check(row.maxHorizontalImpulse<=profile.shakeHorizontalBudget+.002f&&row.maxVerticalImpulse<=profile.shakeVerticalBudget+.002f,"bounded added impulse "+count);
            Check(row.affected>0&&row.moved>0,"nonzero visible shake response "+count);
            Check(row.hideViolations==0,"no protected visibility pop "+count);Check(row.minHullY>=GooseCircularContainer.FloorY-.025f,"floor retained "+count);
            Check(items.All(x=>x.PhysicsRecoveryActive||(Mathf.Abs(x.Body.sleepThreshold-.02f)<.0001f&&Mathf.Abs(x.Body.maxDepenetrationVelocity-1)<.0001f)),"complete normal physics restored "+count);
            if(count==300||count==18)GooseFrameCapture.Save(Path.Combine(output,game.Theme.id+"-after-shake-"+count+".png"));
            report.shakes.Add(row);Save();
        }
        static float Difference(string first,string second)
        {
            var a=new Texture2D(2,2);var b=new Texture2D(2,2);a.LoadImage(File.ReadAllBytes(first));b.LoadImage(File.ReadAllBytes(second));var aa=a.GetPixels32();var bb=b.GetPixels32();double sum=0;
            for(int i=0;i<aa.Length;i++)sum+=Math.Abs(aa[i].r-bb[i].r)+Math.Abs(aa[i].g-bb[i].g)+Math.Abs(aa[i].b-bb[i].b);Destroy(a);Destroy(b);return(float)(sum/(aa.Length*3*255.0));
        }
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(1200);if(!done){report.errors.Add("watchdog");Finish();}}
        void Save(){report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"acceptance.json"),JsonUtility.ToJson(report,true));}
        void Finish(){done=true;Save();Application.Quit(report.passed?0:1);}
    }
}
#endif
