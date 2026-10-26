using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace CatchGoose
{
    public sealed class GooseHud : MonoBehaviour
    {
        public RectTransform Frame;
        public GameObject Home, Play, Modal;
        public Image Background;
        public Text TimeText, ScoreText, ProgressText, StageText, ToastText, GiftText;
        public Button GiftButton;
        public readonly Image[] Slots = new Image[7];
        public readonly Text[] Counts = new Text[3];
        public readonly Image[] PropLabels = new Image[3];
        public Font Font;
        GooseGame game;
        Color cream = new Color(.99f, .94f, .81f), ink = new Color(.26f, .16f, .10f);
        float toastUntil;

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

            var canvas = MakeCanvas("HudCanvas", null);
            canvas.gameObject.AddComponent<GraphicRaycaster>();
            Frame = new GameObject("PhoneFrame", typeof(RectTransform)).GetComponent<RectTransform>();
            Frame.SetParent(canvas.transform, false); Frame.sizeDelta = new Vector2(720, 1280);
            if (!FindObjectOfType<EventSystem>()) new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
            Home = Panel("Home", Frame, new Rect(0, 0, 720, 1280), Color.clear);
            Play = Panel("GameHUD", Frame, new Rect(0, 0, 720, 1280), Color.clear); Play.SetActive(false);
            BuildPlay();
            ToastText = Label(Frame, "", new Rect(55, 250, 610, 70), 25, cream);
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
        public Sprite Sprite(string name) => Resources.Load<Sprite>(name);
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
            var go = Panel(value, parent, rect, color, texture);
            var b = go.AddComponent<Button>(); b.onClick.AddListener(() => action());
            var colors = b.colors; colors.highlightedColor = new Color(1, .96f, .82f); colors.pressedColor = new Color(.78f, .71f, .59f); b.colors = colors;
            Label(go.transform, value, new Rect(0, 0, rect.width, rect.height), 29, ink);
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
            SetBackground("challenge-map-bg");
            Panel("Map", Home.transform, new Rect(0, 230, 720, 940), Color.white, "Textures/challenge-ui/map-continuous-v2");
            Panel("Header", Home.transform, new Rect(0, 1120, 720, 160), Color.white, "Textures/challenge-ui/header-reference");
            for (int i = 0; i < game.Themes.Length; i++)
            {
                int index = i; var theme = game.Themes[i];
                float y = 1020 - i * 155, x = i % 2 == 0 ? 70 : 390;
                var icon = Button(Home.transform, "", new Rect(x, y - 30, 135, 135), () => game.SelectTheme(index), cream);
                icon.GetComponent<Image>().sprite = Sprite("Textures/challenge-ui/station-medallion-" + theme.id + (theme.id == "electronics" ? "" : "-v4"));
                icon.GetComponent<Image>().preserveAspect = true;
                var card = Button(Home.transform, theme.name, new Rect(x - 12, y - 80, 215, 66), () => game.SelectTheme(index), game.ThemeIndex == i ? new Color(1, .79f, .22f) : cream);
                if (game.ThemeIndex == i) Label(Home.transform, "已选择", new Rect(x, y + 90, 150, 38), 22, new Color(.16f, .4f, .11f));
            }
            Panel("ControlDeck", Home.transform, new Rect(0, 0, 720, 285), new Color(.33f, .21f, .13f), "Textures/challenge-ui/control-deck-bg");
            var level = LevelDefinition.At(game.Difficulty);
            Label(Home.transform, $"{game.Theme.name}  ·  {level.Total} 件  ·  {level.seconds / 60}:{level.seconds % 60:00}", new Rect(65, 235, 590, 40), 23, ink);
            string[] names = { "轻松", "标准", "大师" };
            for (int i = 0; i < 3; i++)
            {
                int difficulty = i;
                Button(Home.transform, names[i], new Rect(65 + i * 205, 160, 180, 64), () => game.SelectDifficulty(difficulty), i == game.Difficulty ? new Color(1, .76f, .16f) : cream);
            }
            Button(Home.transform, "出发挑战", new Rect(155, 55, 410, 85), game.StartFromHome, new Color(1, .76f, .15f), "Textures/challenge-ui/cta-button-clean");
            Label(Home.transform, $"今日剩余 {GooseSave.Daily}/3  ·  相同三件即可消除", new Rect(60, 5, 600, 45), 20, cream);
            Button(Home.transform, GooseSave.Sound ? "声 开" : "声 关", new Rect(600, 1190, 105, 55), game.ToggleSound, cream);
        }
        public void ShowOnboarding()
        {
            SetBackground("challenge-map-bg"); Home.SetActive(false); Play.SetActive(false);
            var body = OpenModal("抓住大鹅", "选一站，定难度，凑三个\n\n把相同物件放入七格暂存槽，凑齐三个立即消除。\n\n挑战五个主题，发现藏在堆底的金鹅。");
            Button(body, "开始探索", new Rect(70, 40, 420, 85), () => { GooseSave.Onboarded = true; BuildHome(); }, new Color(1, .77f, .16f));
        }
        void BuildPlay()
        {
            Panel("Status", Play.transform, new Rect(65, 1140, 590, 100), new Color(.15f, .12f, .10f, .9f));
            TimeText = Label(Play.transform, "", new Rect(255, 1175, 210, 65), 32, cream);
            StageText = Label(Play.transform, "", new Rect(465, 1190, 180, 40), 24, cream);
            ScoreText = Label(Play.transform, "", new Rect(65, 1145, 255, 38), 22, cream);
            ProgressText = Label(Play.transform, "", new Rect(340, 1145, 305, 38), 22, cream);
            Button(Play.transform, "Ⅱ", new Rect(20, 1180, 85, 70), game.Pause, cream);
            Panel("Tray", Play.transform, new Rect(12, 140, 696, 112), new Color(.18f, .17f, .14f, .95f));
            for (int i = 0; i < 7; i++)
            {
                Panel("Slot", Play.transform, new Rect(25 + i * 97, 152, 88, 88), new Color(.54f, .52f, .43f));
                var icon = Panel("Icon", Play.transform, new Rect(25 + i * 97, 152, 88, 88), Color.white).GetComponent<Image>();
                icon.preserveAspect = true; icon.raycastTarget = false; icon.enabled = false; Slots[i] = icon;
            }
            string[] props = { "移出", "凑齐", "打乱" };
            string[] propArt = { "remove", "magnet", "shuffle" };
            for (int i = 0; i < 3; i++)
            {
                int index = i;
                var button = Button(Play.transform, "", new Rect(55 + i * 218, 30, 175, 90), () => game.UseProp(index), new Color(.97f, .74f, .18f));
                button.name = props[i];
                // Fixed UI artwork stays independent of the runtime Chinese font atlas.
                PropLabels[i] = Panel("Label", button.transform, new Rect(0, 0, 175, 90), Color.white,
                    "Textures/control-labels/" + propArt[i]).GetComponent<Image>();
                PropLabels[i].raycastTarget = false;
                Counts[i] = Label(Play.transform, "1", new Rect(180 + i * 218, 96, 55, 36), 23, cream);
            }
            GiftButton = Button(Play.transform, "", new Rect(175, 265, 370, 60), game.WatchGift, new Color(.98f, .86f, .50f));
            GiftText = GiftButton.GetComponentInChildren<Text>(); GiftButton.gameObject.SetActive(false);
        }
        public void ShowPlay()
        {
            Home.SetActive(false); Play.SetActive(true); CloseModal(); SetBackground(game.Theme.background, game.Theme.circular);
        }
        public void Refresh()
        {
            if (!TimeText) return;
            int sec = Mathf.CeilToInt(game.TimeLeft);
            TimeText.text = $"{sec / 60}:{sec % 60:00}"; TimeText.color = sec <= 15 ? new Color(1, .37f, .26f) : cream;
            StageText.text = $"第 {game.Difficulty + 1} 关";
            ScoreText.text = $"得分 {game.Score}" + (game.Combo > 1 ? $"  ×{Mathf.Min(5, game.Combo)}" : "");
            ProgressText.text = $"消除 {game.Removed}/{game.Total}  ·  {game.Progress:0}%";
            for (int i = 0; i < 7; i++)
            { Slots[i].enabled = i < game.Tray.Entries.Count; if (Slots[i].enabled) Slots[i].sprite = Sprite("Icons/" + game.Tray.Entries[i].Id); }
            for (int i = 0; i < 3; i++) Counts[i].text = game.Props[i].ToString();
        }
        public RectTransform OpenModal(string title, string message)
        {
            CloseModal();
            Modal = Panel("Modal", Frame, new Rect(0, 0, 720, 1280), new Color(0, 0, 0, .58f));
            var body = Panel("Dialog", Modal.transform, new Rect(80, 330, 560, 620), cream).GetComponent<RectTransform>();
            Label(body, title, new Rect(25, 505, 510, 90), 43, ink);
            Label(body, message, new Rect(35, 215, 490, 290), 28, ink);
            return body;
        }
        public void CloseModal() { if (Modal) { Modal.SetActive(false); Destroy(Modal); } Modal = null; }
        public void Toast(string text) { ToastText.text = text; ToastText.transform.SetAsLastSibling(); toastUntil = Time.unscaledTime + 3.5f; }
        void Update() { if (ToastText && Time.unscaledTime > toastUntil) ToastText.text = ""; }
        public void ShowGift(bool visible)
        { GiftButton.gameObject.SetActive(visible); GiftText.text = "大鹅送礼  ·  看短片领道具"; }
        static void ClearChildren(Transform parent)
        { foreach (Transform child in parent) { child.gameObject.SetActive(false); Destroy(child.gameObject); } }
    }
}
