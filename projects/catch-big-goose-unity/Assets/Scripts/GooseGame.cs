using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed partial class GooseGame : MonoBehaviour
    {
        public static GooseGame Instance;
        public ThemeDefinition[] Themes { get; private set; }
        public int ThemeIndex { get; private set; }
        public int Difficulty { get; private set; }
        public bool ReferenceTrial { get; private set; }
        public int ReferenceCount { get; private set; } = 126;
        ThemeDefinition referenceTheme;
        ItemSizeCatalog itemSizes;
        public ThemeDefinition Theme => DuckReviewActive ? duckReviewTheme : ReferenceTrial ? referenceTheme : Themes[ThemeIndex];
        public bool ReferenceScene => DuckReviewActive||ReferenceTrial||Theme.items.Any(id=>id.StartsWith("ref_"));
        public LevelDefinition Level { get; private set; }
        public readonly TrayRules<GooseItem> Tray = new TrayRules<GooseItem>(x => x.Id);
        public readonly List<GooseItem> Items = new List<GooseItem>();
        public readonly List<GooseItem> Stored = new List<GooseItem>();
        public readonly int[] Props = { 1, 1, 1 };
        readonly int[] toolUses = new int[3];
        bool shufflePropSpent;
        public int Score { get; private set; }
        public int Removed { get; private set; }
        public int Total => Level == null ? 0 : Level.Total;
        public float Progress => Total == 0 ? 0 : Removed * 100f / Total;
        public float TimeLeft { get; private set; }
        public int Combo { get; private set; }
        public bool Playing { get; private set; }
        public bool Paused { get; private set; }
        bool busy, fullTrayPending;
        int pendingMatches;
        bool resolving => pendingMatches > 0;
        public int PendingMatches => pendingMatches;
        public bool Busy { get => busy || fullTrayPending; private set => busy = value; }
        public GooseRoundPreparation Preparation { get; private set; }
        public GooseCircularContainer Container { get; private set; }
        public GooseShakeController Shake { get; private set; }
        public GooseSurfaceShuffle SurfaceShuffle { get; private set; }
        public GooseShakeDiagnostics ShakeDiagnostics { get; private set; }
        public GooseDeviceMonitor DeviceMonitor { get; private set; }
        public float ItemScale => itemScale;
        public PhysicMaterial ContactMaterial => contactMaterial;
        public float FirstRevealMs { get; private set; }
        public float InteractiveMs { get; private set; }
        public bool LastOpeningCached {get;private set;}
        public float LastPrepareMs {get;private set;}
        public float PickMaxMs {get;private set;}
        GameObject roundRoot;
        bool consumePendingAttempt;
        readonly RaycastHit[] pickHits = new RaycastHit[512];
        readonly Collider[] pickNeighbours=new Collider[1024],nearestNeighbours=new Collider[5];
        readonly float[] neighbourDistances=new float[5];
        readonly Dictionary<string,AudioClip> audioCache = new Dictionary<string,AudioClip>();
        public bool SpawnComplete { get; private set; }
        public bool Preparing { get; private set; }
        public string LastResult { get; private set; }
        public Camera MainCamera { get; private set; }
        public GooseHud Hud { get; private set; }
        public GooseTrayPresentation Presentation { get; private set; }
        public GooseReferenceLighting ReferenceLighting {get;private set;}
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        public bool InstantPicksForQa;
#endif
        public GooseVideo Video { get; private set; }
        public PileAlgorithmSettings AlgorithmSettings { get; private set; }
        public LevelTuningCatalog LevelTuning { get; private set; }
        public string LastLevelTuning { get; private set; }
        public CoreRoundCatalog CoreRounds { get; private set; }
        public ThemeRoundCatalog ThemeRounds {get;private set;}
        public GooseHomeStage HomeStage {get;private set;}
        public GooseDuckAudio DuckAudio {get;private set;}
        public GooseSceneDressing SceneDressing {get;private set;}
        public LevelDefinition SelectedLevel()=>DuckReviewActive?DuckReviewLevel():ThemeRounds.Create(Theme,Difficulty);
        public GoosePileDepth Depth { get; private set; }
        Transform world, pile, scenery;
        PhysicMaterial contactMaterial;
        readonly GooseAssetCache assets = new GooseAssetCache();
        readonly Dictionary<string, Stack<GooseItem>> itemPool = new Dictionary<string, Stack<GooseItem>>();
        Transform poolRoot;
        int pooledCount;
        GooseRoundProfiler roundProfiler;
        readonly Collider[] dropOverlaps = new Collider[1024];
        public int PooledCount => pooledCount;
        AudioSource sound;
        VideoBgm bgm;
        DeterministicRandom random;
        float itemScale, lastMatch = -100, elapsed;
        int generation;
#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
        uint? experienceSeed;
#endif
        int[] nextBonus = new int[3];
        static readonly HashSet<string> roundItems = new HashSet<string> { "banzhi", "bracelet", "tongqian", "yuzhuo", "pumpkin", "mushroom", "lotus", "cupcake", "donut", "macaron", "cookie", "pudding" };
        static readonly Dictionary<string, float> scaleAdjust = new Dictionary<string, float>
        {
            {"banana",1.08f},{"grape",1.05f},{"lemon",1.04f},{"pear",1.05f},{"goose",1.06f},{"ruyi",1.08f},
            {"carrot",1.08f},{"corn",1.05f},{"eggplant",1.04f},{"frog",1.07f},{"koi",1.06f},{"duck",1.07f},
            {"cupcake",.80f},{"icecream",1.06f},{"cake_slice",1.05f},{"candy",1.08f},{"croissant",1.06f}
        };

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Bootstrap()
        { if (!FindObjectOfType<GooseGame>()) new GameObject("GooseGame").AddComponent<GooseGame>(); }

        void Awake()
        {
            if (Instance && Instance != this) { Destroy(gameObject); return; }
            Instance = this; Time.timeScale = 1;
#if !UNITY_WEBGL
            // WX export can change the shared player setting. Native QA and
            // desktop playback must keep updating when their window is hidden.
            Application.runInBackground=true;
#endif
            Application.targetFrameRate = 60; QualitySettings.vSyncCount = 0;
            Physics.gravity = new Vector3(0, GooseInteractionProfile.Current.gravity, 0); Time.fixedDeltaTime = 1f / 60;
            Physics.defaultSolverIterations = 12; Physics.defaultSolverVelocityIterations = 4;
            Physics.defaultContactOffset=.02f;Physics.sleepThreshold=.2f;
            GooseRuntimePerformance.Configure();
            Themes = JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text).themes;
            var sizeFile=Resources.Load<TextAsset>("Data/item-presentation");
            itemSizes=sizeFile?JsonUtility.FromJson<ItemSizeCatalog>(sizeFile.text):new ItemSizeCatalog();
            var referenceFile=Resources.Load<TextAsset>("Data/reference-lab");
            if(referenceFile)referenceTheme=JsonUtility.FromJson<ReferenceLabCatalog>(referenceFile.text).theme;
            AlgorithmSettings = new PileAlgorithmSettings();
            var algorithmProfile = Resources.Load<TextAsset>("Data/pile-algorithms");
            if (algorithmProfile) JsonUtility.FromJsonOverwrite(algorithmProfile.text, AlgorithmSettings);
            AlgorithmSettings.Validate();
            LevelTuning = new LevelTuningCatalog();
            var levelTuningProfile = Resources.Load<TextAsset>("Data/level-tuning");
            if (levelTuningProfile) JsonUtility.FromJsonOverwrite(levelTuningProfile.text, LevelTuning);
            CoreRounds = new CoreRoundCatalog();
            var coreProfile = Resources.Load<TextAsset>("Data/core-rounds");
            if (coreProfile) JsonUtility.FromJsonOverwrite(coreProfile.text, CoreRounds);
            ThemeRounds=JsonUtility.FromJson<ThemeRoundCatalog>(Resources.Load<TextAsset>("Data/theme-rounds").text);
            Depth = gameObject.AddComponent<GoosePileDepth>(); Depth.Initialize(this, AlgorithmSettings);
            if (GooseRuntimePerformance.Mobile) roundProfiler = gameObject.AddComponent<GooseRoundProfiler>();
            ThemeIndex = Math.Max(0, Array.FindIndex(Themes, t => t.id == GooseSave.Theme));
            Difficulty = 0;
            world = new GameObject("World").transform;
            pile = new GameObject("Items").transform; pile.SetParent(world);
            poolRoot = new GameObject("InactiveItemPool").transform; poolRoot.SetParent(world);
            scenery = new GameObject("Container").transform; scenery.SetParent(world);
            var cam = new GameObject("MainCamera"); cam.tag = "MainCamera";
            MainCamera = cam.AddComponent<Camera>(); MainCamera.orthographic = true; MainCamera.orthographicSize = 4.25f;
            cam.transform.position = new Vector3(0, 8.2f, .35f); cam.transform.rotation = Quaternion.Euler(GoosePhoneLayout.GameplayPitch, 0, 0);
            MainCamera.clearFlags = CameraClearFlags.Depth; MainCamera.cullingMask = ~((1 << 8) | (1 << 26) | (1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));
            MainCamera.nearClipPlane = .05f; MainCamera.farClipPlane = 100;
            cam.AddComponent<AudioListener>();
            var sun = new GameObject("WarmSun").AddComponent<Light>(); sun.type = LightType.Directional;
            sun.color = new Color(1, .985f, .945f); sun.intensity = 1.05f; sun.shadows = LightShadows.Soft;
            sun.transform.rotation = Quaternion.Euler(62, -24, 0); sun.shadowStrength = .45f;
            if (GooseRuntimePerformance.Mobile) sun.shadows = LightShadows.None;
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
            RenderSettings.ambientLight = new Color(.74f, .72f, .67f);
            ReferenceLighting=gameObject.AddComponent<GooseReferenceLighting>();ReferenceLighting.Initialize(this,sun);
            // Reference ObjMa asset values; original game may override these at runtime.
            var physicsProfile=GooseInteractionProfile.Current;
            contactMaterial = new PhysicMaterial("PileContact") { dynamicFriction = physicsProfile.dynamicFriction, staticFriction = physicsProfile.staticFriction, bounciness = physicsProfile.bounce, frictionCombine = PhysicMaterialCombine.Average };
            sound = gameObject.AddComponent<AudioSource>(); sound.playOnAwake = false;
            bgm = gameObject.AddComponent<VideoBgm>();
            DuckAudio=gameObject.AddComponent<GooseDuckAudio>();DuckAudio.Initialize(this);
            Hud = new GameObject("Interface").AddComponent<GooseHud>(); Hud.Initialize(this);
            Presentation = new GameObject("TrayPresentation").AddComponent<GooseTrayPresentation>(); Presentation.Initialize(this);
            SelectionHighlight = gameObject.AddComponent<GooseSelectionHighlight>(); SelectionHighlight.Initialize(this);
            DeviceMonitor=gameObject.AddComponent<GooseDeviceMonitor>();DeviceMonitor.Initialize(this);
            Video = gameObject.AddComponent<GooseVideo>(); Video.Initialize(this);
            InitializeRewards();
            HomeStage=gameObject.AddComponent<GooseHomeStage>();HomeStage.Initialize(this);
            SceneDressing=gameObject.AddComponent<GooseSceneDressing>();SceneDressing.Initialize(this);
            Preparation=gameObject.AddComponent<GooseRoundPreparation>();Preparation.Initialize(this);
            Shake=gameObject.AddComponent<GooseShakeController>();Shake.Initialize(this);
            SurfaceShuffle=gameObject.AddComponent<GooseSurfaceShuffle>();SurfaceShuffle.Initialize(this);
            SurfaceShuffle.Completed+=OnSurfaceShuffleCompleted;
            ShakeDiagnostics=gameObject.AddComponent<GooseShakeDiagnostics>();ShakeDiagnostics.Initialize(this);
            gameObject.AddComponent<GooseWeChatPlatform>().Initialize(this);
            if (GooseSave.Onboarded || GooseSave.IsQa) Hud.BuildHome(); else Hud.ShowOnboarding();
            Debug.Log($"[Goose] Unity startup: {Themes.Length} themes, {Application.unityVersion}");
        }
        void Start()
        {
#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
            if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseSessionQa")>=0)
            {GooseSave.IsQa=true;gameObject.AddComponent<GooseSessionAcceptance>();return;}
            if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseShakeQa")>=0)
            {GooseSave.IsQa=true;gameObject.AddComponent<GooseShakeAcceptance>();return;}
            if(Array.IndexOf(Environment.GetCommandLineArgs(),"-gooseR4Qa")>=0)
            {GooseSave.IsQa=true;gameObject.AddComponent<GooseR4Acceptance>();return;}
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseInteractionQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GooseInteractionAcceptance>(); return; }
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseUiQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GooseUiAcceptance>(); return; }
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-goosePerformanceQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GoosePerformanceAcceptance>(); return; }
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseExperienceQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GooseExperienceAcceptance>(); return; }
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseAlgorithmQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GooseAlgorithmAcceptance>(); return; }
            if (Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseQa") >= 0)
            { GooseSave.IsQa = true; gameObject.AddComponent<GooseAcceptance>(); }
#endif
        }
        void OnDestroy() { Rewards?.Finish(); if (Instance == this) { Time.timeScale = 1; Instance = null; } }
        public void SelectTheme(int index)
        { if (Playing) return; ThemeIndex = Mathf.Clamp(index, 0, Themes.Length - 1); GooseSave.Theme = Theme.id;Difficulty=0; Hud.BuildHome(); }
        public void SelectDifficulty(int index)
        { if (Playing) return;if(index>0&&!GooseSave.TutorialComplete(Theme.id)&&!GooseSave.IsQa){Hud.Toast("先完成第一关，解锁主题挑战");return;} Difficulty = Mathf.Clamp(index, 0, 1); GooseSave.SelectStoryStage(Theme.id,Difficulty); Hud.BuildHome(); }
        public void ToggleSound()
        { GooseSave.Sound = !GooseSave.Sound; bgm.SetState(GooseSave.Sound && !Paused); if (!Playing) Hud.BuildHome(); }
        public void PlayHomeMusic()=>bgm.SetState(GooseSave.Sound);
        public void StartFromHome()
        {
            if (!GooseSave.GmUnlimited && GooseSave.Daily <= 0)
            {
                var box = Hud.OpenModal("今日挑战已用完", "完整观看短片，可再获得一次挑战机会。");
                Hud.Button(box, "观看短片", new Rect(70, 120, 420, 75), () => Video.Watch(ok => { if (ok) { GooseSave.Daily++; StartThemeSequence(); } else Hud.BuildHome(); }), new Color(1, .78f, .2f));
                Hud.Button(box, "返回地图", new Rect(70, 30, 420, 70), Hud.BuildHome, new Color(.8f, .74f, .61f));
                return;
            }
            StartThemeSequence();
        }
        public void BeginRound(bool consumeAttempt = true)
        {
            Cleanup();
            HomeStage?.Hide();
            ReferenceLighting.Apply(ReferenceScene);
            consumePendingAttempt=consumeAttempt && Difficulty==1 && !ReferenceTrial && !DuckReviewActive && !GooseSave.GmUnlimited;
            Level = ReferenceTrial?CoreRounds.Create(2):SelectedLevel();
            if(ReferenceTrial)
            {
                Level.competitorCore=true;Level.golden=false;Level.frozen=0;Level.targetCount=0;Level.seconds=600;
                Level.pileLayers=new[]{new PileLayerDefinition{kinds=21,normalCount=ReferenceCount,sourceHeight=20}};
                referenceTheme.coreGroupWeights=new float[21];
                int groups=ReferenceCount/3;
                for(int i=0;i<21;i++)referenceTheme.coreGroupWeights[i]=groups/21+(i<groups%21?1:0);
            }
#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
            if (experienceSeed.HasValue) Level.seed = experienceSeed.Value;
#endif
            random = new DeterministicRandom(Level.seed);
            LastLevelTuning = LevelTuning.Apply(Level, Theme, Difficulty);
            Score = Removed = Combo = 0; TimeLeft = Level.seconds; lastMatch = -100; elapsed = 0;PickMaxMs=0;
            ResetRewards(); SpawnComplete = false; LastResult = "";
            for (int i = 0; i < 3; i++) { Props[i] = 1 + (Level.competitorCore ? 0 : nextBonus[i]); nextBonus[i] = 0; toolUses[i] = 0; }
            Preparing = true; Playing = true; Paused = Busy = false; Time.timeScale = 1;
            Hud.ShowPlay(); Hud.Refresh(); bgm.SetState(GooseSave.Sound);
            // R4 uses five authored background plates. Keep the optional source
            // counter preview off: an extra live container obscures the shrinking
            // playfield and adds a second world render on mobile.
            if(GooseInteractionProfile.Current.sceneDressing)SceneDressing.Show();
            if (roundProfiler) roundProfiler.Begin(this);
            StartCoroutine(Spawn(generation));
        }
#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
        public void BeginExperienceRound(uint seed)
        {
            // Only the development harness can vary seeds for sample coverage.
            experienceSeed = seed;
            try { BeginRound(false); } finally { experienceSeed = null; }
        }
#endif
        void Cleanup()
        {
            CancelPointer();
            Rewards?.Finish(); Video?.Close(); SaleTruck?.Hide();
            SurfaceShuffle?.CancelRound();
            generation++; StopAllCoroutines();TransitioningToChallenge=false; pendingMatches = 0; fullTrayPending=false; Presentation?.ResetRound(); Shake?.CancelRound();
            Playing = Paused = Busy = Preparing = false; Time.timeScale = 1;
            Depth?.ResetRound();
            SceneDressing?.Hide();
            Hud?.CloseModal();
            foreach (var item in Items.ToArray()) if (item) RecycleItem(item);
            Items.Clear(); Tray.Entries.Clear(); Stored.Clear();
            if(roundRoot){roundRoot.SetActive(false);Destroy(roundRoot);roundRoot=null;pile=world;scenery=null;Container=null;}
            if (scenery) foreach (Transform child in scenery) { child.gameObject.SetActive(false); Destroy(child.gameObject); }
        }
        public void GoHome()
        { Cleanup(); storySequenceActive=false;Difficulty=0;ReferenceTrial=false; RestoreDuckReviewSelection();ReferenceLighting.Apply(false);bgm.SetState(false); Hud.BuildHome(); }
        public void BeginReferenceTrial(int count)
        {
            if(referenceTheme==null){Hud.Toast("玩具测试资源尚未准备");return;}
            RestoreDuckReviewSelection();ReferenceTrial=true;ReferenceCount=count==300?300:126;BeginRound(false);
        }
        public void Forget(GooseItem item) { InvalidateSelection(item); SelectionHighlight?.Forget(item); Items.Remove(item); }
        public IEnumerable<GooseItem> Remaining => Items.Where(i => i && !i.Picked && i.gameObject.activeInHierarchy);
        public GameObject LoadVisual(string id, Transform parent)
        {
            return assets.Instantiate(id, parent);
        }
        public static Bounds BoundsOf(GameObject go)
        {
            var renderers = go.GetComponentsInChildren<Renderer>();
            if (renderers.Length == 0) return new Bounds(go.transform.position, Vector3.zero);
            var b = renderers[0].bounds; foreach (var r in renderers.Skip(1)) b.Encapsulate(r.bounds); return b;
        }
        public LevelDefinition PrepareLevel()
        {
            var level=SelectedLevel();LevelTuning.Apply(level,Theme,Difficulty);return level;
        }
        public IEnumerator PrepareVisual(string id,bool physics) => assets.Prepare(id,physics);
        public string PreparedGeometryKey(HashSet<string> ids=null)=>assets.GeometryKey(ids);
        public IEnumerator PrepareVisuals(string container,string[] ids)=>assets.PrepareMany(container,ids);
        public IEnumerator PrepareAudio(string id)
        {
            if(audioCache.ContainsKey(id))yield break;
            var request=Resources.LoadAsync<AudioClip>("Audio/"+id);yield return request;audioCache[id]=request.asset as AudioClip;
        }
        public bool RetainPreparedModels(HashSet<string> ids)
        {
            var remove=new List<string>();
            foreach(var pair in itemPool)if(!ids.Contains(pair.Key))
            {foreach(var item in pair.Value)if(item){item.gameObject.SetActive(false);Destroy(item.gameObject);pooledCount--;}remove.Add(pair.Key);}
            foreach(var id in remove)itemPool.Remove(id);
            return assets.Retain(ids)||remove.Count>0;
        }
        public float ScaleForItem(string id,float scale,int index)
        {return (scale+((index+1)%4)*.012f)*(scaleAdjust.TryGetValue(id,out var mult)?mult:1)*itemSizes.Get(id)*ModelSize;}
        IEnumerator Spawn(int token)
        {
            float began=Time.realtimeSinceStartup;FirstRevealMs=InteractiveMs=-1;
            Preparation.Request(Theme,Level,true);
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
            Container=Preparation.Container;itemScale=Preparation.ItemScale*ModelSize;LastPrepareMs=Preparation.PrepareMs;
            if(pile && pile!=world)Destroy(pile.gameObject);
            if(scenery)Destroy(scenery.gameObject);
            roundRoot=Preparation.Adopt(gameObject.scene);roundRoot.transform.SetParent(world,false);
            pile=preparedPile;scenery=preparedScenery;
            Preparation.Items.Clear();Items.AddRange(opening);
            GooseRoundPreparation.Layer(roundRoot.transform,0);
            ReferenceLighting.Container(scenery.gameObject);Container.Activate(this);
            if(consumePendingAttempt){if(!GooseSave.GmUnlimited)GooseSave.Daily--;consumePendingAttempt=false;}
            foreach(var item in opening)
            {
                item.DepthProtectedUntil=Time.time;item.DepthStillSince=Time.time;
                if(item.Golden)PaintGold(item);
            }
            LastOpeningCached=Preparation.UsedBakedLayout;Preparing=false;Hud.Refresh();
            // Classify the prepared static pile before any dynamic body or mesh
            // is revealed. The full inventory stays available as collision support.
            var authoredScales=new Vector3[opening.Count];
            for(int j=0;j<opening.Count;j++)
            {
                var item=opening[j];authoredScales[j]=item.Visual.localScale;item.Visual.localScale=Vector3.zero;
                item.DepthReady=true;item.DepthStillSince=Time.time-AlgorithmSettings.settledDuration;
                item.SetDepthHeld(true);item.SetDepthVisible(false);
            }
            Physics.SyncTransforms();
            while(!Depth.RefreshPreparedOpening())
            {if(token!=generation||!Playing)yield break;yield return null;}
            var visibleOpening=new List<GooseItem>();var visibleScales=new List<Vector3>();
            for(int j=0;j<opening.Count;j++)
            {
                if(opening[j].DepthVisible){visibleOpening.Add(opening[j]);visibleScales.Add(authoredScales[j]);}
                else opening[j].Visual.localScale=authoredScales[j];
            }
            opening=visibleOpening;
            if(opening.Count==0){Debug.LogError("[Goose] prepared pile has no visible surface");GoHome();yield break;}
            float y0=opening[0].transform.position.y,y1=opening[opening.Count-1].transform.position.y;
            float revealStart=Time.time;int shown=0,finished=0;
            var scales=new Vector3[opening.Count];var revealAt=new float[opening.Count];
            for(int j=0;j<opening.Count;j++){scales[j]=visibleScales[j];revealAt[j]=(opening[j].transform.position.y-y0)/Mathf.Max(.01f,y1-y0)*.65f;}
            while(finished<opening.Count)
            {
                if(token!=generation||!Playing)yield break;
                float now=Time.time-revealStart;
                while(shown<opening.Count&&revealAt[shown]<=now)
                {
                    if(FirstRevealMs<0)FirstRevealMs=(Time.realtimeSinceStartup-began)*1000;
                    opening[shown].SetDepthVisible(true);shown++;
                }
                for(int j=finished;j<shown;j++)
                {
                    float x=Mathf.Clamp01((now-revealAt[j])/.20f);
                    opening[j].Visual.localScale=scales[j]*(x<.6f?Mathf.Lerp(.16f,1.10f,x/.6f):Mathf.Lerp(1.10f,1,(x-.6f)/.4f));
                    if(x>=1){opening[j].Visual.localScale=scales[j];opening[j].DepthReady=true;finished=j+1;}
                }
                yield return null;
            }
            foreach(var item in opening)
            {
                item.DepthProtectedUntil=Time.time;item.DepthStillSince=Time.time-AlgorithmSettings.settledDuration;
                item.Body.interpolation=RigidbodyInterpolation.Interpolate;
            }
            SpawnComplete=true;Depth.SpawnFinished(true);Depth.RefreshNow();
            InteractiveMs=(Time.realtimeSinceStartup-began)*1000;
            Debug.Log($"[Goose] R4 opening {Theme.id} stock={Items.Count} first={FirstRevealMs:0}ms interactive={InteractiveMs:0}ms radius={Container.Radius}");
        }
        Vector3 ClearDropPosition(GooseItem item, Vector3 desired)
        {
            // Inserting overlapping rigidbodies can launch them over the container rim.
            // Keep the rotated collider footprint inside and find a free drop height.
            Physics.SyncTransforms();
            var bounds = item.GetComponent<Collider>().bounds;
            Vector3 offset = bounds.center - item.transform.position;
            Vector3 half = bounds.extents;
            if(Container)desired=Container.ClampFootprint(desired,offset,half);
            float xLimit = Mathf.Max(.05f, (Container?Container.Radius:Theme.halfX) - half.x - .08f);
            float zLimit = Mathf.Max(.05f, (Container?Container.Radius:Theme.halfZ) - half.z - .08f);
            desired.x = Mathf.Clamp(desired.x + offset.x, -xLimit, xLimit) - offset.x;
            desired.z = .88f + Mathf.Clamp(desired.z + offset.z - .88f, -zLimit, zLimit) - offset.z;
            if (Theme.circular)
            {
                float radius = Mathf.Max(.05f, (Container?Container.Radius:Theme.halfX) - new Vector2(half.x, half.z).magnitude - .08f);
                var point = Vector2.ClampMagnitude(new Vector2(desired.x + offset.x, desired.z + offset.z - .88f), radius);
                desired.x = point.x - offset.x; desired.z = .88f + point.y - offset.z;
            }
            for (int attempt = 0; attempt < 64; attempt++)
            {
                int count = Physics.OverlapBoxNonAlloc(desired + offset, half * .98f, dropOverlaps, Quaternion.identity, ~0, QueryTriggerInteraction.Ignore);
                bool blocked = false; float blockingTop = float.NegativeInfinity;
                for (int c = 0; c < count; c++) if (dropOverlaps[c].attachedRigidbody != item.Body)
                { blocked = true; blockingTop = Mathf.Max(blockingTop, dropOverlaps[c].bounds.max.y); }
                if (count == dropOverlaps.Length) throw new InvalidOperationException("Drop query buffer saturated");
                if (!blocked) return desired;
                desired.y = Mathf.Max(desired.y + .2f, blockingTop + half.y + .08f - offset.y);
            }
            throw new InvalidOperationException("No collision-free drop position for " + item.Id);
        }
        public GooseItem CreateItem(string id)
        {
            long createStarted = System.Diagnostics.Stopwatch.GetTimestamp();
            if (itemPool.TryGetValue(id, out var stack) && stack.Count > 0)
            {
                var reused = stack.Pop(); pooledCount--;
                reused.transform.SetParent(pile, false); reused.ResetForReuse();
                reused.gameObject.SetActive(true); Items.Add(reused);
                GoosePerformanceCounters.Created(createStarted); return reused;
            }
            var go = new GameObject(id); go.transform.SetParent(pile);
            var item = go.AddComponent<GooseItem>(); item.Id = id;
            item.Visual = LoadVisual(id, go.transform).transform;
            if (!GooseColliderProfile.TryBuild(go, id, item.Visual.gameObject, contactMaterial))
            {
              var mesh = assets.Hull(id);
              if (!mesh) throw new InvalidOperationException("Missing baked collision mesh: " + id);
              var collider = go.AddComponent<MeshCollider>(); collider.sharedMesh = mesh; collider.convex = true;
              collider.sharedMaterial = contactMaterial;
            }
            item.Body = go.AddComponent<Rigidbody>(); item.Body.mass = .95f;
            item.Body.maxDepenetrationVelocity=1;item.Body.sleepThreshold=.2f;
            item.Body.drag = .06f; item.Body.angularDrag = .3f;
            item.Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision;
            item.Body.interpolation = RigidbodyInterpolation.Interpolate;
            item.CacheParts();
            Items.Add(item); GoosePerformanceCounters.Created(createStarted); return item;
        }
        void RecycleItem(GooseItem item)
        {
            InvalidateSelection(item);
            Presentation?.Release(item);
            Items.Remove(item); item.gameObject.SetActive(false);
            if (item.Golden || pooledCount >= 300) { Destroy(item.gameObject); return; }
            item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
            item.Body.isKinematic = true; item.transform.SetParent(poolRoot, false);
            if (!itemPool.TryGetValue(item.Id, out var stack)) { stack = new Stack<GooseItem>(); itemPool.Add(item.Id, stack); }
            stack.Push(item); pooledCount++;
        }
        static IEnumerator PopVisual(GooseItem item)
        {
            Transform visual = item.Visual;
            Vector3 target = visual.localScale; float t = 0;
            while (t < .24f && visual)
            {
                t += Time.deltaTime;
                float x = Mathf.Clamp01(t / .24f);
                float s = x < .6f ? Mathf.Lerp(.16f, 1.10f, x / .6f) : Mathf.Lerp(1.10f, 1, (x - .6f) / .4f);
                visual.localScale = target * s; yield return null;
            }
            if (visual) visual.localScale = target;
            if (item) item.DepthReady = true;
        }
        Vector2 SeedPoint(int index)
        {
            float area = Theme.circular ? Mathf.PI * Theme.halfX * Theme.halfX : 4 * Theme.halfX * Theme.halfZ;
            int perLayer = Mathf.Max(4, Mathf.FloorToInt(area / Mathf.Pow(itemScale * 1.02f, 2) * .85f));
            int layer = index / perLayer, j = index % perLayer;
            int cols = Mathf.Max(1, Mathf.RoundToInt(Mathf.Sqrt(perLayer * Theme.halfX / Theme.halfZ))), rows = Mathf.CeilToInt(perLayer / (float)cols);
            int cells = cols * rows, stride = Mathf.Max(1, Mathf.RoundToInt(cells * .618f));
            while (Gcd(stride, cells) != 1) stride++;
            int cell = (j * stride + layer * 3) % cells;
            float jitterX = Hash(index * 2 + 1), jitterZ = Hash(index * 2 + 2);
            if (AlgorithmSettings.weightedGeneration)
            {
                jitterX = WeightedPosition.Centered(jitterX, Hash(index * 2 + 71), AlgorithmSettings.positionEdgeWeight);
                jitterZ = WeightedPosition.Centered(jitterZ, Hash(index * 2 + 72), AlgorithmSettings.positionEdgeWeight);
            }
            float u = (((cell % cols) + .15f + .7f * jitterX + (layer % 2 == 1 ? .5f : 0)) / cols) % 1;
            float v = ((cell / cols) + .15f + .7f * jitterZ) / rows;
            // Account for the whole rotated item, not just its pivot, at a wall.
            // The rotated collider is clamped by ClearDropPosition. A growing
            // per-layer inset squeezed late inventory into a narrow centre heap.
            float inset = Mathf.Min(itemScale * .35f, Mathf.Min(Theme.halfX,Theme.halfZ)*.18f);
            if (Theme.circular)
            { float r = Mathf.Sqrt(u) * Mathf.Max(.1f, Theme.halfX - inset), a = v * Mathf.PI * 2; return new Vector2(Mathf.Cos(a) * r, .88f + Mathf.Sin(a) * r); }
            return new Vector2((u * 2 - 1) * (Theme.halfX - inset), .88f + (v * 2 - 1) * (Theme.halfZ - inset));
        }
        static int Gcd(int a, int b) { while (b != 0) { int t = a % b; a = b; b = t; } return a; }
        static float Hash(int n)
        {
            unchecked { uint h = ((uint)n ^ 0x9e3779b9u) * 0x85ebca6bu; h = (h ^ (h >> 13)) * 0xc2b2ae35u; return (float)((h ^ (h >> 16)) / 4294967296.0); }
        }
        public static Quaternion NaturalRotation(string id, Func<float> rand)
        {
            float min = 0, max = 0;
            switch (id)
            {
                case "strawberry": min = 34; max = 52; break;
                case "pear": min = 46; max = 68; break;
                case "carrot": min = 62; max = 78; break;
                case "corn": min = 56; max = 74; break;
                case "eggplant": min = 48; max = 68; break;
                case "frog": case "duck": min = 28; max = 42; break;
                case "icecream": min = 46; max = 66; break;
            }
            if (max > 0) return Quaternion.Euler(Mathf.Lerp(min, max, rand()) * (rand() < .5f ? -1 : 1), rand() * 360, (rand() - .5f) * 24);
            float tilt = roundItems.Contains(id) ? 12 : 32;
            return Quaternion.Euler((rand() - .5f) * tilt * 2, rand() * 360, (rand() - .5f) * tilt * 2);
        }
        void PaintGold(GooseItem item)
        {
            foreach (var renderer in item.GetComponentsInChildren<Renderer>())
                foreach (var material in renderer.materials)
                { material.color = new Color(1, .78f, .22f); material.SetFloat("_Metallic", .35f); material.SetFloat("_Glossiness", .55f); }
            item.transform.localScale *= 1.18f;
        }
        void Update()
        {
            TickSelectionInput();
            if (!Playing || Paused || Preparing || !SpawnComplete || !AppVisible) return;
            elapsed += Time.deltaTime;
            if (Level.seconds > 0)
            {
                TimeLeft = Mathf.Max(0, TimeLeft - Time.deltaTime);
                if (TimeLeft <= 0)
                {
                    // Let already committed arrivals/matches finish before a
                    // timeout can pause their animation or obscure a victory.
                    if (!resolving && !fullTrayPending && !Presentation.Moving && !busy) OnTimeout();
                    Hud.Refresh();
                    return;
                }
            }
            if (Combo > 0 && Time.time - lastMatch > 4.5f) Combo = 0;
            TickRewards(Time.deltaTime);
            Hud.Refresh();
        }
        public void PickAtScreenPosition(Vector2 position)
        {
            var item = FindSelectableAtScreenPosition(position);
            if (item) Pick(item);
        }
        public bool Pick(GooseItem item, bool automated = false)
        {
            long start=System.Diagnostics.Stopwatch.GetTimestamp();bool result=PickCore(item,automated);
            PickMaxMs=Mathf.Max(PickMaxMs,(float)((System.Diagnostics.Stopwatch.GetTimestamp()-start)*1000d/System.Diagnostics.Stopwatch.Frequency));return result;
        }
        bool PickCore(GooseItem item,bool automated)
        {
            if (!Playing || Paused || Preparing || !SpawnComplete || !AppVisible || (SurfaceShuffle && SurfaceShuffle.Active) || (!automated && (Busy || (Level.seconds > 0 && TimeLeft <= 0))) || !item || item.Picked) return false;
            if (Tray.Entries.Count >= TrayRules<GooseItem>.Capacity) return false;
            if (!automated && !item.DepthVisible) return false;
            if (item.Frozen) { Hud.Toast("冰封物件需完成三消后解冻"); return false; }
            InvalidateSelection(item);
            var removedBounds = item.SelectionCollider.bounds;
            item.Picked = true; item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative; item.Body.isKinematic = true;
            foreach (var col in item.Colliders) col.enabled = false;
            var removedPosition = item.transform.position;
            int nearCount=Physics.OverlapSphereNonAlloc(removedPosition,itemScale*2.75f,pickNeighbours);
            for(int i=0;i<5;i++){nearestNeighbours[i]=null;neighbourDistances[i]=float.PositiveInfinity;}
            for(int i=0;i<nearCount;i++)
            {
                var col=pickNeighbours[i];float d=(col.transform.position-removedPosition).sqrMagnitude;
                int place=4;while(place>=0&&d<neighbourDistances[place])place--;
                if(place>=4)continue;place++;
                for(int j=4;j>place;j--){neighbourDistances[j]=neighbourDistances[j-1];nearestNeighbours[j]=nearestNeighbours[j-1];}
                neighbourDistances[place]=d;nearestNeighbours[place]=col;
            }
            foreach (var col in nearestNeighbours)
                if(col)
                if (col.attachedRigidbody && !col.attachedRigidbody.isKinematic)
                { col.attachedRigidbody.WakeUp(); col.attachedRigidbody.AddForce((col.transform.position - removedPosition).normalized * .12f, ForceMode.Impulse); }
            Depth.NotifyRemoval(removedPosition, Mathf.Max(.55f, item.transform.localScale.x * 1.8f), removedBounds);
            if (item.Golden)
            { TimeLeft += 20; Score += 300; Props[UnityEngine.Random.Range(0, 3)]++; PlaySound("quack"); Hud.Toast("挖到金鸭：+20 秒 +300 分 +1 道具"); Destroy(item.gameObject); Hud.Refresh(); return true; }
            // Reserve the logical position immediately; visuals arrive before any
            // match, full-tray failure, recycle or end dialog is committed.
            var order = new List<GooseItem>(Tray.Entries);
            int insertion = order.FindLastIndex(x => x.Id == item.Id) + 1;
            if (insertion == 0) insertion = order.Count;
            order.Insert(insertion, item);
            var matched = Tray.Add(item); PlaySound(GooseDuckAudio.IsDuckItem(item.Id) ? "quack" : "pick");
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (InstantPicksForQa) { item.gameObject.SetActive(false); ResolvePick(matched, removedPosition); Hud.Refresh(); return true; }
#endif
            Presentation.Pick(item, order);
            if (matched != null)
            {
                pendingMatches++;Presentation.ReserveMatch(matched);Presentation.Retarget(Tray.Entries);
                StartCoroutine(FinishPick(matched,removedPosition,generation));
            }
            else if(Tray.Entries.Count>=TrayRules<GooseItem>.Capacity)
            {fullTrayPending=true;StartCoroutine(FinishPick(null,removedPosition,generation));}
            Hud.Refresh(); return true;
        }
        IEnumerator FinishPick(List<GooseItem> matched, Vector3 removedPosition, int token)
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
        void ResolvePick(List<GooseItem> matched, Vector3 removedPosition)
        {
            if (matched != null)
            {
                Removed += 3; Container?.MatchCommitted(Removed/(float)Mathf.Max(1,Total)); Combo = Time.time - lastMatch <= 4.5f ? Combo + 1 : 1; lastMatch = Time.time;
                Score += 100 * Mathf.Min(Combo, 5);
                foreach (var m in matched) RecycleItem(m);
                GooseItem thaw=null;
                if(!Level.competitorCore)
                {float nearest=float.PositiveInfinity;foreach(var candidate in Items)if(candidate&&!candidate.Picked&&candidate.Frozen){float d=(candidate.transform.position-removedPosition).sqrMagnitude;if(d<nearest){nearest=d;thaw=candidate;}}}
                if (thaw) { thaw.SetFrozen(false); Hud.Toast("冰层化开了 1 件"); }
                PlaySound("match");
                if (Removed >= Total) EndRound(true, "全部消除！");
                else if (SpawnComplete) CheckDeadlock();
            }
            else if (Tray.Entries.Count >= TrayRules<GooseItem>.Capacity) RequestFailure(GooseFailureReason.TrayFull);
            else if (SpawnComplete) CheckDeadlock();
        }
        public void PlaySound(string id)
        { if (!GooseSave.Sound) return;if(id=="quack"){DuckAudio.Play();return;}if(id=="shake"){PlayShakeAudio();return;} if(!audioCache.TryGetValue(id,out var clip)){clip=Resources.Load<AudioClip>("Audio/"+id);audioCache[id]=clip;} if(clip)sound.PlayOneShot(clip,id=="shuffle"?.62f:1f); }
        public bool HasAvailableTriple()
        {
            var available = Remaining.Concat(Stored).Where(i => !i.Golden && !i.Frozen).GroupBy(i => i.Id).ToDictionary(g => g.Key, g => g.Count());
            int free = 7 - Tray.Entries.Count;
            foreach (var group in Tray.Entries.GroupBy(i => i.Id))
            { int need = 3 - group.Count(); if (need <= free && available.TryGetValue(group.Key, out var n) && n >= need) return true; }
            return free >= 3 && available.Any(k => k.Value >= 3);
        }
        public void CheckDeadlock()
        {
            // No recovered evidence for automatic thawing or an extra unsolvable
            // loss in classic play. Core profiles use tray/time/clear conditions.
            if (Level.competitorCore) return;
            if (!Playing || Busy || !SpawnComplete || HasAvailableTriple()) return;
            var frozen = Remaining.Where(i => i.Frozen).ToList();
            if (frozen.Count > 0) { foreach (var i in frozen) i.SetFrozen(false); Hud.Toast("冰层全部化开了"); return; }
            if (Props[0] > 0) Hud.Toast("没有可凑齐的组合，用「移出」腾格"); else EndRound(false, "无解");
        }
        public bool UseProp(int kind)
        {
            if (!Playing || Paused || Busy || resolving || Presentation.Moving || !SpawnComplete || (SurfaceShuffle && SurfaceShuffle.Active) || kind < 0 || kind > 2) return false;
            // Production rounds spend inventory; a video refill is usable even
            // when the initial copy of that tool has already been consumed.
            if (Level.competitorCore && !Level.strictCatalog && toolUses[kind] >= 1) { Hud.Toast("本局使用次数已达上限"); return false; }
            if (Props[kind] <= 0) { Hud.Toast("道具已用完"); return false; }
            bool used;
            if (kind == 0)
            {
                // A refill must not overflow the three visible storage slots.
                if (Level.competitorCore && Stored.Count > 0) { Hud.Toast("先取回暂存物品，再使用移出"); return false; }
                var back = Tray.TakeFront(3); used = back.Count > 0;
                if (Level.competitorCore) { Stored.AddRange(back); Presentation.Store(Stored); Presentation.Retarget(Tray.Entries); }
                else for (int i = 0; i < back.Count; i++) ReturnItem(back[i], i);
            }
            else if (kind == 1)
            {
                var remaining = Remaining.Concat(Stored).Where(i => !i.Frozen && !i.Golden).ToList();
                var groups = Tray.Entries.GroupBy(i => i.Id).OrderByDescending(g => g.Count()).Select(g => g.Key).Concat(remaining.Select(i => i.Id).Distinct());
                List<GooseItem> picks = null;
                foreach (var id in groups)
                {
                    int need = 3 - Tray.Entries.Count(i => i.Id == id);
                    var list = remaining.Where(i => i.Id == id).Take(need).ToList();
                    if (list.Count == need && need <= 7 - Tray.Entries.Count) { picks = list; break; }
                }
                used = picks != null;
                if (used) { Busy = true; StartCoroutine(Magnet(picks, generation)); }
            }
            else
            {
                used = SurfaceShuffle.Begin();
            }
            if (used) { Props[kind]--; toolUses[kind]++; if(kind==2)shufflePropSpent=true; PlaySound(kind == 2 ? "shuffle" : "prop"); Hud.Refresh(); }
            return used;
        }
        void OnSurfaceShuffleCompleted(bool succeeded)
        {
            if(!shufflePropSpent)return;
            shufflePropSpent=false;
            if(!succeeded){Props[2]++;toolUses[2]=Mathf.Max(0,toolUses[2]-1);Hud.Refresh();}
        }
        IEnumerator Magnet(List<GooseItem> list, int token)
        {
            foreach (var item in list)
            { if (token != generation || !Playing) yield break; while (resolving) yield return null; if (Stored.Contains(item)) PickStored(Stored.IndexOf(item), true); else Pick(item, true); yield return new WaitForSeconds(.18f); }
            while (resolving) yield return null;
            if (token == generation) { Busy = false; CheckDeadlock(); }
        }
        public bool PickStored(int index, bool automated = false)
        {
            if (!Playing || Paused || (!automated && Busy) || index < 0 || index >= Stored.Count || Tray.Entries.Count >= 7) return false;
            var item = Stored[index]; Stored.RemoveAt(index); item.Picked = false;
            // Storage is a UI selection; its former pile visibility is irrelevant.
            // Playing/pause/busy/capacity were checked above before bypassing cover.
            bool picked = Pick(item, true);
            if (!picked) { item.Picked = true; Stored.Insert(index, item); }
            else Presentation.Store(Stored);
            return picked;
        }
        void ReturnItem(GooseItem item, int index)
        {
            Presentation.Release(item); item.transform.SetParent(pile, true);
            item.Picked = false; item.gameObject.SetActive(true);
            item.ReleaseDepth(Time.time + AlgorithmSettings.disturbanceProtection, true);
            var p = SeedPoint(index); item.transform.position = new Vector3(p.x * .6f, 1.3f + index * .5f, .88f + (p.y - .88f) * .6f);
            item.transform.rotation = NaturalRotation(item.Id, () => UnityEngine.Random.value);
            // Preserve the item's original scale (including per-model compensation).
            foreach (var col in item.GetComponentsInChildren<Collider>()) col.enabled = true;
            item.transform.position = ClearDropPosition(item, item.transform.position);
            item.Body.isKinematic = false; item.Body.velocity = new Vector3(0, -1.2f, 0); item.Body.angularVelocity = Vector3.zero; item.Body.WakeUp();
        }
        public void Pause()
        {
            if (!Playing || Video.Active) return;
            if (Rewards != null && Rewards.AwaitingRevive) { ShowReviveDialog(); return; }
            SetPaused(true);
            var panel = Hud.OpenModal("暂停", "");
            Hud.Button(panel,"模型大小",new Rect(70,405,420,88),Hud.ShowModelSizeSettings,new Color(1,.79f,.2f));
            if(ReferenceScene)Hud.Button(panel,"关卡画面设置",new Rect(70,310,420,65),ShowReferenceLook,new Color(.6f,.8f,.9f));
            Hud.Button(panel,"性能数据",new Rect(70,220,420,65),ShowPerformanceData,new Color(.65f,.8f,.9f));
            Hud.Button(panel, "继续游戏", new Rect(70, 130, 420, 75), Resume, new Color(.55f, .79f, .28f));
            Hud.Button(panel, "重开本关", new Rect(70, 45, 200, 65), () => BeginRound(false), new Color(1, .79f, .2f));
            Hud.Button(panel, "返回地图", new Rect(290, 45, 200, 65), GoHome, new Color(.8f, .72f, .59f));
        }
        void ShowReferenceLook()
        {
            var panel=Hud.OpenModal("关卡画面","");
            Hud.Label(panel,"R3 · 同一物堆切换比较",new Rect(45,440,470,50),25,new Color(.3f,.2f,.1f));
            Hud.Button(panel,ReferenceLighting.SimpleComparison?"画面：基础色对照":"画面：材质迁移",new Rect(70,350,420,70),()=>{ReferenceLighting.Comparison(!ReferenceLighting.SimpleComparison);ShowReferenceLook();},new Color(1,.8f,.3f));
            Hud.Button(panel,ReferenceLighting.Settings.shadows?"接触阴影：开":"接触阴影：关",new Rect(70,265,420,70),()=>{ReferenceLighting.ToggleShadows();ShowReferenceLook();},new Color(.65f,.8f,.9f));
            Hud.Button(panel,ReferenceLighting.PixelRatio<2?"清晰度：标准":"清晰度：高清",new Rect(70,180,420,70),()=>{ReferenceLighting.ToggleResolution();ShowReferenceLook();},new Color(.65f,.8f,.9f));
            Hud.Button(panel,"返回暂停",new Rect(70,65,420,75),Pause,new Color(.65f,.8f,.3f));
        }
        void ShowPerformanceData()
        {
            var s=DeviceMonitor.Latest;
            string message=s==null?"开始采样后继续游玩，再暂停查看数据。":
                $"{s.fps:0.0} FPS · P95 {s.p95ms:0.0} ms\n可见 {s.visible} · 表层 {s.surfaceBodies}\n动态 {s.dynamicBodies} · 活动 {s.awakeBodies}\n慢帧 {s.slowFrames} · GC {s.gcCollections}\n深度 {s.depthMs:0.00} ms · 探针 {s.depthProbes}";
            var panel=Hud.OpenModal("性能数据",message);
            Hud.Label(panel,GooseRuntimePerformance.BuildId,new Rect(35,160,490,45),19,new Color(.3f,.2f,.1f));
            Hud.Button(panel,DeviceMonitor.Requested?"停止采样":"开始采样",new Rect(70,90,420,65),()=>{DeviceMonitor.Toggle();Resume();},new Color(.65f,.8f,.3f));
            Hud.Button(panel,"返回暂停",new Rect(70,15,420,60),Pause,new Color(.65f,.8f,.9f));
        }
        public void SetPaused(bool value) { if(value)CancelPointer(); Paused = value; Time.timeScale = value ? 0 : 1; bgm.SetState(GooseSave.Sound && Playing && !value); }
        public void Resume()
        { if (Rewards != null && Rewards.AwaitingRevive) { ShowReviveDialog(); return; } Hud.CloseModal(); SetPaused(false); }
        void OnTimeout() { RequestFailure(GooseFailureReason.Timeout); }
        public void EndRound(bool won, string reason)
        {
            if (!Playing) return;
            SurfaceShuffle?.CancelRound();
            CancelPointer();
            Rewards?.Finish(); SaleTruck?.Hide(); Video?.Close(); Hud.CloseModal();
            Playing = false; Paused = Busy = false; Time.timeScale = 1; bgm.SetState(false);
            LastResult = won ? "win" : reason;
            int stars = Progress >= 100 ? 3 : Progress >= 70 ? 2 : Progress >= 50 ? 1 : 0;
            if (won) { Score += Mathf.RoundToInt(TimeLeft) * 2; for (int i = 0; i < 3; i++) nextBonus[i] = stars > i ? 1 : 0; }
            if(!ReferenceTrial&&!DuckReviewActive){GooseSave.RecordStory(Theme.id,Difficulty,new BestRecord{stars=stars,progress=Progress,score=Score});if(won)GooseSave.CompleteStoryStage(Theme.id,Difficulty);}
            PlaySound(won ? "win" : "lose"); Hud.Refresh();
            if(won&&Difficulty==0&&!ReferenceTrial&&!DuckReviewActive&&storySequenceActive)
            {StartCoroutine(ContinueThemeSequence(generation));Debug.Log($"[Goose] Warmup complete: {Theme.id}; continuing automatically");return;}
            var panel = Hud.OpenModal(won ? "全部消除！" : reason, $"{new string('★', stars)}\n完成度 {Progress:0}%\n得分 {Score}\n{Theme.name}");
            Hud.Button(panel, won?"再玩一次":"重试本关", new Rect(70, 120, 420, 75), () => { if(won&&!ReferenceTrial&&!DuckReviewActive)StartFromHome();else BeginRound(false); }, new Color(1, .79f, .18f));
            Hud.Button(panel, "返回地图", new Rect(70, 30, 420, 70), GoHome, new Color(.8f, .72f, .59f));
            Debug.Log($"[Goose] Round end {LastResult}, {Removed}/{Total}, score={Score}");
        }
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        public void QaSetTime(float seconds) { TimeLeft = seconds; }
        public void QaGrant(int kind, int count) { Props[kind] += count; }
#endif
    }
}
