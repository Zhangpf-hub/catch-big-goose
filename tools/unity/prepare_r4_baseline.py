"""Create an isolated before-change project; never swap the live project's files."""
from pathlib import Path
import shutil,json
ROOT=Path(__file__).resolve().parents[2]
out=ROOT/'work/r4-interaction-20261025/baseline-project'
if out.exists():raise SystemExit('Baseline project already exists; preserve it.')
(out/'Assets').mkdir(parents=True)
for folder in ['Resources','Scenes','Plugins','Mascots']:
    if (ROOT/'projects/catch-big-goose-unity/Assets'/folder).exists():shutil.copytree(ROOT/'projects/catch-big-goose-unity/Assets'/folder,out/'Assets'/folder)
shutil.copytree(ROOT/'work/r4-interaction-20261025/baseline/Scripts',out/'Assets/Scripts')
for p in (ROOT/'work/r4-interaction-20261025/baseline/Data').iterdir():
    if p.is_file():shutil.copy2(p,out/'Assets/Resources/Data'/p.name)
shutil.copytree(ROOT/'projects/catch-big-goose-unity/ProjectSettings',out/'ProjectSettings')
(out/'Packages').mkdir()
for name in ['manifest.json','packages-lock.json']:
    if(ROOT/'projects/catch-big-goose-unity/Packages'/name).exists():shutil.copy2(ROOT/'projects/catch-big-goose-unity/Packages'/name,out/'Packages'/name)
shutil.copytree(ROOT/'projects/catch-big-goose-unity/Packages/com.qq.weixin.minigame',out/'Packages/com.qq.weixin.minigame')
p=out/'Assets/Scripts/GooseGame.cs';s=p.read_text(encoding='utf-8-sig')
s=s.replace('''#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
            if (Array.IndexOf''','''#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
            if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseR3Capture")>=0){GooseSave.IsQa=true;gameObject.AddComponent<GooseR3Capture>();return;}
            if (Array.IndexOf''',1)
p.write_text(s,encoding='utf-8')
(out/'Assets/Scripts/GooseR3Capture.cs').write_text('''#if UNITY_EDITOR || DEVELOPMENT_BUILD
using System;using System.IO;using System.Collections;using System.Linq;using UnityEngine;
namespace CatchGoose{
public sealed class GooseR3Capture:MonoBehaviour{
 IEnumerator Start(){
 var g=GooseGame.Instance;GooseSave.IsQa=true;var args=Environment.GetCommandLineArgs();int a=Array.IndexOf(args,"-gooseR3Output");string output=args[a+1];Directory.CreateDirectory(output);
 yield return null;g.GoHome();g.SelectTheme(0);g.SelectDifficulty(1);float start=Time.realtimeSinceStartup;g.BeginRound(false);float first=-1;bool middle=false;
 while(!g.SpawnComplete&&Time.realtimeSinceStartup-start<60){
 if(first<0&&g.Items.Any(i=>i.DepthVisible)){first=(Time.realtimeSinceStartup-start)*1000;GooseFrameCapture.Save(Path.Combine(output,"r3-opening-bottom.png"));}
 if(!middle&&g.Items.Count(i=>i.DepthVisible)>g.Total/2){middle=true;GooseFrameCapture.Save(Path.Combine(output,"r3-opening-middle.png"));}yield return null;}
 float interactive=(Time.realtimeSinceStartup-start)*1000;yield return new WaitForSeconds(.5f);GooseFrameCapture.Save(Path.Combine(output,"r3-opening-complete.png"));
 var report=new Report{firstMs=first,interactiveMs=interactive,total=g.Total,seed=g.Level.seed,managedBytes=GC.GetTotalMemory(false),allocatedBytes=UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong()};
 File.WriteAllText(Path.Combine(output,"baseline.json"),JsonUtility.ToJson(report,true));g.GoHome();Application.Quit(g.SpawnComplete?0:0);
 }
 [Serializable]class Report{public float firstMs,interactiveMs;public int total;public uint seed;public long managedBytes,allocatedBytes;}
}}
#endif
''',encoding='utf-8')
(out/'Assets/Editor').mkdir()
(out/'Assets/Editor/BaselineBuild.cs').write_text('''using System;using UnityEditor;namespace CatchGoose.Editor{public static class BaselineBuild{public static void Build(){var r=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName="Builds/R3Baseline.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.Development});if(r.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("baseline build failed");}}}''',encoding='utf-8')
(out/'baseline-origin.json').write_text(json.dumps(dict(scope='Frozen source and data captured before this R4 implementation; models/materials copied from current shared resources. No production files replaced.',source=str(ROOT/'work/r4-interaction-20261025/baseline')),indent=2),encoding='utf-8')
print(out)
