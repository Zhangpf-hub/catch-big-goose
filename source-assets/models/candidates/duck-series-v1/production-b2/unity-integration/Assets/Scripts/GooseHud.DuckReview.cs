using UnityEngine;
namespace CatchGoose
{
    public sealed partial class GooseHud
    {
        public void ShowDuckReviewMenu()
        {
            game.LoadDuckReviewCatalog();
            var panel=OpenModal("鸭子模型评审","");
            Label(panel,"独立评审，不计正式成绩",new Rect(45,430,470,55),24,ink);
            for(int i=0;i<game.DuckReviewThemes.Length;i++)
            {
                int index=i;string name=game.DuckReviewThemes[i].name.Replace("鸭子评审 · ","");
                var button=Button(panel,name,new Rect(70,360-i*61,420,53),()=>game.BeginDuckReview(index),yellow);
                button.name="DuckReviewTheme"+i;
            }
            Button(panel,"返回",new Rect(70,40,420,56),CloseModal,blue);
        }
    }
}
