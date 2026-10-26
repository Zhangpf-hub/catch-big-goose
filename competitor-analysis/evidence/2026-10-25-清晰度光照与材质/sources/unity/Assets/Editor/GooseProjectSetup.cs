using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using MCPForUnity.Editor.Services;

namespace CatchGoose.Editor
{
    public static class GooseProjectSetup
    {
        [MenuItem("Goose/Prepare Project")]
        public static void Prepare()
        {
            PlayerSettings.companyName = "GooseStudio"; PlayerSettings.productName = "抓住大鹅";
            PlayerSettings.defaultScreenWidth = 450; PlayerSettings.defaultScreenHeight = 844;
            PlayerSettings.fullScreenMode = FullScreenMode.Windowed; PlayerSettings.runInBackground = true;
            PlayerSettings.resizableWindow = true;
            PlayerSettings.colorSpace = ColorSpace.Linear;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Standalone, ScriptingImplementation.Mono2x);
            PlayerSettings.SetApiCompatibilityLevel(BuildTargetGroup.Standalone, ApiCompatibilityLevel.NET_Standard);
            PlayerSettings.WebGL.compressionFormat = WebGLCompressionFormat.Disabled;
            PlayerSettings.WebGL.decompressionFallback = true;
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.Portrait;
            PlayerSettings.bundleVersion = "1.0.0";
            QualitySettings.shadows = ShadowQuality.All; QualitySettings.shadowDistance = 25;
            if (File.Exists("SourceAssets/Fonts/Chinese-full.otf"))
            {
                var font = (TrueTypeFontImporter)AssetImporter.GetAtPath("Assets/Resources/Fonts/Chinese.otf");
                if (!font.fontNames.SequenceEqual(new[] { "Goose UI CJK" }))
                { font.fontNames = new[] { "Goose UI CJK" }; font.SaveAndReimport(); }
            }
            RepairMaterials();
            GoosePhysicsBake.Build();
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            new GameObject("GooseGame").AddComponent<GooseGame>();
            Directory.CreateDirectory("Assets/Scenes");
            EditorSceneManager.SaveScene(scene, "Assets/Scenes/Main.unity");
            EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene("Assets/Scenes/Main.unity", true) };
            EditorPrefs.SetBool("MCPForUnity.UseHttpTransport", true);
            EditorPrefs.SetString("MCPForUnity.HttpUrl", "http://127.0.0.1:8088");
            // The local server is launched by the project script. Only reconnect the editor bridge.
            EditorPrefs.SetBool("MCPForUnity.AutoStartOnLoad", false);
            AssetDatabase.SaveAssets();
            Audit();
            Debug.Log("[GooseSetup] Project prepared");
        }
        [MenuItem("Goose/Repair Imported Materials")]
        public static void RepairMaterials()
        {
            foreach (string file in Directory.GetFiles("Assets/Resources/Models", "materials.json", SearchOption.AllDirectories))
            {
                string folder = Path.GetDirectoryName(file).Replace('\\', '/');
                var data = JsonUtility.FromJson<MaterialList>(File.ReadAllText(file));
                foreach (var item in data.materials)
                {
                    string path = folder + "/" + item.name + ".mat";
                    var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                    if (!material) { material = new Material(Shader.Find("Standard")); AssetDatabase.CreateAsset(material, path); }
                    material.color = new Color(item.color[0], item.color[1], item.color[2], item.color[3]);
                    material.SetFloat("_Metallic", item.metallic); material.SetFloat("_Glossiness", 1 - item.roughness);
                    if (!string.IsNullOrEmpty(item.texture)) material.mainTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(folder + "/" + item.texture);
                    EditorUtility.SetDirty(material);
                }
                string fbx = Directory.GetFiles(folder, "*.fbx").Single().Replace('\\', '/');
                var importer = (ModelImporter)AssetImporter.GetAtPath(fbx);
                var names=new System.Collections.Generic.HashSet<string>(data.materials.Select(m=>m.name));
                foreach(var mapping in importer.GetExternalObjectMap())
                    if(mapping.Key.type==typeof(Material)&&!names.Contains(mapping.Key.name))importer.RemoveRemap(mapping.Key);
                foreach (var item in data.materials)
                    importer.AddRemap(new AssetImporter.SourceAssetIdentifier(typeof(Material), item.name), AssetDatabase.LoadAssetAtPath<Material>(folder + "/" + item.name + ".mat"));
                importer.SaveAndReimport();
            }
            AssetDatabase.SaveAssets();
        }
        public static void Audit()
        {
            var catalog = JsonUtility.FromJson<ThemeCatalog>(Resources.Load<TextAsset>("Data/themes").text);
            foreach (var theme in catalog.themes)
            {
                if (!Resources.Load<Sprite>("Textures/" + theme.background)) throw new Exception("Missing background " + theme.id);
                foreach (var id in theme.items.Concat(new[] { theme.container, "goose" }).Distinct())
                {
                    var model = Resources.Load<GameObject>($"Models/{id}/{id}");
                    if (!model) throw new Exception("Missing model " + id);
                    foreach (var renderer in model.GetComponentsInChildren<Renderer>())
                        foreach (var material in renderer.sharedMaterials)
                            if (!material || !material.shader || !material.shader.isSupported) throw new Exception("Invalid material " + id);
                }
                foreach (var id in theme.items) if (!Resources.Load<Sprite>("Icons/" + id)) throw new Exception("Missing icon " + id);
            }
            if (!Resources.Load<Font>("Fonts/Chinese")) throw new Exception("Chinese font not imported");
            Debug.Log("[GooseSetup] All five themes, models, icons and materials passed the import audit");
        }
        public static void BuildWindows()
        {
            Prepare();
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = "Builds/Windows/CatchGoose.exe", target = BuildTarget.StandaloneWindows64, options = BuildOptions.None });
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded) throw new Exception("Windows build failed");
            Debug.Log("[GooseSetup] Windows release build succeeded");
        }
        public static void BuildQa()
        {
            Prepare();
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = "Builds/WindowsQA/CatchGooseQA.exe", target = BuildTarget.StandaloneWindows64, options = BuildOptions.Development });
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded) throw new Exception("QA build failed");
        }
        public static void BuildWeb()
        {
            Prepare();
            string symbols = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.WebGL);
            PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.WebGL,
                string.Join(";", symbols.Split(';').Where(symbol => symbol != "GOOSE_WECHAT")));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions { scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = "Builds/WebGL", target = BuildTarget.WebGL });
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded) throw new Exception("WebGL build failed");
        }
        [MenuItem("Goose/Connect MCP")]
        public static async void ConnectMcp()
        {
            EditorPrefs.SetBool("MCPForUnity.UseHttpTransport", true);
            EditorPrefs.SetString("MCPForUnity.HttpUrl", "http://127.0.0.1:8088");
            EditorConfigurationCache.Instance.Refresh();
            bool connected = await MCPServiceLocator.Bridge.StartAsync();
            Debug.Log("[GooseSetup] MCP editor connected: " + connected);
        }
        public static void OpenProject()
        {
            EditorSceneManager.OpenScene("Assets/Scenes/Main.unity", OpenSceneMode.Single);
            ConnectMcp();
        }
    }
}
