#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    public sealed class GooseShakeAcceptance : MonoBehaviour
    {
        [Serializable] public class Row
        {
            public string theme,source;public int stock,remaining,visible,moved,turned,changedNeighbours,accepted,executed;
            public float radius,maxTravel,meanTravel,maxTurn,minHullY=100,maxRadialExcess=-100;
            public bool stockPreserved,trayPreserved,propsPreserved,contactsRestored,radiusPreserved;
        }
        [Serializable] class Report
        {
            public bool passed,baseline;public string scope="Actual native 30 Hz production physics; synthetic sensor input, not phone telemetry.";
            public List<Row> rounds=new List<Row>();public List<string> checks=new List<string>(),errors=new List<string>();
        }
        GooseGame game;Report report=new Report();string output;bool done;
        void Check(bool value,string message){(value?report.checks:report.errors).Add(message);}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string text,string stack,LogType type){if(type==LogType.Exception||type==LogType.Error)report.errors.Add(text+"\n"+stack);}
        IEnumerator Start()
        {
            game=GooseGame.Instance;GooseSave.IsQa=true;
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-gooseShakeOutput");
            output=at>=0?args[at+1]:Path.Combine(Application.persistentDataPath,"shake-qa");Directory.CreateDirectory(output);
            report.baseline=Array.IndexOf(args,"-gooseShakeBaseline")>=0;StartCoroutine(Watchdog());yield return null;
            int themes=report.baseline?1:game.Themes.Length;
            for(int theme=0;theme<themes;theme++)for(int stage=0;stage<2;stage++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(stage);yield return null;
                game.BeginExperienceRound((uint)(155456+theme*7919+stage*101));
                float deadline=Time.realtimeSinceStartup+90;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                Check(game.SpawnComplete,"spawn "+theme+"/"+stage);if(!game.SpawnComplete){Finish();yield break;}
                Check(!game.LastOpeningCached,"alternate seed falls back to live preparation "+theme+"/"+stage);
                yield return new WaitForSeconds(.8f);
                yield return Measure("sensor");
                if(!report.baseline)yield return Measure("button");
                if(stage==1&&!report.baseline)
                {
                    // Fixture only: reduce the inventory through production matches.
                    while(game.Remaining.Count()>18)
                    {
                        var triple=game.Remaining.GroupBy(i=>i.Id).First(g=>g.Count()>=3).Take(3).ToArray();
                        foreach(var item in triple)Check(game.Pick(item,true),"late fixture pick "+theme);
                        yield return new WaitForSeconds(.05f);
                    }
                    yield return new WaitForSeconds(3);
                    yield return Measure("contracted");
                }
            }
            game.GoHome();Finish();
        }
        IEnumerator Measure(string source)
        {
            var items=game.Remaining.ToArray();var visible=items.Where(i=>i.DepthVisible).ToArray();
            var positions=items.ToDictionary(i=>i,i=>i.Body.position);var rotations=items.ToDictionary(i=>i,i=>i.Body.rotation);
            var travel=items.ToDictionary(i=>i,i=>0f);var turn=items.ToDictionary(i=>i,i=>0f);
            var neighbours=visible.ToDictionary(i=>i,i=>Nearest(i,visible));
            var props=game.Props.ToArray();var tray=game.Tray.Entries.ToArray();
            var materials=items.ToDictionary(i=>i,i=>i.SelectionCollider.sharedMaterial);float radius=game.Container.Radius;
            int accepted=game.Shake.Accepted,executed=game.ShakeDiagnostics.State.Applied;
            string key=game.Theme.id+"-"+game.Total+"-"+source;
            GooseFrameCapture.Save(Path.Combine(output,key+"-before.png"));
            if(source=="sensor")
            {
                game.Shake.ResetSensor();float t=Time.unscaledTime;
                for(int i=0;i<8;i++)game.Shake.Sample(Vector3.forward,t+i*.06f);
                game.Shake.Sample(new Vector3(5,0,1),t+.54f);game.Shake.Sample(new Vector3(-5,0,1),t+.60f);
                Check(game.Shake.Accepted==accepted+1,"sensor accepted "+key);
            }
            else Check(game.Shake.Request(new Vector3(1,0,.35f)),"manual accepted "+key);
            Check(!game.Shake.Request(Vector3.right),"cooldown rejects duplicate "+key);
            var row=new Row{theme=game.Theme.id,source=source,stock=game.Total,remaining=items.Length,visible=visible.Length,radius=game.Container.Radius};
            float until=Time.time+2.2f;bool captured=false;
            while(Time.time<until)
            {
                yield return new WaitForEndOfFrame();
                foreach(var i in items)
                {
                    travel[i]=Mathf.Max(travel[i],Vector3.Distance(positions[i],i.Body.position));
                    turn[i]=Mathf.Max(turn[i],Quaternion.Angle(rotations[i],i.Body.rotation));
                    row.minHullY=Mathf.Min(row.minHullY,GooseColliderGeometry.MinY(i.SelectionCollider));
                    row.minHullY=Mathf.Min(row.minHullY,GooseColliderGeometry.MinY(i.SelectionCollider,GooseColliderGeometry.BodyMatrix(i.SelectionCollider,i.Body)));
                    float radial=new Vector2(i.Body.position.x,i.Body.position.z-GooseCircularContainer.CenterZ).magnitude;
                    row.maxRadialExcess=Mathf.Max(row.maxRadialExcess,radial-game.Container.Radius);
                }
                if(!captured&&Time.time>until-1.85f){captured=true;GooseFrameCapture.Save(Path.Combine(output,key+"-moving.png"));}
            }
            GooseFrameCapture.Save(Path.Combine(output,key+"-after.png"));
            float distance=Mathf.Max(.12f,game.ItemScale*.35f);
            row.moved=visible.Count(i=>travel[i]>=distance);row.turned=visible.Count(i=>turn[i]>=30);
            row.changedNeighbours=visible.Count(i=>Nearest(i,visible)!=neighbours[i]);
            row.maxTravel=visible.Max(i=>travel[i]);row.meanTravel=visible.Average(i=>travel[i]);row.maxTurn=visible.Max(i=>turn[i]);
            row.accepted=game.Shake.Accepted-accepted;row.executed=game.ShakeDiagnostics.State.Applied-executed;
            row.stockPreserved=game.Remaining.Count()==items.Length;row.propsPreserved=game.Props.SequenceEqual(props);row.trayPreserved=game.Tray.Entries.SequenceEqual(tray);
            row.contactsRestored=items.All(i=>i.SelectionCollider.sharedMaterial==materials[i]);row.radiusPreserved=Mathf.Abs(game.Container.Radius-radius)<.001f;
            Check(row.accepted==1&&row.executed==1,"one accepted burst and one execution "+key);
            Check(row.stockPreserved&&row.propsPreserved&&row.trayPreserved,"inventory tray props preserved "+key);
            Check(row.contactsRestored&&row.radiusPreserved,"contact materials restored and basket radius preserved "+key);
            Check(row.minHullY>=GooseCircularContainer.FloorY-.025f,"floor support through shake "+key);
            Check(row.maxRadialExcess<=.10f,"circular containment through shake "+key);
            if(!report.baseline)
            {
                Check(row.moved>=Mathf.CeilToInt(visible.Length*(source=="contracted"?.45f:.25f)),"visible items travel substantially "+key);
                Check(row.turned>=Mathf.CeilToInt(visible.Length*(source=="contracted"?.35f:.2f)),"visible items turn substantially "+key);
                Check(row.changedNeighbours>=Mathf.CeilToInt(visible.Length*(source=="contracted"?.3f:.2f)),"visible neighbour relationships change "+key);
            }
            report.rounds.Add(row);Save();
        }
        static GooseItem Nearest(GooseItem item,GooseItem[] items)
        {GooseItem result=null;float best=float.PositiveInfinity;foreach(var other in items)if(other!=item){float d=(other.Body.position-item.Body.position).sqrMagnitude;if(d<best){best=d;result=other;}}return result;}
        IEnumerator Watchdog(){yield return new WaitForSecondsRealtime(600);if(!done){report.errors.Add("watchdog");Finish();}}
        void Save(){report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"shake-acceptance.json"),JsonUtility.ToJson(report,true));}
        void Finish(){if(done)return;done=true;Save();Application.Quit(report.passed?0:1);}
    }
}
#endif
