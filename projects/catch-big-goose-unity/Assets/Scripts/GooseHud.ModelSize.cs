using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed partial class GooseHud
    {
        public void ShowModelSizeSettings()
        {
            if (game.Playing && (!game.SpawnComplete || game.Busy || game.PendingMatches > 0 || game.Depth.AnimationInProgress || (game.Shake && game.Shake.Active) || (game.SurfaceShuffle && game.SurfaceShuffle.Active)))
            { Toast("等待物件动画结束后再调整"); return; }
            if (game.Playing) game.SetPaused(true);
            var panel = OpenModal("模型大小", "");
            // A bottom sheet keeps the live pile visible while the game is paused.
            panel.anchoredPosition = new Vector2(360, 310);
            Modal.GetComponent<Image>().color = new Color(.08f, .16f, .22f, .12f);
            Label(panel, game.Playing ? "拖动实时预览 · 确认后继续本局" : "所有主题通用 · 下次进局生效", new Rect(25, 440, 510, 48), 24, ink);
            var value = Label(panel, "", new Rect(85, 367, 390, 65), 34, ink); value.name = "ModelSizeValue";
            var root = Panel("ModelSizeSlider", panel, new Rect(65, 278, 430, 80), Color.clear);
            var hit = root.GetComponent<Image>(); hit.raycastTarget = true;
            var slider = root.AddComponent<Slider>(); slider.minValue = GooseGame.MinimumModelSize * 100; slider.maxValue = GooseGame.MaximumModelSize * 100; slider.wholeNumbers = true;
            Panel("Track", root.transform, new Rect(0, 32, 430, 16), new Color(.35f, .27f, .17f));
            var fillArea = new GameObject("FillArea", typeof(RectTransform)); Place(fillArea, root.transform, new Rect(22, 32, 386, 16));
            var fill = Panel("Progress", fillArea.transform, new Rect(0, 0, 386, 16), yellow).GetComponent<RectTransform>();
            Stretch(fill); slider.fillRect = fill;
            var area = new GameObject("HandleArea", typeof(RectTransform)); Place(area, root.transform, new Rect(22, 12, 386, 56));
            var handle = Panel("Handle", area.transform, new Rect(-24, 0, 48, 0), yellow).GetComponent<RectTransform>();
            handle.anchoredPosition = Vector2.zero;
            slider.handleRect = handle; slider.targetGraphic = handle.GetComponent<Image>(); slider.direction = Slider.Direction.LeftToRight;
            System.Action refresh = () => { slider.SetValueWithoutNotify(Mathf.RoundToInt(game.ModelSize * 100)); value.text = $"{game.ModelSize * 100:0}%  ·  默认 130%"; };
            slider.onValueChanged.AddListener(v => { game.PreviewModelSize(v / 100); refresh(); });
            Label(panel,"70%",new Rect(45,265,90,30),19,ink); Label(panel,"160%",new Rect(425,265,90,30),19,ink);
            Button(panel, "− 1%", new Rect(45, 172, 140, 88), () => { game.PreviewModelSize(game.ModelSize - .01f); refresh(); }, yellow);
            Button(panel, "恢复默认", new Rect(193, 172, 174, 88), () => { game.PreviewModelSize(GooseGame.DefaultModelSize); refresh(); }, yellow);
            Button(panel, "+ 1%", new Rect(375, 172, 140, 88), () => { game.PreviewModelSize(game.ModelSize + .01f); refresh(); }, yellow);
            Button(panel, game.Playing ? "确认并继续" : "保存并返回设置", new Rect(70, 48, 420, 98), () => { if (game.Playing) game.Resume(); else ShowStorySettings(); }, blue);
            refresh();
        }
    }
}
