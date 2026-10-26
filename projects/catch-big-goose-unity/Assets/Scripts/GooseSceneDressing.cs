using System.Collections;
using System.Linq;
using UnityEngine;
namespace CatchGoose
{
    // Source scene containers and small theme props dress the otherwise empty
    // upper counter. They never enter gameplay physics or the stock budget.
    public sealed class GooseSceneDressing:MonoBehaviour
    {
        GooseGame game;Camera camera;GameObject root;Transform tray,extras;Coroutine job;
        readonly GooseAssetCache cache=new GooseAssetCache();
        public void Initialize(GooseGame owner)
        {
            game=owner;camera=new GameObject("MarketCounterCamera").AddComponent<Camera>();camera.depth=-2;camera.clearFlags=CameraClearFlags.Depth;
            camera.orthographic=true;camera.cullingMask=1<<26;camera.nearClipPlane=.05f;camera.farClipPlane=60;camera.enabled=false;
        }
        static void Layer(Transform t){t.gameObject.layer=26;foreach(Transform c in t)Layer(c);}
        public void Show()
        {
            Hide();cache.Clear();root=new GameObject("SourceSceneDressing");root.transform.position=Vector3.right*200;camera.enabled=true;job=StartCoroutine(Build(game.Theme));
        }
        IEnumerator Build(ThemeDefinition theme)
        {
            // Food scenes use the recovered bamboo serving plate, rather than
            // miniaturizing a full stove/grill with legs into a floating prop.
            string key=theme.id=="reference_toys"?"toys":theme.id;
            string id=key=="toys"||key=="grocery"?"scene_"+key:"scene_breakfast";yield return cache.Prepare(id,false);
            tray=new GameObject("SourceCounter").transform;tray.SetParent(root.transform,false);var table=cache.Instantiate(id,tray);
            tray.localScale=Vector3.one*(theme.id=="barbecue"?1.85f:1.65f);tray.localRotation=Quaternion.Euler(0,-15,0);
            var b=GooseGame.BoundsOf(table);table.transform.position-=b.center-tray.position;Layer(tray);
            extras=new GameObject("CounterProps").transform;extras.SetParent(root.transform,false);
            var ids=theme.items.Where(x=>!x.StartsWith("ref_goose_")).Take(4).ToArray();
            for(int i=0;i<ids.Length;i++)
            {
                yield return cache.Prepare(ids[i],false);var wrap=new GameObject("Decor_"+ids[i]).transform;wrap.SetParent(extras,false);
                cache.Instantiate(ids[i],wrap);wrap.localScale=Vector3.one*.46f;wrap.localPosition=new Vector3((i%2)*.45f,0,(i/2)*.38f);wrap.localRotation=Quaternion.Euler(0,i*35,0);Layer(wrap);
            }
            Layout();job=null;
        }
        void Layout()
        {
            if(!camera.enabled)return;camera.rect=game.MainCamera.rect;camera.orthographicSize=game.MainCamera.orthographicSize;
            camera.transform.SetPositionAndRotation(game.MainCamera.transform.position+Vector3.right*200,game.MainCamera.transform.rotation);
            if(tray)tray.position=camera.ViewportToWorldPoint(new Vector3(.27f,.83f,20));
            if(extras)extras.position=camera.ViewportToWorldPoint(new Vector3(.74f,.86f,20));
        }
        void LateUpdate(){if(camera&&camera.enabled)Layout();}
        public void Hide(){if(job!=null)StopCoroutine(job);job=null;if(root)Destroy(root);root=null;tray=extras=null;if(camera)camera.enabled=false;}
        void OnDestroy(){Hide();cache.Clear();if(camera)Destroy(camera.gameObject);}
    }
}
