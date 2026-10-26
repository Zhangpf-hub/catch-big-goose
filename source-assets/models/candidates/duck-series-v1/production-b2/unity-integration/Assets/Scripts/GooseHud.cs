using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed partial class GooseHud : MonoBehaviour
    {
        public RectTransform Frame;
        public Camera HudCamera { get; private set; }
        RectTransform overlayFrame;
        public GameObject Home, Play, Modal;
        public Image Background;
        public Text TimeText, ScoreText, ProgressText, StageText, ToastText, GiftText;
        public Button GiftButton;
        public readonly Image[] Slots = new Image[7];
        readonly Button[] storedButtons = new Button[3];
        readonly Image[] storedIcons = new Image[3];
        public readonly Text[] Counts = new Text[3];
        public readonly Image[] PropLabels = new Image[3];
        public Font Font, BoldFont;
        GooseGame game;
        Color cream = new Color(.99f, .94f, .81f), ink = new Color(.26f, .16f, .10f);
        float toastUntil;
        readonly System.Collections.Generic.Dictionary<string, Sprite> spriteCache = new System.Collections.Generic.Dictionary<string, Sprite>();
        readonly System.Collections.Generic.HashSet<string> encodedBackgrounds = new System.Collections.Generic.HashSet<string>();
        int previousHash = int.MinValue;
        GoosePhoneLayout phone;
        RectTransform playTop;
        public Transform StatusRoot => playTop;
        Image progressFill;
        static Sprite rounded;
        readonly Color blue = new Color(.02f, .65f, .94f), yellow = new Color(1, .76f, .14f);

        static Sprite Rounded()
        {
            if (rounded) return rounded;
            const int n = 128; const float radius = 30;
            var texture = new Texture2D(n, n, TextureFormat.RGBA32, true);
            texture.filterMode=FilterMode.Trilinear;
            texture.name = "UI rounded shape"; texture.wrapMode = TextureWrapMode.Clamp;
            var pixels = new Color[n * n];
            for (int y = 0; y < n; y++) for (int x = 0; x < n; x++)
            {
                float dx = Mathf.Max(radius - x - .5f, x + .5f - (n - radius));
                float dy = Mathf.Max(radius - y - .5f, y + .5f - (n - radius));
                float distance = new Vector2(Mathf.Max(0, dx), Mathf.Max(0, dy)).magnitude;
                pixels[y*n+x] = new Color(1, 1, 1, Mathf.Clamp01(radius - distance));
            }
            texture.SetPixels(pixels); texture.Apply(true);
            rounded = UnityEngine.Sprite.Create(texture, new Rect(0,0,n,n), new Vector2(.5f,.5f), 100, 0, SpriteMeshType.FullRect, new Vector4(32,32,32,32));
            return rounded;
        }
        GameObject Card(string name, Transform parent, Rect rect, Color color)
        {
            var go = Panel(name, parent, rect, color);
            var image = go.GetComponent<Image>();GooseUiSurface.Apply(image,rect.width<140?Rounded():Sprite("Textures/ui-candy-v2/ivory-panel")??Rounded());
            if(rect.width<140)image.pixelsPerUnitMultiplier=4;
            if(rect.width>180&&rect.height>75)image.color=Color.white;
            if(rect.width<140){var edge=go.AddComponent<Outline>();edge.effectColor=ink;edge.effectDistance=new Vector2(2,-2);}
            return go;
        }
        Image Shape(string name, Transform parent, Rect rect, Color tint)
        {
            var image = Panel(name,parent,rect,tint).GetComponent<Image>();
            image.sprite = Rounded(); image.type = Image.Type.Sliced; image.raycastTarget = false;
            return image;
        }
        Text StickerText(Transform parent, string value, Rect rect, int size, Color color)
        {
            var text = Label(parent,value,rect,size,color);
            text.font=BoldFont;
            if(color.r>.9f&&color.g>.9f&&color.b>.9f)
            {var shadow=text.gameObject.AddComponent<Shadow>();shadow.effectColor=new Color(.16f,.22f,.28f,.45f);shadow.effectDistance=new Vector2(0,-2);}
            return text;
        }

        public void Initialize(GooseGame owner)
        {
            game = owner;
            Font = Resources.Load<Font>("Fonts/Chinese");
            if (!Font) Font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            BoldFont=Resources.Load<Font>("Fonts/Chinese-Bold");if(!BoldFont)BoldFont=Font;
            var cameraObject = new GameObject("BackgroundCamera");
            var bgCamera = cameraObject.AddComponent<Camera>();
            bgCamera.depth = -10; bgCamera.clearFlags = CameraClearFlags.SolidColor;
            bgCamera.backgroundColor = new Color(.13f, .09f, .07f); bgCamera.cullingMask = 1 << 8;
            var bgCanvas = MakeCanvas("Background", bgCamera);
            bgCanvas.gameObject.layer = 8;
            Background = new GameObject("SceneBackground", typeof(RectTransform), typeof(Image)).GetComponent<Image>();
            Background.gameObject.layer = 8; Background.transform.SetParent(bgCanvas.transform, false);
            Stretch(Background.rectTransform);
            Background.raycastTarget = false;
            var fitter = Background.gameObject.AddComponent<AspectRatioFitter>();
            fitter.aspectMode = AspectRatioFitter.AspectMode.EnvelopeParent;

            HudCamera = new GameObject("HudCamera").AddComponent<Camera>();
            HudCamera.depth = 2; HudCamera.clearFlags = CameraClearFlags.Depth;
            HudCamera.cullingMask = 1 << 29; HudCamera.orthographic = true;
            HudCamera.orthographicSize = 10; HudCamera.transform.position = new Vector3(0,0,-100);
            var canvas = MakeCanvas("HudCanvas", HudCamera); canvas.gameObject.layer = 29;
            canvas.gameObject.AddComponent<GraphicRaycaster>();
            Frame = new GameObject("PhoneFrame", typeof(RectTransform)).GetComponent<RectTransform>();
            Frame.SetParent(canvas.transform, false); Frame.sizeDelta = new Vector2(720, 1280);
            Frame.gameObject.layer = 29;
            if (!FindObjectOfType<EventSystem>()) new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
            Home = Panel("Home", Frame, new Rect(0, 0, 720, 1280), Color.clear);
            Play = Panel("GameHUD", Frame, new Rect(0, 0, 720, 1280), Color.clear); Play.SetActive(false);
            cream = new Color(1, .97f, .88f); ink = new Color(.22f, .19f, .17f);
            BuildPlay();
            phone = gameObject.AddComponent<GoosePhoneLayout>(); phone.Frame = Frame;
            phone.Top = playTop; phone.WorldCamera = game.MainCamera; phone.Refresh(true);
            var overlay = MakeCanvas("DialogsCanvas", null); overlay.sortingOrder = 20;
            overlay.gameObject.AddComponent<GraphicRaycaster>();
            overlayFrame = new GameObject("DialogsFrame", typeof(RectTransform)).GetComponent<RectTransform>();
            overlayFrame.SetParent(overlay.transform, false); SyncOverlay();
            ToastText = Label(overlayFrame, "", new Rect(55, 440, 610, 70), 25, cream);
            ToastText.gameObject.AddComponent<Outline>().effectColor = new Color(0, 0, 0, .8f);
        }
        Canvas MakeCanvas(string name, Camera cam)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler));
            var canvas = go.GetComponent<Canvas>();
            canvas.pixelPerfect=true;
            canvas.renderMode = cam ? RenderMode.ScreenSpaceCamera : RenderMode.ScreenSpaceOverlay;
            if (cam) { canvas.worldCamera = cam; canvas.planeDistance = 10; }
            var scale = go.GetComponent<CanvasScaler>(); scale.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scale.referenceResolution = new Vector2(720, 1280); scale.screenMatchMode = CanvasScaler.ScreenMatchMode.Expand;
            return canvas;
        }
        public static void Stretch(RectTransform r)
        { r.anchorMin = Vector2.zero; r.anchorMax = Vector2.one; r.offsetMin = r.offsetMax = Vector2.zero; }
        public static RectTransform Place(GameObject go, Transform parent, Rect rect)
        {
            go.layer = parent.gameObject.layer;
            var r = go.GetComponent<RectTransform>(); r.SetParent(parent, false);
            r.anchorMin = r.anchorMax = Vector2.zero; r.sizeDelta = rect.size; r.anchoredPosition = rect.center;
            return r;
        }
        public GameObject Panel(string name, Transform parent, Rect rect, Color color, string texture = null)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(Image)); Place(go, parent, rect);
            var image = go.GetComponent<Image>(); image.color = color; image.raycastTarget = color.a > .01f;
            if (texture != null) { image.sprite = Sprite(texture); image.color = Color.white; }
            return go;
        }
        public Sprite Sprite(string name)
        {
            if(!spriteCache.TryGetValue(name,out var sprite))
            {
                bool sticker=name.StartsWith("Textures/home-stickers-v2/")||name.StartsWith("Textures/duck-stickers-v3/");
                if(sticker||(name.StartsWith("Textures/mobile-ui/themes/")&&name.EndsWith("-v1")))
                {
                    var jpeg=Resources.Load<TextAsset>(name);
                    if(!jpeg)throw new InvalidOperationException("Missing theme JPEG: "+name);
                    var texture=new Texture2D(2,2,sticker?TextureFormat.RGBA32:TextureFormat.RGB24,true){name=name,filterMode=FilterMode.Trilinear,wrapMode=TextureWrapMode.Clamp};
                    if(!texture.LoadImage(jpeg.bytes,true)){Destroy(texture);throw new InvalidOperationException("Invalid theme JPEG: "+name);}
                    sprite=UnityEngine.Sprite.Create(texture,new Rect(0,0,texture.width,texture.height),Vector2.one*.5f,100,0,SpriteMeshType.FullRect);
                    sprite.name=name.Substring(name.LastIndexOf('/')+1);encodedBackgrounds.Add(name);Resources.UnloadAsset(jpeg);
                }
                else sprite=Resources.Load<Sprite>(name);
                spriteCache.Add(name,sprite);
            }
            return sprite;
        }
        public Text Label(Transform parent, string value, Rect rect, int size, Color color)
        {
            // Rasterize glyphs at twice the design size, then display at half
            // scale. Legacy Text otherwise ignores PhoneFrame's local scale
            // when choosing atlas resolution, producing inconsistent small text.
            var holder=new GameObject("TextLayout",typeof(RectTransform));Place(holder,parent,rect);
            var go = new GameObject("Text", typeof(RectTransform), typeof(Text));
            Place(go,holder.transform,new Rect(-rect.width*.5f,-rect.height*.5f,rect.width*2,rect.height*2));
            var transform=go.GetComponent<RectTransform>();transform.anchorMin=transform.anchorMax=new Vector2(.5f,.5f);
            transform.anchoredPosition=Vector2.zero;transform.localScale=Vector3.one*.5f;
            var text = go.GetComponent<Text>(); text.font = Font; text.text = value; text.fontSize = size*2;
            text.color = color; text.alignment = TextAnchor.MiddleCenter; text.raycastTarget = false;
            text.horizontalOverflow = HorizontalWrapMode.Wrap; text.verticalOverflow = VerticalWrapMode.Truncate;
            text.resizeTextForBestFit=true;text.resizeTextMinSize=Mathf.Max(36,Mathf.RoundToInt(size*1.7f));text.resizeTextMaxSize=size*2;
            return text;
        }
        public Button Button(Transform parent, string value, Rect rect, Action action, Color color, string texture = null)
        {
            rect.height=Mathf.Max(88,rect.height);rect.width=Mathf.Max(88,rect.width);
            bool primary=color.b>.7f&&color.r<.3f;
            var go = Panel(value,parent,rect,Color.white,"Textures/ui-candy-v2/"+(primary?"blue-button":"yellow-button"));
            var face=go.GetComponent<Image>();GooseUiSurface.Apply(face,face.sprite);
            var b = go.AddComponent<Button>(); b.onClick.AddListener(() => action());
            b.targetGraphic = face;
            var colors = b.colors; colors.highlightedColor = new Color(1, .96f, .82f); colors.pressedColor = new Color(.78f, .71f, .59f); b.colors = colors;
            var caption = Label(go.transform, value, new Rect(0, 5, rect.width, rect.height - 8), 28, ink);
            caption.font=BoldFont;caption.color=primary?Color.white:ink;
            go.AddComponent<GooseCandyMotion>();
            return b;
        }
        public void SetBackground(string id, bool dim = false)
        {
            // Keep the active plate, not five full-resolution visited plates.
            var oldThemes=new System.Collections.Generic.List<string>();
            foreach(var key in spriteCache.Keys)if(key.StartsWith("Textures/mobile-ui/themes/")&&key!="Textures/"+id)oldThemes.Add(key);
            Background.sprite = Sprite("Textures/" + id);
            foreach(var key in oldThemes)
            {
                if(encodedBackgrounds.Remove(key)&&spriteCache.TryGetValue(key,out var old)&&old){Destroy(old.texture);Destroy(old);}
                spriteCache.Remove(key);
            }
            Background.color = dim ? new Color(.55f, .56f, .55f) : Color.white;
            if (Background.sprite) Background.GetComponent<AspectRatioFitter>().aspectRatio = Background.sprite.rect.width / Background.sprite.rect.height;
        }
        void OnDestroy()
        {
            foreach(var key in encodedBackgrounds)if(spriteCache.TryGetValue(key,out var sprite)&&sprite){Destroy(sprite.texture);Destroy(sprite);}
            encodedBackgrounds.Clear();
        }
        public void BuildHome()=>BuildStoryHome();
        void ShowHelp()
        {
            var body=OpenModal("抓鸭小技巧","点击相同物件，凑齐三个就消除。\n\n七格满前巧用移出、凑齐和打乱。\n\n先看清上层，再找藏着的鸭子！");
            Button(body,"知道啦",new Rect(70,40,420,88),CloseModal,yellow);
        }
        void ShowRecords()
        {
            var best=GooseSave.StoryBest(game.Theme.id,1);
            var body=OpenModal("我的抓鸭成绩",$"{game.Theme.name}\n最高得分  {best.score}\n最高进度  {best.progress:0}%\n获得星星  {best.stars}");
            Button(body,"继续抓鸭",new Rect(70,40,420,88),CloseModal,yellow);
        }
        public void ShowOnboarding()
        {
            // The short first round teaches play directly.
            GooseSave.Onboarded=true;BuildHome();
        }
        void BuildPlay()
        {
            playTop = new GameObject("SafeTop", typeof(RectTransform)).GetComponent<RectTransform>();
            Place(playTop.gameObject, Play.transform, new Rect(0,0,720,1280)); playTop.pivot = Vector2.zero; playTop.anchoredPosition = Vector2.zero;
            Card("Status", playTop, new Rect(126,1154,568,104), cream);
            TimeText = Label(playTop, "", new Rect(267,1184,210,76), 42, ink);
            TimeText.font=BoldFont;
            StageText = Label(playTop, "", new Rect(492,1202,180,44), 25, ink);
            ScoreText = Label(playTop, "", new Rect(140,1161,220,35), 21, ink);
            ProgressText = Label(playTop, "", new Rect(360,1161,320,35), 21, ink);
            Shape("ProgressTrack", playTop, new Rect(136,1127,548,14), new Color(.26f,.32f,.34f));
            progressFill = Panel("ProgressFill", playTop, new Rect(140,1130,540,8), yellow).GetComponent<Image>(); progressFill.raycastTarget = false;
            Button(playTop, "Ⅱ", new Rect(24,1170,88,88), game.Pause, yellow);
            Button(playTop,"摇一摇",new Rect(24,1074,96,88),()=>game.Shake.Request(new Vector3(1,0,.35f)),new Color(.66f,.87f,.81f));
            Card("ToolDeck", Play.transform, new Rect(12,12,696,156), new Color(.88f,.65f,.43f));
            Card("Tray", Play.transform, new Rect(12,180,696,112), new Color(.96f,.97f,.96f));
            for (int i = 0; i < 7; i++)
            {
                Card("Slot", Play.transform, new Rect(25 + i * 97, 192, 88, 88), new Color(.70f,.76f,.77f));
                var icon = Panel("Icon", Play.transform, new Rect(25 + i * 97, 192, 88, 88), Color.white).GetComponent<Image>();
                icon.preserveAspect = true; icon.raycastTarget = false; icon.enabled = false; Slots[i] = icon;
            }
            string[] props = { "移出", "凑齐", "打乱" };
            string[] propArt = { "remove", "magnet", "shuffle" };
            for (int i = 0; i < 3; i++)
            {
                int index = i;
                var button = Button(Play.transform, "", new Rect(63 + i * 218, 35, 158, 112), () => game.UseProp(index), yellow);
                button.name = props[i];
                // Fixed UI artwork stays independent of the runtime Chinese font atlas.
                PropLabels[i] = Panel("Label", button.transform, new Rect(0, 0, 158, 70), Color.white,
                    "Textures/control-labels/" + propArt[i]).GetComponent<Image>();
                PropLabels[i].raycastTarget = false;
                var symbol = new GameObject("ToolIcon", typeof(RectTransform), typeof(GooseToolIcon));
                Place(symbol, button.transform, new Rect(39,48,80,60));
                Destroy(symbol.GetComponent<GooseToolIcon>());
                var art=Panel("ToolIllustration",button.transform,new Rect(25,45,108,100),Color.white,"Textures/story-ui/"+new[]{"remove","match","shuffle"}[i]).GetComponent<Image>();art.preserveAspect=true;art.raycastTarget=false;
                Card("Count", Play.transform, new Rect(190+i*218,124,44,40), cream);
                Counts[i] = Label(Play.transform, "1", new Rect(190 + i * 218, 124, 44, 40), 23, ink);
            }
            GiftButton = Button(Play.transform, "", new Rect(175, 370, 370, 60), game.WatchGift, new Color(.98f, .86f, .50f));
            GiftText = GiftButton.GetComponentInChildren<Text>(); GiftButton.gameObject.SetActive(false);
            for (int i = 0; i < 3; i++)
            {
                int index = i;
                var button = Button(Play.transform, "", new Rect(225 + i * 92, 310, 84, 84), () => game.PickStored(index), cream);
                storedButtons[i] = button;
                storedIcons[i] = Panel("StoredIcon", button.transform, new Rect(4, 4, 76, 76), Color.white).GetComponent<Image>();
                storedIcons[i].preserveAspect = true; storedIcons[i].raycastTarget = false;
                button.gameObject.SetActive(false);
            }
        }
        public void ShowPlay()
        {
            previousHash = int.MinValue;
            Home.SetActive(false); Play.SetActive(true); CloseModal(); SetBackground(game.Theme.background);
        }
        public void Refresh()
        {
            if (!TimeText) return;
            if (game.Preparing) return;
            int sec = Mathf.CeilToInt(game.TimeLeft);
            int hash;
            unchecked
            {
                hash = (((sec*397+game.Score)*397+game.Removed)*397+game.Combo)*397+game.Total;
                hash = hash*397+game.Difficulty;
                foreach(var item in game.Tray.Entries) hash = hash*397+item.GetInstanceID();
                foreach(var item in game.Stored) hash = hash*397+item.GetInstanceID();
                foreach(int n in game.Props) hash = hash*397+n;
            }
            if(hash == previousHash) return; previousHash = hash;
            TimeText.text = game.Level != null && game.Level.seconds == 0 ? "不限时" : $"{sec / 60}:{sec % 60:00}";
            TimeText.color = game.Level != null && game.Level.seconds > 0 && sec <= 15 ? new Color(.9f, .2f, .13f) : ink;
            if (progressFill) progressFill.rectTransform.sizeDelta = new Vector2(540 * Mathf.Clamp01(game.Progress / 100), 8);
            StageText.text = game.DuckReviewActive ? game.Theme.name.Replace("鸭子评审 · ","评审·") : game.ReferenceTrial ? "玩具 " + game.Total : game.Theme.name;
            ScoreText.text = $"得分 {game.Score}" + (game.Combo > 1 ? $"  ×{Mathf.Min(5, game.Combo)}" : "");
            ProgressText.text = $"消除 {game.Removed}/{game.Total}  ·  {game.Progress:0}%";
            for (int i = 0; i < 7; i++)
            { Slots[i].enabled = i < game.Tray.Entries.Count && !game.Presentation.Contains(game.Tray.Entries[i]); if (Slots[i].enabled) Slots[i].sprite = Sprite("Icons/" + game.Tray.Entries[i].Id); }
            for (int i = 0; i < 3; i++) Counts[i].text = game.Props[i].ToString();
            for (int i = 0; i < 3; i++)
            {
                storedButtons[i].gameObject.SetActive(i < game.Stored.Count);
                if (i < game.Stored.Count) { storedIcons[i].sprite = Sprite("Icons/" + game.Stored[i].Id); storedIcons[i].enabled = !game.Presentation.Contains(game.Stored[i]); }
            }
        }
        public void ShowPreparing(int prepared, int total)
        {
            if(StageText) StageText.text = "准备场景 " + Mathf.RoundToInt(100f*prepared/Mathf.Max(1,total)) + "%";
        }
        public RectTransform OpenModal(string title, string message)
        {
            CloseModal();
            float h = phone ? phone.Height : 1280;
            SyncOverlay();
            Modal = Panel("Modal", overlayFrame, new Rect(0, 0, 720, h), new Color(.08f, .16f, .22f, .72f));
            var body = Card("Dialog", Modal.transform, new Rect(80, (h-620)*.5f, 560, 620), cream).GetComponent<RectTransform>();
            Shape("DialogTitlePlate",body,new Rect(22,510,516,82),yellow);
            StickerText(body,title,new Rect(25,505,510,90),43,ink);
            Label(body, message, new Rect(35, 215, 490, 290), 28, ink);
            return body;
        }
        public void CloseModal() { if (Modal) { Modal.SetActive(false); Destroy(Modal); } Modal = null; }
        public void Toast(string text) { ToastText.text = text; ToastText.transform.parent.SetAsLastSibling(); toastUntil = Time.unscaledTime + 3.5f; }
        float lastHeight;
        public Vector2 TrayScreenPoint(int index) => RectTransformUtility.WorldToScreenPoint(HudCamera, Slots[index].transform.position);
        public Vector2 StoredScreenPoint(int index) => RectTransformUtility.WorldToScreenPoint(HudCamera, storedButtons[index].transform.position);
        public float SlotScreenWidth
        {
            get
            {
                var r = Slots[0].rectTransform;
                return Vector2.Distance(RectTransformUtility.WorldToScreenPoint(HudCamera, r.TransformPoint(new Vector3(r.rect.xMin,0,0))),
                    RectTransformUtility.WorldToScreenPoint(HudCamera, r.TransformPoint(new Vector3(r.rect.xMax,0,0))));
            }
        }
        void SyncOverlay()
        {
            if (!overlayFrame) return;
            overlayFrame.anchorMin = Frame.anchorMin; overlayFrame.anchorMax = Frame.anchorMax;
            overlayFrame.pivot = Frame.pivot; overlayFrame.anchoredPosition = Frame.anchoredPosition;
            overlayFrame.sizeDelta = Frame.sizeDelta; overlayFrame.localScale = Frame.localScale;
        }
        void LateUpdate() { SyncOverlay(); }
        void Update()
        {
            if (ToastText && Time.unscaledTime > toastUntil) ToastText.text = "";
            if (phone && !Mathf.Approximately(lastHeight, phone.Height))
            {
                lastHeight = phone.Height;
                if (Home.activeSelf && !Modal) BuildHome();
                if (Modal)
                {
                    Stretch(Modal.GetComponent<RectTransform>());
                    var dialog = Modal.transform.Find("Dialog") as RectTransform;
                    if (dialog) dialog.anchoredPosition = new Vector2(360, phone.Height * .5f);
                }
            }
        }
        public void ShowGift(bool visible)
        { GiftButton.gameObject.SetActive(visible); GiftText.text = "鸭子送礼  ·  看短片领道具"; }
        static void ClearChildren(Transform parent)
        { foreach (Transform child in parent) { child.gameObject.SetActive(false); Destroy(child.gameObject); } }
    }
}

