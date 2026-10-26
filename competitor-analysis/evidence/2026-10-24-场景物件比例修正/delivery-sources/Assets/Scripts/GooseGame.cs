using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed class GooseGame : MonoBehaviour
    {
        public static GooseGame Instance;
        public ThemeDefinition[] Themes { get; private set; }
        public int ThemeIndex { get; private set; }
        public int Difficulty { get; private set; }
        public bool ReferenceTrial { get; private set; }
        public int ReferenceCount { get; private set; } = 126;
        ThemeDefinition referenceTheme;
        ItemSizeCatalog itemSizes;
        public ThemeDefinition Theme => ReferenceTrial ? referenceTheme : Themes[ThemeIndex];
        public LevelDefinition Level { get; private set; }
        public readonly TrayRules<GooseItem> Tray = new TrayRules<GooseItem>(x => x.Id);
        public readonly List<GooseItem> Items = new List<GooseItem>();
        public readonly List<GooseItem> Stored = new List<GooseItem>();
        public readonly int[] Props = { 1, 1, 1 };
        readonly int[] toolUses = new int[3];
        public int Score { get; private set; }
        public int Removed { get; private set; }
        public int Total => Level == null ? 0 : Level.Total;
        public float Progress => Total == 0 ? 0 : Removed * 100f / Total;
        public float TimeLeft { get; private set; }
        public int Combo { get; private set; }
        public bool Playing { get; private set; }
        public bool Paused { get; private set; }
        bool busy, resolving;
        public bool Busy { get => busy || resolving; private set => busy = value; }
        public bool SpawnComplete { get; private set; }
        public bool Preparing { get; private set; }
        public string LastResult { get; private set; }
        public Camera MainCamera { get; private set; }
        public GooseHud Hud { get; private set; }
        public GooseTrayPresentation Presentation { get; private set; }
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        public bool InstantPicksForQa;
#endif
        public GooseVideo Video { get; private set; }
        public PileAlgorithmSettings AlgorithmSettings { get; private set; }
        public LevelTuningCatalog LevelTuning { get; private set; }
        public string LastLevelTuning { get; private set; }
        public CoreRoundCatalog CoreRounds { get; private set; }
        public GoosePileDepth Depth { get; private set; }
        Transform world, pile, scenery;
        PhysicMaterial contactMaterial;
        readonly GooseAssetCache assets = new GooseAssetCache();
        readonly Dictionary<string, Stack<GooseItem>> itemPool = new Dictionary<string, Stack<GooseItem>>();
        Transform poolRoot;
        string poolTheme;
        int pooledCount;
        bool unloadBeforePrepare;
        GooseRoundProfiler roundProfiler;
        readonly Collider[] dropOverlaps = new Collider[1024];
        public int PooledCount => pooledCount;
        AudioSource sound;
        VideoBgm bgm;
        DeterministicRandom random;
        float itemScale, lastMatch = -100, elapsed, giftUntil;
        bool giftShown, giftAvailable, timeoutUsed, rescueUsed;
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
            Application.targetFrameRate = 60; QualitySettings.vSyncCount = 0;
            Physics.gravity = new Vector3(0, -12, 0); Time.fixedDeltaTime = 1f / 120;
            Physics.defaultSolverIterations = 12; Physics.defaultSolverVelocityIterations = 4;
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
            Depth = gameObject.AddComponent<GoosePileDepth>(); Depth.Initialize(this, AlgorithmSettings);
            if (GooseRuntimePerformance.Mobile) roundProfiler = gameObject.AddComponent<GooseRoundProfiler>();
            ThemeIndex = Math.Max(0, Array.FindIndex(Themes, t => t.id == GooseSave.Theme));
            Difficulty = GooseSave.Difficulty;
            world = new GameObject("World").transform;
            pile = new GameObject("Items").transform; pile.SetParent(world);
            poolRoot = new GameObject("InactiveItemPool").transform; poolRoot.SetParent(world);
            scenery = new GameObject("Container").transform; scenery.SetParent(world);
            var cam = new GameObject("MainCamera"); cam.tag = "MainCamera";
            MainCamera = cam.AddComponent<Camera>(); MainCamera.orthographic = true; MainCamera.orthographicSize = 4.25f;
            cam.transform.position = new Vector3(0, 8.2f, .35f); cam.transform.rotation = Quaternion.Euler(87.3f, 0, 0);
            MainCamera.clearFlags = CameraClearFlags.Depth; MainCamera.cullingMask = ~((1 << 8) | (1 << 29) | (1 << 30));
            MainCamera.nearClipPlane = .05f; MainCamera.farClipPlane = 100;
            cam.AddComponent<AudioListener>();
            var sun = new GameObject("WarmSun").AddComponent<Light>(); sun.type = LightType.Directional;
            sun.color = new Color(1, .985f, .945f); sun.intensity = 1.05f; sun.shadows = LightShadows.Soft;
            sun.transform.rotation = Quaternion.Euler(62, -24, 0); sun.shadowStrength = .45f;
            if (GooseRuntimePerformance.Mobile) sun.shadows = LightShadows.None;
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
            RenderSettings.ambientLight = new Color(.74f, .72f, .67f);
            // Reference ObjMa asset values; original game may override these at runtime.
            contactMaterial = new PhysicMaterial("PileContact") { dynamicFriction = .6f, staticFriction = .6f, bounciness = 0, frictionCombine = PhysicMaterialCombine.Average };
            sound = gameObject.AddComponent<AudioSource>(); sound.playOnAwake = false;
            bgm = gameObject.AddComponent<VideoBgm>();
            Hud = new GameObject("Interface").AddComponent<GooseHud>(); Hud.Initialize(this);
            Presentation = new GameObject("TrayPresentation").AddComponent<GooseTrayPresentation>(); Presentation.Initialize(this);
            gameObject.AddComponent<GooseDeviceMonitor>().Initialize(this);
            Video = gameObject.AddComponent<GooseVideo>(); Video.Initialize(this);
            gameObject.AddComponent<GooseWeChatPlatform>().Initialize(this);
            if (GooseSave.Onboarded || GooseSave.IsQa) Hud.BuildHome(); else Hud.ShowOnboarding();
            Debug.Log($"[Goose] Unity startup: {Themes.Length} themes, {Application.unityVersion}");
        }
        void Start()
        {
#if (UNITY_EDITOR || DEVELOPMENT_BUILD) && !UNITY_WEBGL
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
        void OnDestroy() { if (Instance == this) { Time.timeScale = 1; Instance = null; } }
        public void SelectTheme(int index)
        { if (Playing) return; ThemeIndex = Mathf.Clamp(index, 0, Themes.Length - 1); GooseSave.Theme = Theme.id; Hud.BuildHome(); }
        public void SelectDifficulty(int index)
        { if (Playing) return; Difficulty = Mathf.Clamp(index, 0, 2); GooseSave.Difficulty = Difficulty; Hud.BuildHome(); }
        public void ToggleSound()
        { GooseSave.Sound = !GooseSave.Sound; bgm.SetState(GooseSave.Sound && Playing && !Paused); if (!Playing) Hud.BuildHome(); }
        public void StartFromHome()
        {
            if (GooseSave.Daily <= 0)
            {
                var box = Hud.OpenModal("今日挑战已用完", "完整观看短片，可再获得一次挑战机会。");
                Hud.Button(box, "观看短片", new Rect(70, 120, 420, 75), () => Video.Watch(ok => { if (ok) { GooseSave.Daily++; BeginRound(); } else Hud.BuildHome(); }), new Color(1, .78f, .2f));
                Hud.Button(box, "返回地图", new Rect(70, 30, 420, 70), Hud.BuildHome, new Color(.8f, .74f, .61f));
                return;
            }
            BeginRound();
        }
        public void BeginRound(bool consumeAttempt = true)
        {
            Cleanup();
            if (consumeAttempt) GooseSave.Daily--;
            Level = CoreRounds.Create(Difficulty);
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
            Score = Removed = Combo = 0; TimeLeft = Level.seconds; lastMatch = -100; elapsed = 0;
            timeoutUsed = rescueUsed = giftShown = giftAvailable = false; SpawnComplete = false; LastResult = "";
            for (int i = 0; i < 3; i++) { Props[i] = 1 + (Level.competitorCore ? 0 : nextBonus[i]); nextBonus[i] = 0; toolUses[i] = 0; }
            if (poolTheme != Theme.id)
            {
                foreach (var stack in itemPool.Values) foreach (var item in stack) if (item) Destroy(item.gameObject);
                itemPool.Clear(); pooledCount = 0; poolTheme = Theme.id;
                assets.Clear(); unloadBeforePrepare = true;
            }
            Preparing = true; Playing = true; Paused = Busy = false; Time.timeScale = 1;
            Hud.ShowPlay(); Hud.ShowGift(false); Hud.Refresh(); bgm.SetState(GooseSave.Sound);
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
            generation++; StopAllCoroutines(); resolving = false; Presentation?.ResetRound();
            Playing = Paused = Busy = Preparing = false; Time.timeScale = 1;
            Depth?.ResetRound();
            Hud?.CloseModal();
            foreach (var item in Items.ToArray()) if (item) RecycleItem(item);
            Items.Clear(); Tray.Entries.Clear(); Stored.Clear();
            if (scenery) foreach (Transform child in scenery) { child.gameObject.SetActive(false); Destroy(child.gameObject); }
        }
        public void GoHome()
        { Video.Close(); Cleanup(); ReferenceTrial=false; bgm.SetState(false); Hud.BuildHome(); }
        public void BeginReferenceTrial(int count)
        {
            if(referenceTheme==null){Hud.Toast("玩具测试资源尚未准备");return;}
            ReferenceTrial=true;ReferenceCount=count==300?300:126;BeginRound(false);
        }
        public void Forget(GooseItem item) { Items.Remove(item); }
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
        void BuildContainer()
        {
            var visual = LoadVisual(Theme.container, scenery);
            // LoadVisual returns a model with its longest edge at one. Containers are then fitted by their opening footprint.
            var b = BoundsOf(visual); float factor = 4f / Mathf.Max(b.size.x, b.size.z);
            visual.transform.localScale *= factor; visual.transform.localPosition *= factor;
            b = BoundsOf(visual); visual.transform.position += new Vector3(0, -.08f - b.min.y, .88f);
            var contactMesh=Resources.Load<Mesh>("ContainerPhysics/"+Theme.container);
            if(contactMesh)
            {
                var contact=new GameObject("ContainerContact");contact.transform.SetParent(scenery,false);
                float contactScale=4f/Mathf.Max(contactMesh.bounds.size.x,contactMesh.bounds.size.z);
                contact.transform.localScale=Vector3.one*contactScale;
                contact.transform.position=b.center-contactMesh.bounds.center*contactScale;
                var c=contact.AddComponent<MeshCollider>();c.sharedMesh=contactMesh;c.sharedMaterial=contactMaterial;
            }
            else foreach (var filter in visual.GetComponentsInChildren<MeshFilter>())
            { var c = filter.gameObject.AddComponent<MeshCollider>(); c.sharedMesh = filter.sharedMesh; c.sharedMaterial = contactMaterial; }
            // Safety walls sit just outside the playable boundary. Curved containers retain their real concave mesh.
            if (!Theme.circular)
            {
                Wall(new Vector3(0, -.12f, .88f), new Vector3(Theme.halfX * 2, .15f, Theme.halfZ * 2));
                // Cover the full drop height, including collisions between spawning pieces.
                Wall(new Vector3(-Theme.halfX - .10f, 3, .88f), new Vector3(.2f, 6.4f, Theme.halfZ * 2 + .4f));
                Wall(new Vector3(Theme.halfX + .10f, 3, .88f), new Vector3(.2f, 6.4f, Theme.halfZ * 2 + .4f));
                Wall(new Vector3(0, 3, .88f - Theme.halfZ - .10f), new Vector3(Theme.halfX * 2 + .4f, 6.4f, .2f));
                Wall(new Vector3(0, 3, .88f + Theme.halfZ + .10f), new Vector3(Theme.halfX * 2 + .4f, 6.4f, .2f));
            }
            else
            {
                Wall(new Vector3(0, -.12f, .88f), new Vector3(4.4f, .15f, 4.4f));
                for (int i = 0; i < 40; i++)
                {
                    float angle = i * 360f / 40, radians = angle * Mathf.Deg2Rad;
                    var wall = Wall(new Vector3(Mathf.Cos(radians) * 1.95f, 3, .88f + Mathf.Sin(radians) * 1.95f), new Vector3(.42f, 6.4f, .2f));
                    wall.transform.rotation = Quaternion.Euler(0, 90 - angle, 0);
                }
            }
        }
        GameObject Wall(Vector3 position, Vector3 size)
        { var go = new GameObject("SafetyBoundary"); go.transform.SetParent(scenery); go.transform.position = position; var box = go.AddComponent<BoxCollider>(); box.size = size; box.sharedMaterial = contactMaterial; return go; }
        IEnumerator Spawn(int token)
        {
            var queue = Level.MakeQueue(Theme, random, AlgorithmSettings.weightedGeneration);
            var ids = queue.Distinct().ToArray(); Hud.ShowPreparing(0, ids.Length);
            if (unloadBeforePrepare)
            { unloadBeforePrepare = false; yield return null; yield return Resources.UnloadUnusedAssets(); }
            yield return assets.Prepare(Theme.container, false);
            if (token != generation || !Playing) yield break;
            BuildContainer();
            for (int prepared = 0; prepared < ids.Length; prepared++)
            {
                Hud.ShowPreparing(prepared, ids.Length);
                yield return assets.Prepare(ids[prepared], true);
                if (token != generation || !Playing) yield break;
            }
            float area = Theme.circular ? Mathf.PI * Theme.halfX * Theme.halfX : 4 * Theme.halfX * Theme.halfZ;
            itemScale = Mathf.Clamp(Mathf.Sqrt(Level.layers * area / queue.Count) / 1.02f, .3f, .8f);
            // Inventory depth must not shrink the silhouettes into tiny tokens.
            // Screenshot-calibrated own scale, not the competitor's world units.
            itemScale = Mathf.Max(.70f, itemScale);
            if(ReferenceTrial)itemScale=.70f;
            var frozen = new HashSet<int>();
            var last = new Dictionary<string, int>();
            for (int i = Level.golden ? 1 : 0; i < queue.Count; i++) last[queue[i]] = i;
            var candidates = last.Values.ToList(); random.Shuffle(candidates);
            foreach (int i in candidates.Take(Level.frozen)) frozen.Add(i);
            var opening = new List<GooseItem>(queue.Count);
            long frameStarted = System.Diagnostics.Stopwatch.GetTimestamp();
            for (int i = 0; i < queue.Count; i++)
            {
                if (token != generation || !Playing) yield break;
                var item = CreateItem(queue[i]);
                item.GenerationLayer = Level.LayerAt(i);
                item.DepthProtectedUntil = Time.time + AlgorithmSettings.spawnProtection;
                item.DepthStillSince = Time.time;
                item.Golden = Level.golden && i == 0;
                float scale = (itemScale + ((i + 1) % 4) * .012f) * (scaleAdjust.TryGetValue(item.Id, out var mult) ? mult : 1) * itemSizes.Get(item.Id);
                item.transform.localScale = Vector3.one * scale;
                var p = SeedPoint(i);
                item.transform.position = new Vector3(p.x + (random.Next() - .5f) * .12f, 0, p.y + (random.Next() - .5f) * .08f);
                item.transform.rotation = NaturalRotation(item.Id, random.Next);
                if (item.Golden) PaintGold(item);
                item.SetFrozen(frozen.Contains(i));
                // Place full-sized collision bodies from the floor upward before
                // revealing them. Hidden kinematic supports cannot explode apart.
                item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative;
                item.Body.isKinematic = true;
                item.Body.interpolation = RigidbodyInterpolation.None;
                Physics.SyncTransforms();
                var bounds = item.SelectionCollider.bounds;
                item.transform.position += Vector3.up * (.02f - bounds.min.y);
                item.transform.position = ClearDropPosition(item, item.transform.position);
                item.Body.position = item.transform.position; item.Body.rotation = item.transform.rotation;
                item.SetDepthVisible(false); opening.Add(item);
                if ((System.Diagnostics.Stopwatch.GetTimestamp() - frameStarted) * 1000.0 / System.Diagnostics.Stopwatch.Frequency > 2)
                { yield return null; frameStarted = System.Diagnostics.Stopwatch.GetTimestamp(); }
            }
            // Resolve support contacts while meshes are hidden, rather than reveal
            // a tall AABB placement stack and let it rain down after the grow-in.
            foreach (var item in opening)
            {
                item.Body.isKinematic = false; item.Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision;
                item.Body.velocity = item.Body.angularVelocity = Vector3.zero;
            }
            float settlingStart = Time.time;
            while (Time.time - settlingStart < 2.2f)
            {
                yield return new WaitForFixedUpdate();
                if (token != generation || !Playing) yield break;
                bool still = Time.time - settlingStart >= .5f;
                foreach (var item in opening) if (item.Body.velocity.sqrMagnitude > .0225f) { still = false; break; }
                if (still) break;
            }
            foreach (var item in opening)
            {
                var position = item.Body.position; var rotation = item.Body.rotation;
                item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative; item.Body.isKinematic = true;
                item.transform.SetPositionAndRotation(position, rotation);
            }
            opening.Sort((a,b) => a.transform.position.y.CompareTo(b.transform.position.y));
            Preparing = false; Hud.Refresh();
            float band = Mathf.Max(.12f, itemScale * .55f), currentBandTop = float.NegativeInfinity;
            int batch = 0;
            foreach (var item in opening)
            {
                if (token != generation || !Playing) yield break;
                if (item.transform.position.y > currentBandTop)
                {
                    if (batch > 0) yield return new WaitForSeconds(.22f);
                    currentBandTop = item.transform.position.y + band; batch = 0;
                }
                item.SetDepthVisible(true); StartCoroutine(PopVisual(item));
                if (++batch % Mathf.Max(1, Level.spawnBatch) == 0)
                    yield return new WaitForSeconds(Level.SpawnWait(queue.Count));
            }
            yield return new WaitForSeconds(.28f);
            foreach (var item in opening)
            {
                item.DepthProtectedUntil = Time.time;
                item.DepthStillSince = Time.time - AlgorithmSettings.settledDuration; item.Body.isKinematic = false;
                item.Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision;
                item.Body.interpolation = RigidbodyInterpolation.Interpolate;
                item.Body.velocity = item.Body.angularVelocity = Vector3.zero;
            }
            SpawnComplete = true;
            Depth.SpawnFinished(true); Depth.RefreshNow();
            Debug.Log($"[Goose] Spawn complete: {Theme.id}/{Difficulty + 1}, normal={Total}, actual={Items.Count}, seed={Level.seed}");
        }
        Vector3 ClearDropPosition(GooseItem item, Vector3 desired)
        {
            // Inserting overlapping rigidbodies can launch them over the container rim.
            // Keep the rotated collider footprint inside and find a free drop height.
            Physics.SyncTransforms();
            var bounds = item.GetComponent<Collider>().bounds;
            Vector3 offset = bounds.center - item.transform.position;
            Vector3 half = bounds.extents;
            float xLimit = Mathf.Max(.05f, Theme.halfX - half.x - .08f);
            float zLimit = Mathf.Max(.05f, Theme.halfZ - half.z - .08f);
            desired.x = Mathf.Clamp(desired.x + offset.x, -xLimit, xLimit) - offset.x;
            desired.z = .88f + Mathf.Clamp(desired.z + offset.z - .88f, -zLimit, zLimit) - offset.z;
            if (Theme.circular)
            {
                float radius = Mathf.Max(.05f, Theme.halfX - new Vector2(half.x, half.z).magnitude - .08f);
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
            item.Body.drag = .06f; item.Body.angularDrag = .3f;
            item.Body.collisionDetectionMode = GooseRuntimePerformance.DynamicCollision;
            item.Body.interpolation = RigidbodyInterpolation.Interpolate;
            item.CacheParts();
            Items.Add(item); GoosePerformanceCounters.Created(createStarted); return item;
        }
        void RecycleItem(GooseItem item)
        {
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
            while (t < .28f && visual)
            {
                t += Time.deltaTime;
                float x = Mathf.Clamp01(t / .28f);
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
        static Quaternion NaturalRotation(string id, Func<float> rand)
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
            if (!Playing || Paused || Preparing || !SpawnComplete) return;
            elapsed += Time.deltaTime;
            if (Level.seconds > 0)
            {
                TimeLeft = Mathf.Max(0, TimeLeft - Time.deltaTime);
                if (TimeLeft <= 0) { OnTimeout(); return; }
            }
            if (Combo > 0 && Time.time - lastMatch > 4.5f) Combo = 0;
            if (!Level.competitorCore && !giftShown && TimeLeft <= Level.seconds * .5f)
            { giftShown = giftAvailable = true; giftUntil = elapsed + 14; Hud.ShowGift(true); }
            if (giftAvailable && elapsed > giftUntil) { giftAvailable = false; Hud.ShowGift(false); }
            if (!GooseWeChatPlatform.HandlesPointer && Input.GetMouseButtonDown(0) && !Busy
                && !(EventSystem.current && EventSystem.current.IsPointerOverGameObject())) PickAtScreenPosition(Input.mousePosition);
            Hud.Refresh();
        }
        public void PickAtScreenPosition(Vector2 position)
        {
            if (!Playing || Paused || Busy || Preparing || !SpawnComplete) return;
            if (!MainCamera.pixelRect.Contains(position)) return;
            var ray = MainCamera.ScreenPointToRay(position);
            foreach (var hit in Physics.RaycastAll(ray, 100).OrderBy(h => h.distance))
            {
                var item = hit.collider.GetComponentInParent<GooseItem>();
                if (item && !item.Picked && item.DepthVisible) { Pick(item); break; }
            }
        }
        public bool Pick(GooseItem item, bool automated = false)
        {
            if (!Playing || Paused || resolving || (!automated && Busy) || !item || item.Picked) return false;
            if (Tray.Entries.Count >= TrayRules<GooseItem>.Capacity) return false;
            if (!automated && !item.DepthVisible) return false;
            if (item.Frozen) { Hud.Toast("冰封物件需完成三消后解冻"); return false; }
            item.Picked = true; item.Body.collisionDetectionMode = CollisionDetectionMode.ContinuousSpeculative; item.Body.isKinematic = true;
            foreach (var col in item.Colliders) col.enabled = false;
            var removedPosition = item.transform.position;
            foreach (var col in Physics.OverlapSphere(removedPosition, itemScale * 2.75f).OrderBy(c => Vector3.Distance(c.transform.position, removedPosition)).Take(5))
                if (col.attachedRigidbody && !col.attachedRigidbody.isKinematic)
                { col.attachedRigidbody.WakeUp(); col.attachedRigidbody.AddForce((col.transform.position - removedPosition).normalized * .12f, ForceMode.Impulse); }
            Depth.NotifyRemoval(removedPosition, Mathf.Max(.55f, item.transform.localScale.x * 1.8f));
            if (item.Golden)
            { TimeLeft += 20; Score += 300; Props[UnityEngine.Random.Range(0, 3)]++; PlaySound("honk"); Hud.Toast("挖到金鹅：+20 秒 +300 分 +1 道具"); Destroy(item.gameObject); Hud.Refresh(); return true; }
            // Reserve the logical position immediately; visuals arrive before any
            // match, full-tray failure, recycle or end dialog is committed.
            var order = new List<GooseItem>(Tray.Entries);
            int insertion = order.FindLastIndex(x => x.Id == item.Id) + 1;
            if (insertion == 0) insertion = order.Count;
            order.Insert(insertion, item);
            var matched = Tray.Add(item); PlaySound(item.Id == "goose" ? "honk" : "pick");
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (InstantPicksForQa) { item.gameObject.SetActive(false); ResolvePick(matched, removedPosition); Hud.Refresh(); return true; }
#endif
            Presentation.Pick(item, order);
            if (matched != null || Tray.Entries.Count >= TrayRules<GooseItem>.Capacity)
            { resolving = true; StartCoroutine(FinishPick(matched, removedPosition, generation)); }
            Hud.Refresh(); return true;
        }
        IEnumerator FinishPick(List<GooseItem> matched, Vector3 removedPosition, int token)
        {
            // At least one frame is required, including for a zero-distance pick.
            yield return null;
            while (Presentation.Moving) yield return null;
            if (token != generation || !Playing) yield break;
            if (matched != null)
            {
                yield return new WaitForSeconds(.05f);
                float time = 0;
                while (time < .25f)
                {
                    time += Time.deltaTime; Presentation.Combine(matched, Mathf.Clamp01(time / .25f)); yield return null;
                }
            }
            if (token != generation || !Playing) yield break;
            resolving = false;
            ResolvePick(matched, removedPosition);
            Presentation.Retarget(Tray.Entries);
            Hud.Refresh();
        }
        void ResolvePick(List<GooseItem> matched, Vector3 removedPosition)
        {
            if (matched != null)
            {
                Removed += 3; Combo = Time.time - lastMatch <= 4.5f ? Combo + 1 : 1; lastMatch = Time.time;
                Score += 100 * Mathf.Min(Combo, 5);
                foreach (var m in matched) RecycleItem(m);
                var thaw = Remaining.Where(x => x.Frozen).OrderBy(x => (x.transform.position - removedPosition).sqrMagnitude).FirstOrDefault();
                if (thaw) { thaw.SetFrozen(false); Hud.Toast("冰层化开了 1 件"); }
                PlaySound("match");
                if (Removed >= Total) EndRound(true, "全部消除！");
                else if (SpawnComplete) CheckDeadlock();
            }
            else if (Tray.Entries.Count >= TrayRules<GooseItem>.Capacity) EndRound(false, "槽位已满");
            else if (SpawnComplete) CheckDeadlock();
        }
        public void PlaySound(string id)
        { if (!GooseSave.Sound) return; var clip = Resources.Load<AudioClip>("Audio/" + id); if (clip) sound.PlayOneShot(clip); }
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
            if (!Playing || Paused || Busy || Presentation.Moving || !SpawnComplete || kind < 0 || kind > 2) return false;
            if (Level.competitorCore && toolUses[kind] >= 1) { Hud.Toast("本局使用次数已达上限"); return false; }
            if (Props[kind] <= 0) { Hud.Toast("道具已用完"); return false; }
            bool used;
            if (kind == 0)
            {
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
                var list = Remaining.ToList(); used = list.Count > 0;
                Depth.DisturbAll();
                for (int i = list.Count - 1; i > 0; i--) { int j = UnityEngine.Random.Range(0, i + 1); var temp = list[i]; list[i] = list[j]; list[j] = temp; }
                for (int i = 0; i < list.Count; i++)
                {
                    var p = SeedPoint(i);
                    list[i].transform.rotation = NaturalRotation(list[i].Id, () => UnityEngine.Random.value);
                    list[i].transform.position = ClearDropPosition(list[i], new Vector3(p.x, 1.55f + (i % 6) * .1f, p.y));
                    list[i].Body.velocity = new Vector3(UnityEngine.Random.Range(-.2f, .2f), -1.2f, UnityEngine.Random.Range(-.2f, .2f)); list[i].Body.WakeUp();
                }
            }
            if (used) { Props[kind]--; toolUses[kind]++; PlaySound(kind == 2 ? "shuffle" : "prop"); Hud.Refresh(); }
            return used;
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
            if (!Playing || Paused || resolving || (!automated && Busy) || index < 0 || index >= Stored.Count || Tray.Entries.Count >= 7) return false;
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
            SetPaused(true);
            var panel = Hud.OpenModal("暂停", "休息一下，再继续寻找相同物件。");
            Hud.Button(panel,"性能数据",new Rect(70,220,420,60),()=>GetComponent<GooseDeviceMonitor>().Toggle(),new Color(1,.85f,.45f));
            Hud.Button(panel, "继续游戏", new Rect(70, 130, 420, 75), Resume, new Color(.55f, .79f, .28f));
            Hud.Button(panel, "重开本关", new Rect(70, 45, 200, 65), () => BeginRound(false), new Color(1, .79f, .2f));
            Hud.Button(panel, "返回地图", new Rect(290, 45, 200, 65), GoHome, new Color(.8f, .72f, .59f));
        }
        public void SetPaused(bool value) { Paused = value; Time.timeScale = value ? 0 : 1; bgm.SetState(GooseSave.Sound && Playing && !value); }
        public void Resume() { Hud.CloseModal(); SetPaused(false); }
        public void WatchGift()
        {
            if (!Playing || !giftAvailable || Video.Active) return;
            Video.Watch(ok => { if (ok) { Props[UnityEngine.Random.Range(0, 3)]++; giftAvailable = false; Hud.ShowGift(false); Hud.Toast("完整观看奖励：+1 随机道具"); } Hud.Refresh(); });
        }
        void OnTimeout()
        {
            if (!timeoutUsed)
            {
                SetPaused(true);
                int resumeSeconds = Level.competitorCore ? 300 : 60;
                var box = Hud.OpenModal("时间到了", "完整观看一段短片，可保留当前对局并补时 " + resumeSeconds + " 秒。每局限一次。");
                Hud.Button(box, "观看短片复活", new Rect(70, 120, 420, 75), () => Video.Watch(ok => { if (ok) { timeoutUsed = true; TimeLeft = resumeSeconds; Resume(); } else OnTimeout(); }), new Color(1, .78f, .2f));
                Hud.Button(box, "结束本局", new Rect(70, 30, 420, 70), () => { Resume(); EndRound(false, "时间到"); }, new Color(.8f, .74f, .61f));
            }
            else EndRound(false, "时间到");
        }
        public void EndRound(bool won, string reason)
        {
            if (!Playing) return;
            Playing = false; Paused = Busy = false; Time.timeScale = 1; bgm.SetState(false);
            LastResult = won ? "win" : reason;
            int stars = Progress >= 100 ? 3 : Progress >= 70 ? 2 : Progress >= 50 ? 1 : 0;
            if (won) { Score += Mathf.RoundToInt(TimeLeft) * 2; for (int i = 0; i < 3; i++) nextBonus[i] = stars > i ? 1 : 0; }
            GooseSave.Record(Theme.id, Difficulty, new BestRecord { stars = stars, progress = Progress, score = Score });
            PlaySound(won ? "win" : "lose"); Hud.Refresh(); Hud.ShowGift(false);
            var panel = Hud.OpenModal(won ? "全部消除！" : reason, $"{new string('★', stars)}\n完成度 {Progress:0}%\n得分 {Score}\n{Theme.name} · 第 {Difficulty + 1} 关");
            bool canRescue = !won && !rescueUsed && reason != "时间到" && Tray.Entries.Count >= 3;
            if (canRescue) Hud.Button(panel, "救一下：退回 3 件", new Rect(70, 205, 420, 65), Rescue, new Color(.55f, .79f, .28f));
            Hud.Button(panel, won && Difficulty < 2 && !ReferenceTrial ? "下一关" : "再来一局", new Rect(70, 120, 420, 75), () => { if (won && Difficulty < 2 && !ReferenceTrial) { Difficulty++; GooseSave.Difficulty = Difficulty; } BeginRound(false); }, new Color(1, .79f, .18f));
            Hud.Button(panel, "返回地图", new Rect(70, 30, 420, 70), GoHome, new Color(.8f, .72f, .59f));
            Debug.Log($"[Goose] Round end {LastResult}, {Removed}/{Total}, score={Score}");
        }
        public void Rescue()
        {
            if (rescueUsed || Tray.Entries.Count < 3 || Playing) return;
            rescueUsed = true; var back = Tray.TakeFront(3); for (int i = 0; i < back.Count; i++) ReturnItem(back[i], i);
            Playing = true; Busy = Paused = false; LastResult = ""; Hud.CloseModal(); Hud.Refresh(); bgm.SetState(GooseSave.Sound);
        }
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        public void QaSetTime(float seconds) { TimeLeft = seconds; }
        public void QaGrant(int kind, int count) { Props[kind] += count; }
#endif
    }
}
