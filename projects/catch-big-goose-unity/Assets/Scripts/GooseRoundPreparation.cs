using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace CatchGoose
{
    // A manually simulated physics scene is invisible to gameplay queries.
    // Its actual objects are adopted on start, rather than instantiated twice.
    public sealed class GooseRoundPreparation : MonoBehaviour
    {
        public enum Status { Idle, Preparing, Ready, Failed, Cancelled }
        public Status State { get; private set; }
        public string Key { get; private set; }
        public string Error { get; private set; }
        public float Progress { get; private set; }
        public float PrepareMs { get; private set; }
        public bool UsedBakedLayout {get;private set;}
        public float ItemScale { get; private set; }
        public GameObject Root { get; private set; }
        public Transform Pile { get; private set; }
        public Transform Scenery { get; private set; }
        public GooseCircularContainer Container { get; private set; }
        public readonly List<GooseItem> Items = new List<GooseItem>();
        GooseGame game;
        Scene scene;
        Coroutine job;
        int request;
        string lastAutoSelection;
        readonly Collider[] overlaps=new Collider[1024];
        GoosePreparedLayouts baked;
        public void Initialize(GooseGame owner){game=owner;}
        public static string MakeKey(ThemeDefinition theme,LevelDefinition level)
        { return theme.id+":"+theme.container+":"+JsonUtility.ToJson(level)+":"+GooseRuntimePerformance.BuildId+":"+(GooseGame.Instance?GooseGame.Instance.ModelSize:GooseSave.ModelSize).ToString("F2",System.Globalization.CultureInfo.InvariantCulture); }
        void Update()
        {
            if(!game)return;
            if(game.Video&&game.Video.Active)return;
            if(game.Playing)
            {
                // The small tutorial leaves enough budget to prepare the next
                // challenge while the player is learning, before the result page.
                if(game.SpawnComplete&&!game.Paused&&!game.ReferenceTrial&&!game.DuckReviewActive&&game.Difficulty==0)
                {
                    string selection="next:"+game.Theme.id;
                    if(lastAutoSelection==selection&&State!=Status.Idle&&State!=Status.Cancelled)return;
                    lastAutoSelection=selection;
                    var next=game.ThemeRounds.Create(game.Theme,1);game.LevelTuning.Apply(next,game.Theme,1);Request(game.Theme,next);
                }
                return;
            }
            if(game.Hud.Home&&game.Hud.Home.activeInHierarchy)
            {
                string selection="home:"+game.Theme.id+":"+game.Difficulty;
                if(lastAutoSelection==selection&&State!=Status.Idle&&State!=Status.Cancelled)return;
                lastAutoSelection=selection;Request(game.Theme,game.PrepareLevel());
            }
        }
        public void Request(ThemeDefinition theme,LevelDefinition level,bool retry=false)
        {
            string key=MakeKey(theme,level);
            if(Key==key&&(State==Status.Ready||State==Status.Preparing||(State==Status.Failed&&!retry)))return;
            Cancel();Key=key;Error=null;UsedBakedLayout=false;State=Status.Preparing;Progress=0;
            int token=++request;job=StartCoroutine(Drive(Build(theme,level),token));
        }
        IEnumerator Drive(IEnumerator routine,int token)
        {
            float began=Time.realtimeSinceStartup;
            var stack=new Stack<IEnumerator>();stack.Push(routine);
            while(stack.Count>0&&token==request)
            {
                if((game.Video&&game.Video.Active)||(game.Playing&&game.Paused)){yield return null;continue;}
                bool more=false;object value=null;Exception failure=null;
                try{more=stack.Peek().MoveNext();if(more)value=stack.Peek().Current;}
                catch(Exception e){failure=e;}
                if(failure!=null){Error=failure.Message;State=Status.Failed;Debug.LogException(failure);ReleaseScene();yield break;}
                if(!more){stack.Pop();continue;}
                if(value is IEnumerator nested)stack.Push(nested);else yield return value;
            }
            if(token==request){PrepareMs=(Time.realtimeSinceStartup-began)*1000;Progress=1;State=Status.Ready;job=null;Debug.Log($"[GoosePrepare] ready {Key} ms={PrepareMs:0}");}
        }
        public void Cancel()
        {
            request++;if(job!=null)StopCoroutine(job);job=null;ReleaseScene();
            Key=null;State=Status.Cancelled;Progress=0;
        }
        void ReleaseScene()
        {
            if(Root){Root.SetActive(false);Destroy(Root);}Root=null;Items.Clear();
            if(scene.IsValid()&&scene.isLoaded)SceneManager.UnloadSceneAsync(scene);scene=default;
            Pile=Scenery=null;Container=null;
        }
        public GameObject Adopt(Scene target)
        {
            if(State!=Status.Ready||!Root)throw new InvalidOperationException("Round has not finished preparing");
            var root=Root;SceneManager.MoveGameObjectToScene(root,target);
            if(scene.IsValid()&&scene.isLoaded)SceneManager.UnloadSceneAsync(scene);scene=default;
            Root=null;Key=null;State=Status.Idle;return root;
        }
        public static void Layer(Transform tr,int layer)
        {tr.gameObject.layer=layer==0&&tr.name.StartsWith("CircularBoundary_")?2:layer;foreach(Transform child in tr)Layer(child,layer);}
        IEnumerator Build(ThemeDefinition theme,LevelDefinition level)
        {
            var random=new DeterministicRandom(level.seed);var queue=level.MakeQueue(theme,random,game.AlgorithmSettings.weightedGeneration);
            var ids=queue.Distinct().ToArray();
            var retained=new HashSet<string>(ids.Concat(new[]{theme.container}));
            warmed.RemoveWhere(id=>!retained.Contains(id));
            foreach(var active in game.Items)if(active)retained.Add(active.Id);
            if(game.RetainPreparedModels(retained)&&!game.Playing)
            {yield return null;yield return Resources.UnloadUnusedAssets();}
            var bg=theme.background.StartsWith("mobile-ui/themes/")&&theme.background.EndsWith("-v1")
                ?Resources.LoadAsync<TextAsset>("Textures/"+theme.background):Resources.LoadAsync<Sprite>("Textures/"+theme.background);yield return bg;
            if(!bg.asset)throw new InvalidOperationException("Missing theme background "+theme.background);
            yield return game.PrepareVisuals(theme.container,ids);Progress=.25f;
            foreach(var id in new[]{"pick","match","shuffle","shake"})yield return game.PrepareAudio(id);
            scene=SceneManager.CreateScene("GoosePrepared_"+request,new CreateSceneParameters(LocalPhysicsMode.Physics3D));
            Root=new GameObject("PreparedRound");SceneManager.MoveGameObjectToScene(Root,scene);
            Pile=new GameObject("Items").transform;Pile.SetParent(Root.transform,false);
            Scenery=new GameObject("Container").transform;Scenery.SetParent(Root.transform,false);
            Container=Scenery.gameObject.AddComponent<GooseCircularContainer>();
            var model=game.LoadVisual(theme.container,Scenery);Container.Initialize(model,game.ContactMaterial);
            Layer(Root.transform,27);
            var physics=scene.GetPhysicsScene();
            float area=Mathf.PI*GooseCircularContainer.InitialRadius*GooseCircularContainer.InitialRadius;
            ItemScale=Mathf.Max(.70f,Mathf.Clamp(Mathf.Sqrt(level.layers*area/queue.Count)/1.02f,.3f,.8f));
            if(game.ReferenceTrial)ItemScale=.70f;
            if(baked==null){var file=Resources.Load<TextAsset>("Data/prepared-layouts");baked=file?JsonUtility.FromJson<GoosePreparedLayouts>(file.text):new GoosePreparedLayouts();}
            string signature=GoosePreparedLayouts.Key(game,theme,level);
            var layout=baked.version==1&&baked.layouts!=null?baked.layouts.FirstOrDefault(x=>x.key==signature):null;
            if(layout!=null&&ValidLayout(layout,queue,level,out var sourceIndices))
            {
                float budget=game.Playing&&!game.Preparing?.001f:.004f,frameStart=Time.realtimeSinceStartup;
                for(int poseIndex=0;poseIndex<layout.items.Length;poseIndex++)
                {
                    var pose=layout.items[poseIndex];
                    var item=game.CreateItem(pose.id);game.Items.Remove(item);item.transform.SetParent(null,true);
                    SceneManager.MoveGameObjectToScene(item.gameObject,scene);item.transform.SetParent(Pile,false);
                    item.transform.localScale=pose.scale;item.transform.SetPositionAndRotation(pose.position,pose.rotation);
                    item.Body.collisionDetectionMode=CollisionDetectionMode.ContinuousSpeculative;item.Body.isKinematic=true;item.Body.interpolation=RigidbodyInterpolation.None;
                    item.Body.position=pose.position;item.Body.rotation=pose.rotation;item.Body.solverIterations=12;item.Body.solverVelocityIterations=4;item.Body.sleepThreshold=.02f;
                    item.Body.maxDepenetrationVelocity=1;
                    item.GenerationLayer=level.LayerAt(sourceIndices[poseIndex]);item.Golden=level.golden&&sourceIndices[poseIndex]==0;
                    item.SetDepthVisible(false);Layer(item.transform,27);Items.Add(item);Progress=.25f+.65f*Items.Count/layout.items.Length;
                    if(Time.realtimeSinceStartup-frameStart>budget){yield return null;frameStart=Time.realtimeSinceStartup;}
                }
                Physics.SyncTransforms();UsedBakedLayout=true;
                yield return WarmMaterials(ids,scene);Progress=1;yield break;
            }
            int perLayer=Mathf.Max(4,Mathf.FloorToInt(area/Mathf.Pow(ItemScale*1.02f,2)*.85f));
            float frame=Time.realtimeSinceStartup;
            for(int i=0;i<queue.Count;i++)
            {
                var item=game.CreateItem(queue[i]);game.Items.Remove(item);
                item.transform.SetParent(null,true);SceneManager.MoveGameObjectToScene(item.gameObject,scene);item.transform.SetParent(Pile,false);
                item.transform.localScale=Vector3.one*game.ScaleForItem(item.Id,ItemScale,i);
                item.transform.rotation=GooseGame.NaturalRotation(item.Id,random.Next);
                item.GenerationLayer=level.LayerAt(i);item.Golden=level.golden&&i==0;
                item.Body.collisionDetectionMode=CollisionDetectionMode.ContinuousSpeculative;item.Body.isKinematic=true;item.Body.interpolation=RigidbodyInterpolation.None;
                item.SetDepthVisible(false);Layer(item.transform,27);
                Physics.SyncTransforms();
                float u=((i%perLayer)+.5f)/perLayer;
                float a=i*2.39996323f+(random.Next()-.5f)*.18f;
                var b=item.SelectionCollider.bounds;Vector3 offset=b.center-item.transform.position;
                float radial=Mathf.Sqrt(u)*Mathf.Max(.05f,GooseCircularContainer.InitialRadius-new Vector2(b.extents.x,b.extents.z).magnitude-.07f);
                Vector3 desired=new Vector3(Mathf.Cos(a)*radial,GooseCircularContainer.FloorY+.035f-b.min.y+item.transform.position.y,GooseCircularContainer.CenterZ+Mathf.Sin(a)*radial);
                desired=GooseGame.ClampModelFootprint(item,desired,GooseCircularContainer.InitialRadius);
                Physics.SyncTransforms();
                desired=game.PlaceSizedItem(item,desired,physics,GooseCircularContainer.InitialRadius,overlaps);
                item.transform.position=desired;item.Body.position=desired;item.Body.rotation=item.transform.rotation;
                Items.Add(item);Progress=.25f+.35f*(i+1)/queue.Count;
                Physics.SyncTransforms();
                if(Time.realtimeSinceStartup-frame>.002f){yield return null;frame=Time.realtimeSinceStartup;}
            }
            foreach(var item in Items)
            {
                item.Body.isKinematic=false;item.Body.collisionDetectionMode=CollisionDetectionMode.ContinuousDynamic;
                item.Body.solverIterations=24;item.Body.solverVelocityIterations=8;item.Body.sleepThreshold=.005f;item.Body.maxDepenetrationVelocity=3;
                item.Body.velocity=item.Body.angularVelocity=Vector3.zero;
            }
            Physics.SyncTransforms();
            // Virtual time advances here on the home screen, never in BeginRound.
            for(int step=0;step<300;step++)
            {
                physics.Simulate(1f/60);Progress=.6f+.30f*(step+1)/300;
                bool still=step>=48;
                foreach(var item in Items)if(item.Body.velocity.sqrMagnitude>.0225f||item.Body.angularVelocity.sqrMagnitude>.09f){still=false;break;}
                if(still)foreach(var item in Items)if(GooseColliderGeometry.MinY(item.SelectionCollider)<GooseCircularContainer.FloorY-.015f){still=false;break;}
                if(still)break;
                if(Time.realtimeSinceStartup-frame>.002f){yield return null;frame=Time.realtimeSinceStartup;}
            }
            foreach(var item in Items)
            {
                var position=item.Body.position;var rotation=item.Body.rotation;
                item.Body.velocity=item.Body.angularVelocity=Vector3.zero;item.Body.collisionDetectionMode=CollisionDetectionMode.ContinuousSpeculative;item.Body.isKinematic=true;
                item.Body.solverIterations=12;item.Body.solverVelocityIterations=4;item.Body.sleepThreshold=.02f;item.Body.maxDepenetrationVelocity=1;
                item.transform.SetPositionAndRotation(position,rotation);item.SetDepthVisible(false);
            }
            Physics.SyncTransforms();
            float support=float.PositiveInfinity;
            foreach(var item in Items)support=Mathf.Min(support,GooseColliderGeometry.MinY(item.SelectionCollider));
            if(support<GooseCircularContainer.FloorY-.10f)
            {
                var worst=Items.OrderBy(i=>GooseColliderGeometry.MinY(i.SelectionCollider)).First();
                throw new InvalidOperationException($"Prepared stock escaped floor: {support} id={worst.Id} body={worst.Body.position} bounds={worst.SelectionCollider.bounds}");
            }
            float maxY=Items.Max(i=>i.Body.position.y);
            if(maxY>GoosePhoneLayout.MaximumPileHeight)throw new InvalidOperationException("Prepared pile exceeds safe height: "+maxY);
            if(Items.Any(i=>new Vector2(i.Body.position.x,i.Body.position.z-GooseCircularContainer.CenterZ).magnitude>GooseCircularContainer.InitialRadius+.03f))
                throw new InvalidOperationException("Prepared stock escaped circular boundary");
            float floorCorrection=Mathf.Clamp(GooseCircularContainer.FloorY+.01f-support,0,.10f);
            if(floorCorrection>0)foreach(var item in Items){item.transform.position+=Vector3.up*floorCorrection;item.Body.position=item.transform.position;}
            Items.Sort((a,b)=>a.transform.position.y.CompareTo(b.transform.position.y));
            // Warm actual material passes into one shared tiny target; never show
            // staged meshes through the player's camera or allocate per-item RTs.
            yield return WarmMaterials(ids,scene);Progress=1;
        }
        bool ValidLayout(GoosePreparedLayouts.Layout layout,List<string> queue,LevelDefinition level,out int[] sourceIndices)
        {
            sourceIndices=null;if(layout.items==null||layout.items.Length!=queue.Count||Mathf.Abs(layout.itemScale-ItemScale)>.0001f)return false;
            var indices=new Dictionary<string,List<int>>();for(int i=0;i<queue.Count;i++){if(!indices.TryGetValue(queue[i],out var list))indices[queue[i]]=list=new List<int>();list.Add(i);}
            sourceIndices=new int[queue.Count];
            for(int i=0;i<layout.items.Length;i++)
            {
                var pose=layout.items[i];
                if(!indices.TryGetValue(pose.id,out var list)||list.Count==0||!float.IsFinite(pose.position.y)||pose.position.y<0||pose.position.y>GoosePhoneLayout.MaximumPileHeight||
                    !float.IsFinite(pose.position.x)||!float.IsFinite(pose.position.z)||new Vector2(pose.position.x,pose.position.z-GooseCircularContainer.CenterZ).magnitude>GooseCircularContainer.InitialRadius+.03f)return false;
                float norm=Quaternion.Dot(pose.rotation,pose.rotation);if(!float.IsFinite(norm)||Mathf.Abs(norm-1)>.001f)return false;
                int match=list.FindIndex(index=>(pose.scale-Vector3.one*game.ScaleForItem(pose.id,ItemScale,index)).sqrMagnitude<.00000001f);
                if(match<0)return false;sourceIndices[i]=list[match];list.RemoveAt(match);
            }
            return true;
        }
        readonly HashSet<string> warmed=new HashSet<string>();
        IEnumerator WarmMaterials(string[] ids,Scene target)
        {
            var cameraObject=new GameObject("ThemeWarmupCamera");SceneManager.MoveGameObjectToScene(cameraObject,target);
            var camera=cameraObject.AddComponent<Camera>();camera.enabled=false;camera.cullingMask=1<<27;camera.orthographic=true;camera.orthographicSize=1.2f;camera.nearClipPlane=.05f;camera.farClipPlane=10;
            var rt=RenderTexture.GetTemporary(32,32,16);camera.targetTexture=rt;
            float frame=Time.realtimeSinceStartup;
            foreach(var id in ids)
            {
                if(warmed.Contains(id))continue;
                var item=Items.First(x=>x.Id==id);camera.transform.SetPositionAndRotation(item.transform.position+Vector3.up*3,Quaternion.Euler(90,0,0));
                item.SetDepthVisible(true);camera.Render();item.SetDepthVisible(false);warmed.Add(id);
                if(Time.realtimeSinceStartup-frame>.002f){yield return null;frame=Time.realtimeSinceStartup;}
            }
            camera.targetTexture=null;RenderTexture.ReleaseTemporary(rt);Destroy(cameraObject);
        }
        void OnDestroy(){if(job!=null)StopCoroutine(job);ReleaseScene();}
    }
}
