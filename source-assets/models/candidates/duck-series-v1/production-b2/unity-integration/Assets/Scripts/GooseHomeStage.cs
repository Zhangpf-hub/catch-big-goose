using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;
namespace CatchGoose
{
    // Home owns an isolated layer/light; furniture and mascot survive theme changes.
    public sealed class GooseHomeStage:MonoBehaviour
    {
        public const float TableTop=-.1f;
        GooseGame game;GameObject root,props,duck;Camera camera;Transform mascot;Coroutine load;Light key;
        readonly GooseAssetCache cache=new GooseAssetCache();
        readonly Dictionary<Material,Material> litMaterials=new Dictionary<Material,Material>();
        MaterialPropertyBlock homeFill;
        Material groundMaterial;string themeId;bool tableReady;
        public GooseDuckMascot DuckMascot {get;private set;}
        public Camera Camera=>camera;
        public Light KeyLight=>key;
        public GameObject Table {get;private set;}
        public bool FreezeAnimationForQa {get;set;}
        public bool Ready=>root&&mascot&&load==null;
        public void Initialize(GooseGame owner)
        {
            homeFill=new MaterialPropertyBlock();
            game=owner;camera=new GameObject("HomeStageCamera").AddComponent<Camera>();camera.depth=0;camera.clearFlags=CameraClearFlags.Depth;
            camera.cullingMask=1<<28;camera.orthographic=true;camera.orthographicSize=3.05f;camera.nearClipPlane=.1f;camera.farClipPlane=30;
            camera.transform.position=new Vector3(100,5.7f,-7);camera.transform.LookAt(new Vector3(100,.6f,0));camera.enabled=false;
            key=new GameObject("HomeKeyLight").AddComponent<Light>();key.transform.SetParent(transform,false);
            key.type=LightType.Directional;key.cullingMask=1<<28;key.color=new Color(1,.96f,.90f);key.intensity=.9f;
            key.shadows=LightShadows.Soft;key.shadowCustomResolution=1024;key.shadowStrength=.45f;key.shadowBias=.02f;key.shadowNormalBias=.05f;
            key.transform.rotation=Quaternion.Euler(50,35,0);key.enabled=false;
            homeFill.SetFloat("_FillStrength",.25f);homeFill.SetFloat("_DirectStrength",.75f);
        }
        public void Show()
        {
            if(!camera)return;camera.enabled=true;Layout();game.ReferenceLighting.Home(key,true);
            if(!root){root=new GameObject("LiveMarketDisplay");root.transform.position=new Vector3(100,0,0);}
            root.SetActive(true);
            if(themeId==game.Theme.id&&(load!=null||Ready))return;
            if(load!=null)StopCoroutine(load);
            if(props){props.SetActive(false);Destroy(props);}
            themeId=game.Theme.id;load=StartCoroutine(Build((string[])game.Theme.items.Clone()));
        }
        static void Layer(Transform t){t.gameObject.layer=28;foreach(Transform c in t)Layer(c);}
        void LightMaterials(GameObject visual)
        {
            Layer(visual.transform);
            foreach(var renderer in visual.GetComponentsInChildren<Renderer>())
            {
                var materials=renderer.sharedMaterials;
                for(int i=0;i<materials.Length;i++)
                {
                    var original=materials[i];if(original.shader.name.StartsWith("Goose/Reference"))continue;
                    if(!litMaterials.TryGetValue(original,out var lit))
                    {
                        lit=new Material(Resources.Load<Shader>("GooseReferenceOpaque")){name=original.name+"_HomeLit",mainTexture=original.mainTexture,color=original.color,enableInstancing=true};litMaterials.Add(original,lit);
                    }
                    materials[i]=lit;
                }
                renderer.sharedMaterials=materials;bool glass=materials[0].shader.name=="Goose/ReferenceGlass";
                renderer.shadowCastingMode=glass?ShadowCastingMode.Off:ShadowCastingMode.On;renderer.receiveShadows=!glass;renderer.SetPropertyBlock(homeFill);
            }
        }
        IEnumerator Build(string[] ids)
        {
            var retained=new HashSet<string>{"home-table"};for(int i=0;i<14;i++)retained.Add(ids[(i*7+i/3)%ids.Length]);cache.Retain(retained);
            if(!tableReady)
            {
                yield return cache.Prepare("home-table",false);
                var anchor=new GameObject("HomeTable").transform;anchor.SetParent(root.transform,false);anchor.localScale=Vector3.one*4.6f;
                Table=cache.Instantiate("home-table",anchor);var bounds=GooseGame.BoundsOf(Table);
                anchor.position+=new Vector3(100-bounds.center.x,TableTop-bounds.max.y,-bounds.center.z);LightMaterials(Table);
                var ground=GameObject.CreatePrimitive(PrimitiveType.Quad);ground.name="HomeGroundShadow";ground.transform.SetParent(root.transform,false);
                ground.transform.position=new Vector3(100,GooseGame.BoundsOf(Table).min.y-.01f,0);ground.transform.rotation=Quaternion.Euler(90,0,0);ground.transform.localScale=new Vector3(5.6f,5.6f,1);
                Destroy(ground.GetComponent<Collider>());Layer(ground.transform);groundMaterial=new Material(Resources.Load<Shader>("GooseHomeShadow")){name="HomeGroundShadowMaterial"};
                var r=ground.GetComponent<Renderer>();r.sharedMaterial=groundMaterial;r.shadowCastingMode=ShadowCastingMode.Off;r.receiveShadows=true;tableReady=true;
                var ld=-key.transform.forward;groundMaterial.SetVector("_HomeLightDir",new Vector4(ld.x,ld.y,ld.z,0));
            }
            if(!mascot)
            {
                var request=Resources.LoadAsync<GameObject>("Mascots/DuckHome");yield return request;
                if(!request.asset)throw new System.InvalidOperationException("The approved B2 duck prefab is missing");
                var anchor=new GameObject("DuckMascotAnchor");anchor.transform.SetParent(root.transform,false);mascot=anchor.transform;
                duck=Instantiate((GameObject)request.asset,mascot);DuckMascot=duck.GetComponent<GooseDuckMascot>();
                var b=GooseGame.BoundsOf(duck);float extent=Mathf.Max(b.size.x,b.size.y,b.size.z);
                mascot.localScale=Vector3.one*(2.35f/extent);mascot.localRotation=Quaternion.Euler(0,180,0);
                b=GooseGame.BoundsOf(duck);mascot.position+=new Vector3(100-b.center.x,TableTop-b.min.y,-b.center.z);
                LightMaterials(duck);
            }
            props=new GameObject("HomeThemeProps");props.transform.SetParent(root.transform,false);
            for(int i=0;i<14;i++)
            {
                string id=ids[(i*7+i/3)%ids.Length];yield return cache.Prepare(id,false);if(!root)yield break;
                var wrap=new GameObject("Display_"+id).transform;wrap.SetParent(props.transform,false);var visual=cache.Instantiate(id,wrap);
                float a=i*Mathf.PI*2/14;wrap.localScale=Vector3.one*(i%3==0?.83f:.63f);wrap.localRotation=Quaternion.Euler(0,i*37,0);
                wrap.localPosition=new Vector3(Mathf.Sin(a)*1.6f,0,Mathf.Cos(a)*1.4f);var b=GooseGame.BoundsOf(visual);wrap.position+=Vector3.up*(TableTop-b.min.y);LightMaterials(visual);
            }
            load=null;
        }
        public void Hide(){if(camera)camera.enabled=false;if(root)root.SetActive(false);game.ReferenceLighting.Home(key,false);}
        public void React(){DuckMascot?.React();game.PlaySound("honk");}
        public void SetShadowsForQa(bool enabled){key.shadows=enabled?LightShadows.Soft:LightShadows.None;if(groundMaterial)groundMaterial.SetFloat("_ContactStrength",enabled?1:0);}
        void Layout()
        {
            var frame=game.Hud.Frame;float h=frame.rect.height;
            var lo=RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,frame.TransformPoint(new Vector3(-360,410-h*.5f)));
            var hi=RectTransformUtility.WorldToScreenPoint(game.Hud.HudCamera,frame.TransformPoint(new Vector3(360,h*.5f-260)));
            camera.pixelRect=new Rect(lo.x,lo.y,hi.x-lo.x,Mathf.Max(100,hi.y-lo.y));camera.orthographicSize=2.65f/Mathf.Max(.65f,camera.aspect);
        }
        void Update()
        {
            bool showing=camera&&camera.enabled&&(!game.Video||!game.Video.Active);if(key)key.enabled=showing;
            if(!showing)return;Layout();
            if(DuckMascot)DuckMascot.Freeze(FreezeAnimationForQa);
            if(Input.GetMouseButtonDown(0)&&camera.pixelRect.Contains(Input.mousePosition)&&(!EventSystem.current||!EventSystem.current.IsPointerOverGameObject()))React();
        }
        void OnDestroy()
        {
            cache.Clear();foreach(var material in litMaterials.Values)if(material)Destroy(material);litMaterials.Clear();
            if(groundMaterial)Destroy(groundMaterial);if(root)Destroy(root);if(camera)Destroy(camera.gameObject);if(key)Destroy(key.gameObject);
        }
    }
}
