using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed class GooseSaleTruck : MonoBehaviour
    {
        GooseGame game;
        RectTransform clip, truck;
        RectTransform[] wheels;
        Button button;
        int offer;
        float age, exitAge, exitFrom;
        bool claimed;
        public bool Visible => clip && clip.gameObject.activeSelf;
        public float Age => age;
        public bool WheelsMoving { get; private set; }
        public RectTransform TruckRect => truck;
        public RectTransform LaneRect => clip;

        public void Initialize(GooseGame owner)
        {
            game = owner;
            var layer = new GameObject("SaleTruckLane", typeof(RectTransform), typeof(RectMask2D));
            clip = GooseHud.Place(layer, game.Hud.Play.transform, new Rect(0, 0, 720, 236));
            var body = game.Hud.Panel("DuckSaleTruck", clip, new Rect(0, 8, 420, 220), Color.clear);
            truck = body.GetComponent<RectTransform>();
            var hit = body.GetComponent<Image>(); hit.raycastTarget = true;
            button = body.AddComponent<Button>(); button.targetGraphic = hit; button.transition = Selectable.Transition.None;
            button.onClick.AddListener(game.WatchSale);
            var art = game.Hud.Panel("BodyWithB2Driver", truck, new Rect(0, 32, 420, 181), Color.white, "Textures/reward-truck/body").GetComponent<Image>();
            art.raycastTarget = false;
            wheels = new RectTransform[2];
            for (int i = 0; i < 2; i++)
            {
                var wheel = game.Hud.Panel("Wheel" + i, truck, new Rect((i == 0 ? 89 : 333) - 38, 4, 76, 76), Color.white, "Textures/reward-truck/wheel").GetComponent<Image>();
                wheel.raycastTarget = false; wheels[i] = wheel.rectTransform;
            }
            var title = game.Hud.Label(truck, "道具甩卖", new Rect(184, 101, 207, 76), 48, new Color(.24f, .16f, .09f));
            title.font = game.Hud.BoldFont; title.raycastTarget = false;
            title.resizeTextForBestFit = false;
            Hide();
        }

        public void Show(int id)
        {
            offer = id; age = exitAge = 0; claimed = false; button.interactable = true;
            clip.gameObject.SetActive(true); PositionLane(); SetPosition(930);
            foreach (var wheel in wheels) wheel.localRotation = Quaternion.identity;
        }

        public void Hide()
        { if (clip) clip.gameObject.SetActive(false); WheelsMoving = false; }

        public void Claim()
        { if (!Visible) return; claimed = true; exitAge = 0; exitFrom = truck.anchoredPosition.x; button.interactable = false; }

        void PositionLane()
        {
            float height = game.Hud.Frame.rect.height;
            float center = height - GoosePhoneLayout.GameplayTopInset + clip.rect.height * .5f;
            clip.anchoredPosition = new Vector2(360, center);
        }

        void SetPosition(float x) { truck.anchoredPosition = new Vector2(x, 118); }

        // Six seconds of travel split into three legs; two independent stops.
        public static float PositionAt(float time, float drive, float stop)
        {
            float leg = drive / 3;
            if (time < leg) return Mathf.Lerp(930, 480, time / leg);
            time -= leg;
            if (time < stop) return 480;
            time -= stop;
            if (time < leg) return Mathf.Lerp(480, 240, time / leg);
            time -= leg;
            if (time < stop) return 240;
            time -= stop;
            return Mathf.Lerp(240, -210, time / leg);
        }

        void Update()
        {
            if (!Visible) return;
            PositionLane();
            if (!game.Playing) { Hide(); return; }
            if (game.Paused || game.Video.Active || !game.AppVisible) { WheelsMoving = false; return; }
            float previous = truck.anchoredPosition.x, next;
            if (claimed)
            {
                exitAge += Time.deltaTime; next = Mathf.Lerp(exitFrom, -210, exitAge / 1.5f);
                if (exitAge >= 1.5f) { Hide(); return; }
            }
            else
            {
                age += Time.deltaTime;
                next = PositionAt(age, game.RewardPolicy.driveSeconds, game.RewardPolicy.stopSeconds);
                if (age >= game.RewardPolicy.driveSeconds + game.RewardPolicy.stopSeconds * 2)
                { game.ExpireSale(offer); Hide(); return; }
            }
            WheelsMoving = Mathf.Abs(previous - next) > .01f;
            if (WheelsMoving) foreach (var wheel in wheels) wheel.Rotate(0, 0, (previous - next) * 1.5f);
            SetPosition(next);
        }
        void OnDestroy() { if (clip) Destroy(clip.gameObject); }
    }
}
