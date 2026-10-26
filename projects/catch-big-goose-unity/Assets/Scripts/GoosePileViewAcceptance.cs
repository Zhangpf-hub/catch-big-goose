#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Compare the same frozen physical stock through different camera angles.
    // Then exercise matches and shake at the shipped angle, without rescaling it.
    public sealed class GoosePileViewAcceptance : MonoBehaviour
    {
        [Serializable] sealed class Row
        {
            public string theme,phase; public float pitch,maxHeight,minScreenY,maxScreenY,itemScale,radius;
            public int stock,visible,clippedCentres,rayHits; public Rect viewport;
        }
        [Serializable] sealed class Report
        {
            public bool passed; public int width,height;
            public List<Row> rows=new List<Row>(); public List<string> errors=new List<string>();
        }
        readonly Report report=new Report(); string output; GooseGame game; GoosePhoneLayout layout;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)] static void Boot()
        {if(Array.IndexOf(Environment.GetCommandLineArgs(),"-goosePileViewQa")>=0)new GameObject("PileViewQA").AddComponent<GoosePileViewAcceptance>();}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs(); output=args[Array.IndexOf(args,"-goosePileViewOutput")+1];Directory.CreateDirectory(output);
            GooseSave.IsQa=true; yield return null; game=GooseGame.Instance;layout=FindObjectOfType<GoosePhoneLayout>();
            report.width=Screen.width;report.height=Screen.height;
            for(int theme=0;theme<game.Themes.Length;theme++)
            {
                game.GoHome();game.SelectTheme(theme);game.SelectDifficulty(1);game.BeginRound(false);
                float deadline=Time.realtimeSinceStartup+100;
                while(!game.SpawnComplete&&Time.realtimeSinceStartup<deadline)yield return null;
                if(!game.SpawnComplete){report.errors.Add("Opening timeout "+game.Theme.id);break;}
                yield return new WaitForSeconds(2);
                game.SetPaused(true);
                Capture("before",64,false);Capture("near-overhead",84,false);Capture("opening",GoosePhoneLayout.GameplayPitch,true);
                game.SetPaused(false);
                // Six complete groups reproduce the reported 18/300 progress.
                var groups=game.Remaining.GroupBy(x=>x.Id).Where(g=>g.Count()>=3).OrderByDescending(g=>g.Max(x=>x.transform.position.y)).Take(6).Select(g=>g.OrderByDescending(x=>x.transform.position.y).Take(3).ToArray()).ToArray();
                foreach(var group in groups)
                {
                    foreach(var item in group)if(!game.Pick(item,true))report.errors.Add("Match rejected "+item.Id);
                    yield return new WaitForSeconds(.65f);
                }
                yield return new WaitForSeconds(1);
                if(game.Removed!=18)report.errors.Add("Expected 18 removed: "+game.Theme.id+" "+game.Removed);
                game.SetPaused(true);Capture("removed-18",GoosePhoneLayout.GameplayPitch,true);game.SetPaused(false);
                if(!game.Shake.Request(new Vector3(1,0,.35f)))report.errors.Add("Shake rejected "+game.Theme.id);
                for(int sample=0;sample<4;sample++)
                {yield return new WaitForSeconds(.25f);Capture("shake-"+sample,GoosePhoneLayout.GameplayPitch,true,sample==2);}
                yield return new WaitForSeconds(3);Capture("settled",GoosePhoneLayout.GameplayPitch,true);
            }
            game.GoHome();report.passed=report.rows.Count==game.Themes.Length*9&&report.errors.Count==0;Save();Application.Quit(report.passed?0:1);
        }
        void Capture(string phase,float pitch,bool verify,bool screenshot=true)
        {
            var camera=game.MainCamera;camera.transform.rotation=Quaternion.Euler(pitch,0,0);layout.Refresh(true);Physics.SyncTransforms();
            var row=new Row{theme=game.Theme.id,phase=phase,pitch=pitch,stock=game.Remaining.Count(),itemScale=game.ItemScale,radius=game.Container.Radius,
                viewport=camera.pixelRect,maxHeight=game.Remaining.Max(x=>x.transform.position.y),minScreenY=float.PositiveInfinity,maxScreenY=float.NegativeInfinity};
            foreach(var item in game.Remaining)
            {
                if(!item.DepthVisible)continue;row.visible++;
                var bounds=GooseGame.BoundsOf(item.Visual.gameObject);var center=camera.WorldToScreenPoint(bounds.center);
                if(!camera.pixelRect.Contains(new Vector2(center.x,center.y)))row.clippedCentres++;
                var ray=camera.ScreenPointToRay(center);
                if(Physics.RaycastAll(ray,100,~((1<<2)|(1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30))).Any(h=>h.collider.GetComponentInParent<GooseItem>()==item))row.rayHits++;
                for(int c=0;c<8;c++)
                {
                    var p=camera.WorldToScreenPoint(new Vector3((c&1)==0?bounds.min.x:bounds.max.x,(c&2)==0?bounds.min.y:bounds.max.y,(c&4)==0?bounds.min.z:bounds.max.z));
                    row.minScreenY=Mathf.Min(row.minScreenY,p.y);row.maxScreenY=Mathf.Max(row.maxScreenY,p.y);
                }
            }
            if(verify&&(row.clippedCentres>0||row.rayHits==0))report.errors.Add(row.theme+"/"+phase+" clipped="+row.clippedCentres+" hits="+row.rayHits);
            report.rows.Add(row);if(screenshot)GooseFrameCapture.Save(Path.Combine(output,row.theme+"-"+phase+".png"));Save();
        }
        void Save(){File.WriteAllText(Path.Combine(output,"pile-view.json"),JsonUtility.ToJson(report,true));}
    }
}
#endif
