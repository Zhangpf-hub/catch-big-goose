"""Apply bounded runtime changes to the current game, preserving newer story/UI work."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=ROOT/'projects/catch-big-goose-unity/Assets/Scripts/GooseGame.cs'
s=p.read_text(encoding='utf-8-sig')
start=s.index('        IEnumerator Spawn(int token)')
end=s.index('        Vector3 ClearDropPosition',start)
s=s[:start]+'''        public LevelDefinition PrepareLevel()
        {
            var level=SelectedLevel();LevelTuning.Apply(level,Theme,Difficulty);return level;
        }
        public IEnumerator PrepareVisual(string id,bool physics) => assets.Prepare(id,physics);
        public float ScaleForItem(string id,float scale,int index)
        {return (scale+((index+1)%4)*.012f)*(scaleAdjust.TryGetValue(id,out var mult)?mult:1)*itemSizes.Get(id);}
        IEnumerator Spawn(int token)
        {
            float began=Time.realtimeSinceStartup;FirstRevealMs=InteractiveMs=-1;
            Preparation.Request(Theme,Level);
            while(Preparation.State==GooseRoundPreparation.Status.Preparing)
            {
                Hud.ShowPreparing(Mathf.RoundToInt(Preparation.Progress*100),100);
                if(token!=generation||!Playing)yield break;
                yield return null;
            }
            if(Preparation.State!=GooseRoundPreparation.Status.Ready)
            {Debug.LogError("[Goose] preparation failed: "+Preparation.Error);GoHome();Hud.Toast("资源准备失败，请重试");yield break;}
            var opening=new List<GooseItem>(Preparation.Items);
            var preparedPile=Preparation.Pile;var preparedScenery=Preparation.Scenery;
            Container=Preparation.Container;itemScale=Preparation.ItemScale;
            if(pile && pile!=world)Destroy(pile.gameObject);
            if(scenery)Destroy(scenery.gameObject);
            roundRoot=Preparation.Adopt(gameObject.scene);roundRoot.transform.SetParent(world,false);
            pile=preparedPile;scenery=preparedScenery;
            Preparation.Items.Clear();Items.AddRange(opening);
            GooseRoundPreparation.Layer(roundRoot.transform,0);
            ReferenceLighting.Container(scenery.gameObject);Container.Activate(this);
            if(consumePendingAttempt){GooseSave.Daily--;consumePendingAttempt=false;}
            foreach(var item in opening)
            {
                item.DepthProtectedUntil=Time.time;item.DepthStillSince=Time.time;
                if(item.Golden)PaintGold(item);
            }
            Preparing=false;Hud.Refresh();
            float y0=opening[0].transform.position.y,y1=opening[opening.Count-1].transform.position.y;
            float revealStart=Time.time;
            for(int i=0;i<opening.Count;)
            {
                if(token!=generation||!Playing)yield break;
                float now=Time.time-revealStart;
                while(i<opening.Count)
                {
                    float at=(opening[i].transform.position.y-y0)/Mathf.Max(.01f,y1-y0)*1.2f;
                    if(at>now)break;
                    if(FirstRevealMs<0)FirstRevealMs=(Time.realtimeSinceStartup-began)*1000;
                    opening[i].SetDepthVisible(true);StartCoroutine(PopVisual(opening[i]));i++;
                }
                yield return null;
            }
            yield return new WaitForSeconds(.25f);
            foreach(var item in opening)
            {
                item.DepthProtectedUntil=Time.time;item.DepthStillSince=Time.time-AlgorithmSettings.settledDuration;
                item.Body.isKinematic=false;item.Body.collisionDetectionMode=GooseRuntimePerformance.DynamicCollision;
                item.Body.interpolation=RigidbodyInterpolation.Interpolate;item.Body.velocity=item.Body.angularVelocity=Vector3.zero;
            }
            SpawnComplete=true;Depth.SpawnFinished(true);Depth.RefreshNow();
            InteractiveMs=(Time.realtimeSinceStartup-began)*1000;
            Debug.Log($"[Goose] R4 opening {Theme.id} stock={Items.Count} first={FirstRevealMs:0}ms interactive={InteractiveMs:0}ms radius={Container.Radius}");
        }
''' + s[end:]
s=s.replace('        static Quaternion NaturalRotation(', '        public static Quaternion NaturalRotation(')
s=s.replace('while (t < .28f && visual)','while (t < .24f && visual)').replace('float x = Mathf.Clamp01(t / .28f);','float x = Mathf.Clamp01(t / .24f);')
s=s.replace('if (!Playing || Paused || resolving || (!automated && Busy) || !item || item.Picked) return false;',
'''if (!Playing || Paused || Preparing || !SpawnComplete || (!automated && Busy) || !item || item.Picked) return false;''')
s=s.replace('if (!Playing || Paused || resolving || (!automated && Busy) || index < 0',
            'if (!Playing || Paused || (!automated && Busy) || index < 0')
s=s.replace('''            if (matched != null || Tray.Entries.Count >= TrayRules<GooseItem>.Capacity)
            { resolving = true; StartCoroutine(FinishPick(matched, removedPosition, generation)); }''',
'''            if (matched != null)
            {
                pendingMatches++;Presentation.ReserveMatch(matched);Presentation.Retarget(Tray.Entries);
                StartCoroutine(FinishPick(matched,removedPosition,generation));
            }
            else if(Tray.Entries.Count>=TrayRules<GooseItem>.Capacity)
            {fullTrayPending=true;StartCoroutine(FinishPick(null,removedPosition,generation));}''')
a=s.index('        IEnumerator FinishPick(');b=s.index('        void ResolvePick(',a)
s=s[:a]+'''        IEnumerator FinishPick(List<GooseItem> matched, Vector3 removedPosition, int token)
        {
            IList<GooseItem> arrivals=matched ?? (IList<GooseItem>)Tray.Entries.ToArray();
            yield return null;
            while(!Presentation.Arrived(arrivals)){if(token!=generation||!Playing)yield break;yield return null;}
            if(token!=generation||!Playing)yield break;
            if(matched!=null)
            {
                yield return new WaitForSeconds(.05f);
                float time=0;
                while(time<.25f)
                {
                    if(token!=generation||!Playing)yield break;
                    time+=Time.deltaTime;Presentation.Combine(matched,Mathf.Clamp01(time/.25f));yield return null;
                }
                pendingMatches--;
            }
            else
            {
                while(pendingMatches>0){if(token!=generation||!Playing)yield break;yield return null;}
                fullTrayPending=false;
            }
            if(token!=generation||!Playing)yield break;
            ResolvePick(matched,removedPosition);Presentation.Retarget(Tray.Entries);Hud.Refresh();
        }
''' +s[b:]
s=s.replace('''                Removed += 3; Combo''','''                Removed += 3; Container?.MatchCommitted(Removed/(float)Mathf.Max(1,Total)); Combo''')
s=s.replace('''        { if (!GooseSave.Sound) return; var clip = Resources.Load<AudioClip>("Audio/" + id); if (clip) sound.PlayOneShot(clip); }''',
'''        { if (!GooseSave.Sound) return; if(!audioCache.TryGetValue(id,out var clip)){clip=Resources.Load<AudioClip>("Audio/"+id);audioCache[id]=clip;} if(clip)sound.PlayOneShot(clip); }''')
s=s.replace('''if (!Playing || Paused || Busy || Presentation.Moving || !SpawnComplete''','''if (!Playing || Paused || Busy || resolving || Presentation.Moving || !SpawnComplete''')
a=s.index('            var ray = MainCamera.ScreenPointToRay(position);',s.index('public void PickAtScreenPosition'))
b=s.index('\n        }',a)
s=s[:a]+'''            var ray=MainCamera.ScreenPointToRay(position);
            int n=Physics.RaycastNonAlloc(ray,pickHits,100,~((1<<8)|(1<<27)|(1<<28)|(1<<29)|(1<<30)),QueryTriggerInteraction.Ignore);
            RaycastHit nearest=default;float distance=float.PositiveInfinity;
            for(int i=0;i<n;i++)if(pickHits[i].distance<distance){nearest=pickHits[i];distance=nearest.distance;}
            if(nearest.collider)
            {
                var item=nearest.collider.GetComponentInParent<GooseItem>();
                if(item&&!item.Picked&&item.DepthVisible)Pick(item);
            }''' +s[b:]
# Returned pieces must obey the current contracted radius as well.
s=s.replace('''            float xLimit = Mathf.Max(.05f, Theme.halfX - half.x - .08f);''',
'''            if(Container)desired=Container.ClampFootprint(desired,offset,half);
            float xLimit = Mathf.Max(.05f, (Container?Container.Radius:Theme.halfX) - half.x - .08f);''')
s=s.replace('float zLimit = Mathf.Max(.05f, Theme.halfZ - half.z - .08f);','float zLimit = Mathf.Max(.05f, (Container?Container.Radius:Theme.halfZ) - half.z - .08f);')
s=s.replace('Theme.halfX - new Vector2(half.x, half.z).magnitude - .08f','(Container?Container.Radius:Theme.halfX) - new Vector2(half.x, half.z).magnitude - .08f')
p.write_text(s,encoding='utf-8')
print('GooseGame: R4 runtime changes applied')
