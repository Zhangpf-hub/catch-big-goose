using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    public static class GooseUiSurface
    {
        public const float PixelsPerUnitMultiplier=2;
        public static void Apply(Image image,Sprite sprite)
        {
            image.sprite=sprite;image.type=Image.Type.Sliced;image.fillCenter=true;
            image.pixelsPerUnitMultiplier=PixelsPerUnitMultiplier;
        }
    }
}
