using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed class GooseHud : MonoBehaviour
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
        public Font Font;
        GooseGame game;
        Color cream = new Color(.99f, .94f, .81f), ink = new Color(.26f, .16f, .10f);
        float toastUntil;
        readonly System.Collections.Generic.Dictionary<string, Sprite> spriteCache = new System.Collections.Generic.Dictionary<string, Sprite>();
        int previousHash = int.MinValue;
        GoosePhoneLayout phone;
        RectTransform playTop;
        Image progressFill;
        static Sprite rounded;
        readonly Color blue = new Color(.02f, .65f, .94f), yellow = new Color(1, .76f, .14f);

        static Sprite Rounded()
        {
            if (rounded) return rounded;
            const int n = 64; const float radius = 15;
            var texture = new Texture2D(n, n, TextureFormat.RGBA32, false);
            texture.name = "UI rounded shape"; texture.wrapMode = TextureWrapMode.Clamp;
            var pixels = new Color[n * n];
            for (int y = 0; y < n; y++) for (int x = 0; x < n; x++)
            {
                float dx = Mathf.Max(radius - x - .5f, x + .5f - (n - radius));
                float dy = Mathf.Max(radius - y - .5f, y + .5f - (n - radius));
                float distance = new Vector2(Mathf.Max(0, dx), Mathf.Max(0, dy)).magnitude;
                pixels[y*n+x] = new Color(1, 1, 1, Mathf.Clamp01(radius - distance));
            }
            texture.SetPixels(pixels); texture.Apply();
            rounded = UnityEngine.Sprite.Create(texture, new Rect(0,0,n,n), new Vector2(.5f,.5f), 100, 0, SpriteMeshType.FullRect, new Vector4(16,16,16,16));
            return rounded;
        }
        GameObject Card(string name, Transform parent, Rect rect, Color color)
        {
            var go = Panel(name, parent, rect, color);
            var image = go.GetComponent<Image>(); image.sprite = Rounded(); image.type = Image.Type.Sliced;
            var outline = go.AddComponent<Outline>(); outline.effectColor = ink; outline.effectDistance = new Vector2(3,-3);
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
            var text = Label(parent,value,rect,size,color); text.fontStyle = FontStyle.Bold;
            var edge = text.gameObject.AddComponent<Outline>(); edge.effectColor = ink; edge.effectDistance = new Vector2(2.5f,-2.5f);
            return text;
        }

        public void Initialize(GooseGame owner)
        {
            game = owner;
            Font = Resources.Load<Font>("Fonts/Chinese");
            if (!Font) Font = Resources.GetBuiltinResource<Font>("Arial.ttf");
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
            cream = new Color(1, .97f, .83f); ink = new Color(.27f, .15f, .075f);
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
            if(!spriteCache.TryGetValue(name,out var sprite)){sprite=Resources.Load<Sprite>(name);spriteCache.Add(name,sprite);}
            return sprite;
        }
        public Text Label(Transform parent, string value, Rect rect, int size, Color color)
        {
            var go = new GameObject("Text", typeof(RectTransform), typeof(Text)); Place(go, parent, rect);
            var text = go.GetComponent<Text>(); text.font = Font; text.text = value; text.fontSize = size;
            text.color = color; text.alignment = TextAnchor.MiddleCenter; text.raycastTarget = false;
            text.horizontalOverflow = HorizontalWrapMode.Wrap; text.verticalOverflow = VerticalWrapMode.Truncate;
            return text;
        }
        public Button Button(Transform parent, string value, Rect rect, Action action, Color color, string texture = null)
        {
            if (parent.name == "Dialog") rect.height = Mathf.Max(88, rect.height);
            var go = Card(value, parent, rect, new Color(.55f,.28f,.10f));
            var shadow = go.AddComponent<Shadow>(); shadow.effectColor = new Color(.20f,.12f,.05f,.4f); shadow.effectDistance = new Vector2(0,-6);
            Shape("WhiteRim",go.transform,new Rect(0,5,rect.width,rect.height-5),Color.white);
            var face = Shape("ButtonFace",go.transform,new Rect(6,12,rect.width-12,rect.height-20),color);
            Shape("TopShine",go.transform,new Rect(17,rect.height-24,rect.width-34,6),new Color(1,1,1,.38f));
            var b = go.AddComponent<Button>(); b.onClick.AddListener(() => action());
            b.targetGraphic = face;
            var colors = b.colors; colors.highlightedColor = new Color(1, .96f, .82f); colors.pressedColor = new Color(.78f, .71f, .59f); b.colors = colors;
            var caption = Label(go.transform, value, new Rect(0, 5, rect.width, rect.height - 8), 28, ink);
            caption.fontStyle = FontStyle.Bold;
            return b;
        }
        public void SetBackground(string id, bool dim = false)
        {
            Background.sprite = Sprite("Textures/" + id);
            Background.color = dim ? new Color(.55f, .56f, .55f) : Color.white;
            if (Background.sprite) Background.GetComponent<AspectRatioFitter>().aspectRatio = Background.sprite.rect.width / Background.sprite.rect.height;
        }
        public void BuildHome()
        {
            ClearChildren(Home.transform); Home.SetActive(true); Play.SetActive(false); CloseModal();
            SetBackground("mobile-ui/market-courtyard");
            float h = phone ? phone.Height : 1280;
            // Scene-first composition: a quiet ground plate and a separate table
            // sprite allow the character display to scale without stretching.
            float tableShift=Mathf.Clamp01((h-1280)/280)*80;
            var hero = Panel("MarketTable", Home.transform, new Rect(-8,390-tableShift,736,h-625), Color.white, "Textures/mobile-ui/market-table").GetComponent<Image>();
            hero.preserveAspect = true; hero.raycastTarget = false;
            var banner = Card("MarketSign",Home.transform,new Rect(116,h-234,488,172),yellow);
            Shape("SignRim",banner.transform,new Rect(5,6,478,162),Color.white);
            Shape("SignFace",banner.transform,new Rect(12,13,464,148),new Color(1,.78f,.17f));
            StickerText(banner.transform,"抓住大鹅",new Rect(12,52,464,108),68,Color.white);
            Label(banner.transform,"三件消除  ·  五大场景",new Rect(24,17,440,42),24,ink).fontStyle = FontStyle.Bold;
            Button(Home.transform,GooseSave.Sound ? "声 开" : "声 关",new Rect(602,h-110,96,88),game.ToggleSound,cream);

            string[] art = {"apple","jadevase","pumpkin","icecream","radio"};
            Color[] colors = {new Color(1,.60f,.20f),new Color(.37f,.79f,.64f),new Color(.62f,.80f,.27f),new Color(.96f,.48f,.73f),new Color(.37f,.70f,1)};
            float sideTop = h-408;
            for (int i = 0; i < game.Themes.Length; i++)
            {
                int index = i; var theme = game.Themes[i];
                float x = i%2==0 ? 18 : 572;
                float y = sideTop - (i/2)*164 - (i%2)*24;
                var card = Button(Home.transform,"",new Rect(x,y,130,140),()=>game.SelectTheme(index),colors[i]);
                card.name = "Theme_"+theme.id;
                var icon = Panel("ThemeIcon",card.transform,new Rect(19,45,92,94),Color.white,"Icons/"+art[i]).GetComponent<Image>();
                icon.preserveAspect = true; icon.raycastTarget = false;
                StickerText(card.transform,theme.name,new Rect(0,10,130,45),25,Color.white);
                if (game.ThemeIndex==i)
                {
                    Shape("SelectedBadge",card.transform,new Rect(24,128,82,32),new Color(.94f,.25f,.07f));
                    StickerText(card.transform,"当前",new Rect(24,126,82,36),20,Color.white);
                }
            }
            var best = GooseSave.Best(game.Theme.id,game.Difficulty);
            var scoreCard = Card("PersonalBest",Home.transform,new Rect(562,sideTop-328,142,108),new Color(.30f,.25f,.18f));
            Label(scoreCard.transform,"本地最佳",new Rect(4,62,134,34),21,yellow).fontStyle = FontStyle.Bold;
            StickerText(scoreCard.transform,best.score.ToString(),new Rect(4,12,134,52),30,Color.white);

            // Bottom controls remain anchored to the safe area, as in the game HUD.
            Shape("BottomShade",Home.transform,new Rect(0,0,720,300),new Color(.22f,.15f,.07f,.15f));
            var themeSign = Card("ThemeBanner",Home.transform,new Rect(150,310,420,94),yellow);
            Shape("BannerShine",themeSign.transform,new Rect(8,71,404,14),new Color(1,1,1,.45f));
            StickerText(themeSign.transform,game.Theme.name+" · 主题挑战",new Rect(8,36,404,52),31,Color.white);
            var level = game.CoreRounds.Create(game.Difficulty);
            string duration = level.seconds > 0 ? $"{level.seconds / 60}:{level.seconds % 60:00}" : "不限时";
            Label(themeSign.transform,$"{level.Total} 件物品  ·  {duration}",new Rect(12,5,396,34),21,ink).fontStyle=FontStyle.Bold;
            StickerText(Home.transform,"选择难度",new Rect(230,267,260,40),24,Color.white);
            string[] names = { "轻松", "标准", "大师" };
            for (int i = 0; i < 3; i++)
            {
                int difficulty = i;
                Button(Home.transform,names[i],new Rect(80+i*192,176,176,88),()=>game.SelectDifficulty(difficulty),i==game.Difficulty ? yellow : cream);
            }
            var start = Button(Home.transform,"",new Rect(116,23,488,136),game.StartFromHome,blue);
            start.name="StartChallenge";
            StickerText(start.transform,"抓大鹅",new Rect(20,24,448,96),58,Color.white);
            var badge = Card("DailyBadge",Home.transform,new Rect(482,120,138,60),new Color(.35f,.79f,.11f));
            badge.GetComponent<Image>().raycastTarget=false;
            StickerText(badge.transform,$"今日 {GooseSave.Daily}/3 次",new Rect(3,7,132,46),23,Color.white);
            Button(Home.transform,"成绩",new Rect(16,43,88,100),ShowRecords,new Color(.99f,.63f,.22f));
            Button(Home.transform,"玩法",new Rect(616,43,88,100),ShowHelp,new Color(.99f,.63f,.22f));
            Button(Home.transform,"对照",new Rect(18,h-110,96,88),ShowReferenceLab,cream);
        }
        void ShowHelp()
        {
            var body=OpenModal("抓鹅小技巧","点击相同物件，凑齐三个就消除。\n\n七格满前巧用移出、凑齐和打乱。\n\n先看清上层，再找藏着的大鹅！");
            Button(body,"知道啦",new Rect(70,40,420,88),CloseModal,yellow);
        }
        void ShowReferenceLab()
        {
            var body=OpenModal("玩具性能对照","优化版本 R1 · 21 类竞品玩具模型。\n\n两档库存使用相同物件尺寸，可对比物堆数量对表现的影响。");
            Button(body,"玩具 · 126 件",new Rect(70,200,420,70),()=>game.BeginReferenceTrial(126),yellow);
            Button(body,"玩具 · 300 件",new Rect(70,110,420,70),()=>game.BeginReferenceTrial(300),blue);
            Button(body,"返回",new Rect(70,20,420,70),CloseModal,cream);
        }
        void ShowRecords()
        {
            var best=GooseSave.Best(game.Theme.id,game.Difficulty);
            var body=OpenModal("我的抓鹅成绩",$"{game.Theme.name}\n最高得分  {best.score}\n最高进度  {best.progress:0}%\n获得星星  {best.stars}");
            Button(body,"继续抓鹅",new Rect(70,40,420,88),CloseModal,yellow);
        }
        public void ShowOnboarding()
        {
            SetBackground("mobile-ui/market-courtyard"); Home.SetActive(false); Play.SetActive(false);
            var body = OpenModal("抓住大鹅", "选一站，定难度，凑三个\n\n把相同物件放入七格暂存槽，凑齐三个立即消除。\n\n清完物件即可过关，入门关有三只目标鹅。");
            Button(body, "开始探索", new Rect(70, 40, 420, 85), () => { GooseSave.Onboarded = true; BuildHome(); }, new Color(1, .77f, .16f));
        }
        void BuildPlay()
        {
            playTop = new GameObject("SafeTop", typeof(RectTransform)).GetComponent<RectTransform>();
            Place(playTop.gameObject, Play.transform, new Rect(0,0,720,1280)); playTop.pivot = Vector2.zero; playTop.anchoredPosition = Vector2.zero;
            Card("Status", playTop, new Rect(126,1154,568,104), cream);
            TimeText = Label(playTop, "", new Rect(267,1184,210,76), 42, ink); TimeText.fontStyle = FontStyle.Bold;
            StageText = Label(playTop, "", new Rect(492,1202,180,44), 25, ink);
            ScoreText = Label(playTop, "", new Rect(140,1161,220,35), 21, ink);
            ProgressText = Label(playTop, "", new Rect(360,1161,320,35), 21, ink);
            Card("ProgressTrack", playTop, new Rect(136,1127,548,14), new Color(.26f,.32f,.34f));
            progressFill = Panel("ProgressFill", playTop, new Rect(140,1130,540,8), yellow).GetComponent<Image>(); progressFill.raycastTarget = false;
            Button(playTop, "Ⅱ", new Rect(24,1170,88,88), game.Pause, yellow);
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
                symbol.GetComponent<GooseToolIcon>().Kind = i; symbol.GetComponent<GooseToolIcon>().raycastTarget = false;
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
            Home.SetActive(false); Play.SetActive(true); CloseModal(); SetBackground("mobile-ui/market-courtyard");
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
            StageText.text = game.ReferenceTrial ? "玩具 " + game.Total : $"第 {game.Difficulty + 1} 关";
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
            if(StageText) StageText.text = "准备物件 " + prepared + "/" + total;
        }
        public RectTransform OpenModal(string title, string message)
        {
            CloseModal();
            float h = phone ? phone.Height : 1280;
            SyncOverlay();
            Modal = Panel("Modal", overlayFrame, new Rect(0, 0, 720, h), new Color(.08f, .16f, .22f, .72f));
            var body = Card("Dialog", Modal.transform, new Rect(80, (h-620)*.5f, 560, 620), cream).GetComponent<RectTransform>();
            Shape("DialogTitlePlate",body,new Rect(22,510,516,82),yellow);
            StickerText(body,title,new Rect(25,505,510,90),43,Color.white);
            Label(body, message, new Rect(35, 215, 490, 290), 28, ink);
            return body;
        }
        public void CloseModal() { if (Modal) { Modal.SetActive(false); Destroy(Modal); } Modal = null; }
        public void Toast(string text) { ToastText.text = text; ToastText.transform.SetAsLastSibling(); toastUntil = Time.unscaledTime + 3.5f; }
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
        { GiftButton.gameObject.SetActive(visible); GiftText.text = "大鹅送礼  ·  看短片领道具"; }
        static void ClearChildren(Transform parent)
        { foreach (Transform child in parent) { child.gameObject.SetActive(false); Destroy(child.gameObject); } }
    }
}

