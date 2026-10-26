#requires -Version 7.0
param([string]$SourcePath='projects/catch-big-goose-unity/Assets/Scripts/GooseWeChatPlatform.cs',[Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference='Stop'
$taskSource=(Resolve-Path -LiteralPath $SourcePath).Path
$taskText=Get-Content -LiteralPath $taskSource -Raw -Encoding UTF8
$taskStart=$taskText.IndexOf('        void Acceleration(')
$taskEnd=$taskText.IndexOf('        void Hidden(', $taskStart)
if($taskStart -lt 0 -or $taskEnd -lt 0){throw 'Actual lifecycle method block not found'}
$taskControl=$taskText.Substring($taskStart,$taskEnd-$taskStart)
$taskKeep=[regex]::Match($taskText,'public static bool KeepAccelerometer[\s\S]*?;').Value
if(-not $taskKeep){throw 'Actual listener-intent method not found'}
$taskPrefix=@'
using System;
using System.Collections.Generic;
namespace SensorLifecycleCheck {
public class Vector3 {public Vector3(float x,float y,float z){}}
public class OnAccelerometerChangeListenerResult {public double x,y,z;}
public class Result {public string errMsg="mock";}
public class StartAccelerometerOption {public string interval;public Action<Result> success,fail,complete;}
public class StopAccelerometerOption {public Action<Result> success,fail,complete;}
public static class Time {public static float unscaledTime;}
public static class Debug {public static void Log(string x){}public static void LogWarning(string x){}}
public static class WX {
 public static List<StartAccelerometerOption> starts=new List<StartAccelerometerOption>();
 public static List<StopAccelerometerOption> stops=new List<StopAccelerometerOption>();
 public static Action<OnAccelerometerChangeListenerResult> listener;public static bool autoSuccess=true;
 public static void Reset(){starts.Clear();stops.Clear();listener=null;autoSuccess=true;Time.unscaledTime=0;}
 public static void OnAccelerometerChange(Action<OnAccelerometerChangeListenerResult> x){listener=x;}
 public static void OffAccelerometerChange(Action<OnAccelerometerChangeListenerResult> x){if(listener==x)listener=null;}
 public static void StartAccelerometer(StartAccelerometerOption x){starts.Add(x);if(autoSuccess)x.success(new Result());}
 public static void StopAccelerometer(StopAccelerometerOption x){stops.Add(x);}
 public static void Complete(int n,bool failed=false){var x=stops[n];if(failed)x.fail(new Result());else x.success(new Result());x.complete(new Result());}
}
public class Shake {public bool SensorAvailable;public int callbacks,resets;public static implicit operator bool(Shake x)=>x!=null;
 public void ResetSensor(){resets++;}public void Sample(Vector3 v,float t){callbacks++;}}
public class Diagnostics {int attempt;public static implicit operator bool(Diagnostics x)=>x!=null;
 public int Begin()=>++attempt;public bool StartResult(int n,bool success,string msg)=>n==attempt;
 public void Stop(string x){}public void Callback(Vector3 x){} }
public class Game {public bool Playing=true,TransitioningToChallenge,Paused,AppVisible=true,SpawnComplete=true;
 public Shake Shake=new Shake();public Diagnostics ShakeDiagnostics=new Diagnostics();public static implicit operator bool(Game x)=>x!=null;}
public class Subject {
 public static implicit operator bool(Subject x)=>x!=null;
 public Game game=new Game();bool HandlesPointer=true;
 bool accelerometer,accelerometerWanted,accelerometerStopping;int accelerometerGeneration,accelerometerAttempts,accelerometerStopGeneration;
 float nextAccelerometerRetry;Action<OnAccelerometerChangeListenerResult> accelerometerHandler;
 void ApplyFrameRate(){}public void Tick(){Update();}public void Pause(){game.Paused=true;Tick();}public void Resume(){game.Paused=false;Tick();}
'@
$taskSuffix=@'
}
public class Report {public bool passed;public string scope="Actual source lifecycle method block compiled unchanged against a controlled asynchronous SDK mock; not WeChat or phone runtime evidence.";
 public List<string> checks=new List<string>(),errors=new List<string>();}
public static class Suite {
 static void Assert(bool x,string text){if(!x)throw new Exception(text);}
 static Subject New(){WX.Reset();var s=new Subject();s.Tick();Assert(WX.starts.Count==1,"initial start");return s;}
 static void Case(Report r,string name,Action test){try{test();r.checks.Add(name);}catch(Exception e){r.errors.Add(name+": "+e.Message);}}
 public static Report Run(){var r=new Report();
  Case(r,"pause/resume/pause coalesces pending stop",()=>{var s=New();s.Pause();s.Resume();s.Pause();Assert(WX.stops.Count==1,"duplicate Stop issued while first Stop pending");s.Resume();Assert(WX.starts.Count==1,"new Start before Stop complete");WX.Complete(0);s.Tick();Assert(WX.starts.Count==2,"next Start after Stop complete");});
  Case(r,"failed Stop complete releases the wait",()=>{var s=New();s.Pause();s.Resume();Assert(WX.starts.Count==1,"Start during pending failed stop");WX.Complete(0,true);s.Tick();Assert(WX.starts.Count==2,"failed stop completion left listener blocked");});
  Case(r,"old completion cannot release a newer pending stop",()=>{var s=New();s.Pause();s.Resume();WX.Complete(0);s.Tick();s.Pause();s.Resume();Assert(WX.stops.Count==2,"second real stop missing");WX.stops[0].complete(new Result());s.Tick();Assert(WX.starts.Count==2,"stale old completion unblocked newer stop");WX.Complete(1);s.Tick();Assert(WX.starts.Count==3,"latest completion did not release gate");});
  Case(r,"tutorial transition retains the current listener",()=>{var s=New();var listener=WX.listener;s.game.Playing=false;s.game.TransitioningToChallenge=true;s.game.SpawnComplete=false;s.Tick();Assert(WX.stops.Count==0&&WX.starts.Count==1&&WX.listener==listener,"transition restarted listener");s.game.Playing=true;s.game.TransitioningToChallenge=false;s.Tick();Assert(WX.stops.Count==0&&WX.starts.Count==1,"preparing challenge restarted listener");});
  Case(r,"queued callbacks from a retired generation are ignored",()=>{var s=New();var old=WX.listener;s.Pause();s.Resume();WX.Complete(0);s.Tick();int before=s.game.Shake.callbacks;old(new OnAccelerometerChangeListenerResult());Assert(s.game.Shake.callbacks==before,"old callback reached new stream");WX.listener(new OnAccelerometerChangeListenerResult());Assert(s.game.Shake.callbacks==before+1,"current callback rejected");});
  Case(r,"late start success cannot overwrite new attempt",()=>{WX.Reset();WX.autoSuccess=false;var s=new Subject();s.Tick();var old=WX.starts[0];s.Pause();s.Resume();WX.Complete(0);s.Tick();old.success(new Result());Assert(!s.game.Shake.SensorAvailable,"old success marked new listener available");WX.starts[1].success(new Result());Assert(s.game.Shake.SensorAvailable,"current success not applied");});
  Case(r,"start failure retries remain bounded",()=>{WX.Reset();WX.autoSuccess=false;var s=new Subject();for(int n=0;n<3;n++){s.Tick();Assert(WX.starts.Count==n+1,"retry missing");WX.starts[n].fail(new Result());Time.unscaledTime+=2;}s.Tick();Assert(WX.starts.Count==3,"unbounded start retry");});
  r.passed=r.errors.Count==0;return r;
 }
}
}
'@
$taskCode=$taskPrefix+"`n"+$taskControl+"`n"+$taskKeep+"`n"+$taskSuffix
Add-Type -TypeDefinition $taskCode -IgnoreWarnings
$taskResult=[SensorLifecycleCheck.Suite]::Run()
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
$taskResult | Add-Member -NotePropertyName sourceSha256 -NotePropertyValue (Get-FileHash -LiteralPath $taskSource -Algorithm SHA256).Hash.ToLowerInvariant()
$taskHasher=[Security.Cryptography.SHA256]::Create()
try{$taskHash=[BitConverter]::ToString($taskHasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($taskControl+$taskKeep))).Replace('-','').ToLowerInvariant()}finally{$taskHasher.Dispose()}
$taskResult | Add-Member -NotePropertyName testedMethodBlockSha256 -NotePropertyValue $taskHash
$taskResult | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputPath 'sensor-lifecycle.json') -Encoding UTF8
$taskResult | ConvertTo-Json -Depth 5
if(-not $taskResult.passed){exit 1}
