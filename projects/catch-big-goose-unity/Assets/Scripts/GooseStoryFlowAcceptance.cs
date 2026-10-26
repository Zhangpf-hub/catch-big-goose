#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    public sealed class GooseStoryFlowAcceptance:MonoBehaviour
    {
        [Serializable] class Report{public bool passed;public List<string> checks=new List<string>(),errors=new List<string>();}
        readonly Report report=new Report();string output;GooseGame game;
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot()
        {if(Environment.GetCommandLineArgs().Contains("-storyFlowQa"))new GameObject("StoryFlowQa").AddComponent<GooseStoryFlowAcceptance>();}
        void Check(bool ok,string message){(ok?report.checks:report.errors).Add(message);}
        IEnumerator Spawn()
        {float deadline=Time.realtimeSinceStartup+120;while(!game.SpawnComplete&&game.Playing&&Time.realtimeSinceStartup<deadline)yield return null;Check(game.SpawnComplete,"Production start completed");yield return new WaitForSeconds(.3f);}
        IEnumerator Start()
        {
            var args=Environment.GetCommandLineArgs();output=args[Array.IndexOf(args,"-storyOutput")+1];Directory.CreateDirectory(output);GooseSave.IsQa=true;yield return null;game=GooseGame.Instance;
            foreach(string suffix in new[]{"stage_","intro_","challenge_"})PlayerPrefs.DeleteKey("goose_unity_qa_story1_"+suffix+"barbecue");
            GooseSave.Daily=3;game.GoHome();game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id=="barbecue"));game.SelectDifficulty(0);
            game.Hud.Home.GetComponentsInChildren<Button>().Single(b=>b.name=="StartChallenge").onClick.Invoke();yield return Spawn();
            Check(game.Difficulty==0&&game.Total==15&&game.Level.seconds==0,"Home button starts the 15-item untimed tutorial");Check(GooseSave.Daily==3,"Tutorial does not consume a challenge attempt");
            game.InstantPicksForQa=true;foreach(var g in game.Remaining.GroupBy(i=>i.Id).ToList()){foreach(var i in g.ToList())game.Pick(i,true);yield return null;}
            Check(game.LastResult=="win"&&GooseSave.TutorialComplete("barbecue"),"Tutorial win unlocks this theme's challenge");
            var next=game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.GetComponentsInChildren<Text>().Any(t=>t.text=="挑战第二关"));next.onClick.Invoke();yield return Spawn();
            Check(game.Difficulty==1&&game.Total==300&&game.Level.seconds==600,"Next button enters the source second stage");Check(GooseSave.Daily==2,"Entering the challenge consumes exactly one attempt");
            game.EndRound(false,"槽位已满");game.Hud.Modal.GetComponentsInChildren<Button>().Single(b=>b.GetComponentsInChildren<Text>().Any(t=>t.text=="重试本关")).onClick.Invoke();yield return Spawn();
            Check(game.Difficulty==1&&game.Total==300&&GooseSave.Daily==2,"Retry stays in the second stage without a duplicate attempt charge");
            game.InstantPicksForQa=true;foreach(var g in game.Remaining.GroupBy(i=>i.Id).ToList()){foreach(var i in g.ToList())game.Pick(i,true);yield return null;}
            Check(game.LastResult=="win"&&GooseSave.ChallengeComplete("barbecue"),"Challenge completion saved");
            Check(!game.Hud.Modal.GetComponentsInChildren<Text>().Any(t=>t.text=="下一关"),"No third-stage action is exposed");
            game.GoHome();game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id=="toys"));game.SelectDifficulty(0);game.SelectTheme(Array.FindIndex(game.Themes,t=>t.id=="barbecue"));Check(game.Difficulty==1,"Theme selection restores that theme's own stage");
            report.passed=report.errors.Count==0;File.WriteAllText(Path.Combine(output,"flow-acceptance.json"),JsonUtility.ToJson(report,true));Application.Quit(report.passed?0:1);
        }
    }
}
#endif
