#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Scene-space projection measurements, not guessed pixels from the artwork.
    public sealed class GooseScaleAcceptance:MonoBehaviour
    {
        [Serializable] class ItemProjection {public string id;public float widthRatio,longEdgeRatio,xMin,yMin,xMax,yMax;}
        [Serializable] class Row
        {
            public string theme;public int stock,visible,outOfBounds,clippedCentres;
            public float medianWidthRatio,medianLongEdgeRatio,p90LongEdgeRatio,minHeight,maxHeight,worldWidth;
            public Rect viewport;public Vector3 cameraPosition;public List<ItemProjection> items=new List<ItemProjection>();
        }
        [Serializable] class Report
        {
            public string build=GooseRuntimePerformance.BuildId,scope="Native forced-mobile profile, actual renderer AABB projections. No competitor runtime or iPhone FPS measured.";
            public bool passed;public int width,height;public List<Row> rows=new List<Row>();public List<string> errors=new List<string>();
        }
        readonly Report report=new Report();string output;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseScaleQa")>=0)new GameObject("ScaleAcceptance").AddComponent<GooseScaleAcceptance>();}
        void OnEnable(){Application.logMessageReceived+=Log;}
        void OnDisable(){Application.logMessageReceived-=Log;}
        void Log(string message,string stack,LogType type){if(type==LogType.Error||type==LogType.Exception||type==LogType.Assert)report.errors.Add(message+"\n"+stack);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();int at=Array.IndexOf(args,"-gooseScaleOutput");output=args[at+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true;yield return null;report.width=Screen.width;report.height=Screen.height;
            var game=GooseGame.Instance;
            for(int i=0;i<7;i++)
            {
                game.GoHome();game.SelectTheme(i<5?i:0);game.SelectDifficulty(2);
                if(i<5)game.BeginExperienceRound(155921);else game.BeginReferenceTrial(i==5?126:300);
                float deadline=Time.realtimeSinceStartup+75;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                if(!game.SpawnComplete){report.errors.Add("Spawn deadline "+game.Theme.id);break;}
                yield return new WaitForSeconds(2);
                var camera=game.MainCamera;
                var row=new Row{theme=game.Theme.id,stock=game.Total,viewport=camera.rect,cameraPosition=camera.transform.position,
                    worldWidth=camera.orthographicSize*2*camera.aspect,minHeight=float.PositiveInfinity,maxHeight=float.NegativeInfinity};
                foreach(var item in game.Remaining)
                {
                    row.minHeight=Mathf.Min(row.minHeight,item.transform.position.y);row.maxHeight=Mathf.Max(row.maxHeight,item.transform.position.y);
                    if(item.transform.position.y<-.65f||Mathf.Abs(item.transform.position.x)>2.4f||Mathf.Abs(item.transform.position.z-.88f)>2.4f)row.outOfBounds++;
                    if(!item.DepthVisible)continue;
                    var b=GooseGame.BoundsOf(item.Visual.gameObject);
                    var p=new ItemProjection{id=item.Id,xMin=float.PositiveInfinity,yMin=float.PositiveInfinity,xMax=float.NegativeInfinity,yMax=float.NegativeInfinity};
                    for(int c=0;c<8;c++)
                    {
                        var corner=new Vector3((c&1)==0?b.min.x:b.max.x,(c&2)==0?b.min.y:b.max.y,(c&4)==0?b.min.z:b.max.z);
                        var point=camera.WorldToScreenPoint(corner);p.xMin=Mathf.Min(p.xMin,point.x);p.yMin=Mathf.Min(p.yMin,point.y);p.xMax=Mathf.Max(p.xMax,point.x);p.yMax=Mathf.Max(p.yMax,point.y);
                    }
                    p.widthRatio=(p.xMax-p.xMin)/camera.pixelWidth;p.longEdgeRatio=Mathf.Max(p.xMax-p.xMin,p.yMax-p.yMin)/camera.pixelWidth;
                    if(!camera.pixelRect.Contains(new Vector2((p.xMin+p.xMax)/2,(p.yMin+p.yMax)/2)))row.clippedCentres++;
                    row.items.Add(p);
                }
                row.visible=row.items.Count;var widths=row.items.Select(x=>x.widthRatio).OrderBy(x=>x).ToArray();var longs=row.items.Select(x=>x.longEdgeRatio).OrderBy(x=>x).ToArray();
                row.medianWidthRatio=widths[widths.Length/2];row.medianLongEdgeRatio=longs[longs.Length/2];row.p90LongEdgeRatio=longs[(int)((longs.Length-1)*.9f)];
                if(row.outOfBounds>0||row.clippedCentres>0)report.errors.Add(row.theme+" escaped/clipped "+row.outOfBounds+"/"+row.clippedCentres);
                if(row.medianLongEdgeRatio<.13f||row.medianLongEdgeRatio>.36f)report.errors.Add(row.theme+" silhouette median outside screenshot-calibrated own interval");
                report.rows.Add(row);GooseFrameCapture.Save(Path.Combine(output,row.theme+"-"+row.stock+".png"),Screen.width,Screen.height);Save();
            }
            game.GoHome();report.passed=report.rows.Count==7&&report.errors.Count==0;Save();Application.Quit(report.passed?0:1);
        }
        void Save(){File.WriteAllText(Path.Combine(output,"proportions.json"),JsonUtility.ToJson(report,true));}
    }
}
#endif
