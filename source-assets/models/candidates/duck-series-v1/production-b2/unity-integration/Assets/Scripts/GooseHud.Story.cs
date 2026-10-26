using UnityEngine;
using UnityEngine.UI;
namespace CatchGoose
{
    public sealed partial class GooseHud
    {
        public const string HomeUiVersion="20261025-DUCKBRAND3";
        bool stickerActionPending;
        void BuildStoryHome()
        {
            stickerActionPending=false;ClearChildren(Home.transform);Home.SetActive(true);Play.SetActive(false);CloseModal();SetBackground(game.Theme.background);
            float h=phone?phone.Height:1280;
            var fxObject=new GameObject("StickerSparkles",typeof(RectTransform),typeof(GooseStickerBurst));Place(fxObject,Home.transform,new Rect(0,0,720,h));
            var fx=fxObject.GetComponent<GooseStickerBurst>();fx.raycastTarget=false;
            var title=new GameObject("MarketSign",typeof(RectTransform));Place(title,Home.transform,new Rect(110,h-320,500,250));
            StickerArt(title.transform,"title",new Rect(0,0,500,250));
            var titleMotion=title.AddComponent<GooseCandyMotion>();titleMotion.IdleAmplitude=.012f;titleMotion.Rock=true;titleMotion.RockDegrees=1.2f;titleMotion.EntranceDelay=.03f;
            var settings=StickerButton("设置",new Rect(614,h-112,90,90),"settings",ShowStorySettings,fx,.1f,false);
            settings.GetComponent<GooseCandyMotion>().HopHeight=0;
            for(int i=0;i<game.Themes.Length;i++)
            {
                int index=i;var theme=game.Themes[i];float x=i%2==0?18:552,y=h-555-(i/2)*215;
                var card=StickerButton("Theme_"+theme.id,new Rect(x,y,150,200),theme.id,()=>game.SelectTheme(index),fx,.12f+i*.055f,game.ThemeIndex==i);
                var visual=card.GetComponent<GooseCandyMotion>().Visual;
                var caption=StickerText(visual,theme.name,new Rect(1,15,148,40),27,Color.white);
                var edge=caption.gameObject.AddComponent<Outline>();edge.effectColor=new Color(.35f,.15f,.04f);edge.effectDistance=new Vector2(2.2f,-2.2f);
                if(game.ThemeIndex==i)
                {
                    var selected=StickerText(visual,"当前",new Rect(95,143,54,30),20,new Color(1,.9f,.25f));
                    var rim=selected.gameObject.AddComponent<Outline>();rim.effectColor=new Color(.28f,.15f,.07f);rim.effectDistance=new Vector2(2,-2);
                }
            }
            var start=StickerButton("StartChallenge",new Rect(50,95,620,207),"cta",game.StartFromHome,fx,.4f,true);
            var startVisual=start.GetComponent<GooseCandyMotion>().Visual;
            var playText=StickerText(startVisual,"开始抓鸭",new Rect(137,30,356,84),56,Color.white);
            var playEdge=playText.gameObject.AddComponent<Outline>();playEdge.effectColor=new Color(.02f,.29f,.47f);playEdge.effectDistance=new Vector2(3,-3);
            var startMotion=start.GetComponent<GooseCandyMotion>();startMotion.Rock=false;startMotion.HopHeight=9;startMotion.IdleAmplitude=.025f;
            fx.SetIdleAnchor(new Vector2(0,95+105-h*.5f));fxObject.transform.SetAsLastSibling();
            game.HomeStage?.Show();game.PlayHomeMusic();
        }
        Image StickerArt(Transform parent,string id,Rect rect)
        {
            string folder=id=="title"||id=="cta"||id=="settings"?"duck-stickers-v3":"home-stickers-v2";
            var image=Panel("GeneratedIllustration",parent,rect,Color.white,"Textures/"+folder+"/"+id).GetComponent<Image>();
            image.preserveAspect=true;image.type=Image.Type.Simple;image.raycastTarget=false;return image;
        }
        Button StickerButton(string name,Rect rect,string id,System.Action action,GooseStickerBurst fx,float delay,bool active)
        {
            var button=Button(Home.transform,"",rect,()=>
            {
                if(stickerActionPending)return;stickerActionPending=true;game.PlaySound("pick");StartCoroutine(CompleteStickerAction(action));
            },yellow);button.name=name;
            // Stable nine-slice hit area; generated irregular art is never stretched.
            button.transition=Selectable.Transition.None;((Image)button.targetGraphic).color=Color.clear;
            var visual=new GameObject("StickerVisual",typeof(RectTransform),typeof(CanvasGroup));Place(visual,button.transform,new Rect(Vector2.zero,rect.size));
            StickerArt(visual.transform,id,new Rect(Vector2.zero,rect.size));
            var motion=button.GetComponent<GooseCandyMotion>();motion.SetVisual(visual.transform);motion.EntranceDelay=delay;motion.Phase=delay*7;
            motion.IdleAmplitude=active?.022f:.008f;motion.Rock=true;motion.RockDegrees=active?3.4f:1.4f;motion.HopHeight=active?9:3;
            motion.Released=()=>{if(fx)fx.EmitAt(fx.rectTransform.InverseTransformPoint(button.transform.position));};
            return button;
        }
        System.Collections.IEnumerator CompleteStickerAction(System.Action action)
        {
            // Keep the release burst visible before the next screen replaces it.
            yield return new WaitForSecondsRealtime(.14f);stickerActionPending=false;action();
        }
        void ShowStorySettings()
        {
            var panel=OpenModal("设置","");
            Button(panel,GooseSave.Sound?"音乐音效：开启":"音乐音效：关闭",new Rect(70,350,420,76),()=>{game.ToggleSound();ShowStorySettings();},yellow);
            var gm=Button(panel,GooseSave.GmUnlimited?"GM 无限次数：开启":"GM 无限次数：关闭",new Rect(70,240,420,76),()=>{game.ToggleGmUnlimited();ShowStorySettings();},yellow);gm.name="GmUnlimited";
            var duckReview=Button(panel,"鸭子模型评审",new Rect(70,135,420,76),ShowDuckReviewMenu,yellow);duckReview.name="DuckModelReview";
            Button(panel,"返回市集",new Rect(70,45,420,88),CloseModal,blue);
        }
    }
}
