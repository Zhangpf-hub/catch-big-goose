using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace CatchGoose
{
    // One shared generated atlas, pooled UI images, no dynamic font atlas uploads.
    public sealed class GooseSpriteNumber : MonoBehaviour
    {
        static Dictionary<char,Sprite> glyphs;
        Image[] images;
        public string Value { get; private set; }
        public bool Warning { get; private set; }

        public void Initialize(int capacity)
        {
            if(glyphs==null)
            {
                glyphs=new Dictionary<char,Sprite>();
                foreach(var sprite in Resources.LoadAll<Sprite>("Textures/hud-numbers/golden-digits-v1"))
                {
                    string id=sprite.name.Substring("glyph-".Length);
                    glyphs.Add(id=="colon"?':':id=="infinity"?'∞':id[0],sprite);
                }
                foreach(char c in "0123456789:∞")
                    if(!glyphs.ContainsKey(c))throw new InvalidOperationException("Missing HUD numeral: "+c);
            }
            images=new Image[capacity];
            for(int i=0;i<capacity;i++)
            {
                var go=new GameObject("Digit",typeof(RectTransform),typeof(Image));
                go.layer=gameObject.layer;go.transform.SetParent(transform,false);
                images[i]=go.GetComponent<Image>();images[i].raycastTarget=false;
                images[i].enabled=false;
            }
        }

        public void Show(string value,bool warning=false)
        {
            if(value==Value&&warning==Warning)return;
            if(value.Length>images.Length)throw new ArgumentOutOfRangeException(nameof(value));
            var bounds=((RectTransform)transform).rect;
            float height=bounds.height,width=0,gap=height*.025f;
            foreach(char c in value)width+=height*Aspect(c)+gap;
            width=Mathf.Max(0,width-gap);
            float scale=Mathf.Min(1,bounds.width/Mathf.Max(1,width));
            float x=-width*scale*.5f;
            for(int i=0;i<images.Length;i++)
            {
                var image=images[i];image.enabled=i<value.Length;
                if(!image.enabled)continue;
                char c=value[i];float w=height*Aspect(c)*scale,h=height*Height(c)*scale;
                image.sprite=glyphs[c];image.color=warning?new Color(1,.42f,.28f):Color.white;
                var rect=image.rectTransform;rect.anchorMin=rect.anchorMax=rect.pivot=Vector2.one*.5f;
                rect.sizeDelta=new Vector2(w,h);rect.anchoredPosition=new Vector2(x+w*.5f,0);
                x+=w+gap*scale;
            }
            Value=value;Warning=warning;
        }
        static float Height(char c)=>c==':'?.78f:c=='∞'?.65f:1;
        static float Aspect(char c)=>glyphs[c].rect.width/glyphs[c].rect.height*Height(c);
    }
}
