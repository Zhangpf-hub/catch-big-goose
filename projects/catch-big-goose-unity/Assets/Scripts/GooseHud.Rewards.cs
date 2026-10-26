using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    public sealed partial class GooseHud
    {
        public void AnimateSaleReward(int count) { StartCoroutine(SaleRewardFlight(count)); }
        IEnumerator SaleRewardFlight(int count)
        {
            var round = game.Rewards;
            var sprites = new[] { "remove", "match", "shuffle" };
            var flyers = new RectTransform[3];
            float center = game.SaleTruck.LaneRect.anchoredPosition.y;
            float originX = game.SaleTruck.TruckRect.anchoredPosition.x;
            for (int i = 0; i < flyers.Length; i++)
            {
                var image = Panel("RewardFlight" + i, Play.transform, new Rect(originX - 70 + i * 30, center - 40, 80, 80), Color.white,
                    "Textures/story-ui/" + sprites[i]).GetComponent<Image>();
                image.raycastTarget = false; image.preserveAspect = true; flyers[i] = image.rectTransform;
                var number = Label(flyers[i], "+" + count, new Rect(35, 35, 60, 42), 25, new Color(1, .75f, .1f));
                number.raycastTarget = false; number.gameObject.AddComponent<Outline>().effectColor = new Color(.3f, .18f, .05f);
            }
            float age = 0;
            while (age < .9f && game.Playing && game.Rewards == round)
            {
                if (!game.Paused && game.AppVisible) age += Time.deltaTime;
                float t = Mathf.SmoothStep(0, 1, age / .9f);
                for (int i = 0; i < flyers.Length; i++)
                {
                    flyers[i].anchoredPosition = Vector2.Lerp(new Vector2(originX - 30 + i * 30, center), new Vector2(142 + i * 218, 105), t)
                        + Vector2.up * Mathf.Sin(t * Mathf.PI) * 100;
                    flyers[i].localScale = Vector3.one * Mathf.Lerp(1.15f, .65f, t);
                }
                yield return null;
            }
            foreach (var flyer in flyers) if (flyer) Destroy(flyer.gameObject);
        }
    }
}
