using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using WeChatWASM;

namespace CatchGoose.Editor
{
    public static class GooseWeChatBuild
    {
        [Serializable] public class Settings { public string appId = ""; public bool development = false; }
        [MenuItem("Goose/Build WeChat Mini Game")]
        public static void Build() { Export(true); }
        public static void ConvertExisting() { Export(false); }
        static void Export(bool buildWebGL)
        {
            if (!BuildPipeline.IsBuildTargetSupported(BuildTargetGroup.WebGL, BuildTarget.WebGL))
                throw new Exception("Install WebGL Build Support for Unity 2022.3.62f3 first");
            string root = Path.GetFullPath("..");
            string settingsPath = Path.Combine(root, "unity/WeChatBuild.local.json");
            var settings = File.Exists(settingsPath) ? JsonUtility.FromJson<Settings>(File.ReadAllText(settingsPath)) : new Settings();
            string appId = string.IsNullOrWhiteSpace(settings.appId) ? "touristappid" : settings.appId.Trim();
            if (appId != "touristappid" && !System.Text.RegularExpressions.Regex.IsMatch(appId, "^wx[0-9a-f]{16}$"))
                throw new Exception("Invalid WeChat AppID");
            GooseProjectSetup.Prepare();
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.WebGL, ScriptingImplementation.IL2CPP);
            string symbols = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.WebGL);
            if (!symbols.Split(';').Contains("GOOSE_WECHAT"))
                PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.WebGL, symbols + ";GOOSE_WECHAT");
            PlayerSettings.WebGL.memorySize = 256;
            PlayerSettings.WebGL.exceptionSupport = WebGLExceptionSupport.ExplicitlyThrownExceptionsOnly;
            PlayerSettings.WebGL.decompressionFallback = false;
            string output = Path.GetFullPath("Builds/WeChat");
            var config = WXConvertCore.config;
            var serialized = new SerializedObject(config);
            Set(serialized, "ProjectConf.projectName", "CatchGoose");
            Set(serialized, "ProjectConf.Appid", appId);
            Set(serialized, "ProjectConf.relativeDST", "Builds/WeChat");
            Set(serialized, "ProjectConf.DST", output);
            Set(serialized, "ProjectConf.assetLoadType", 1);
            Set(serialized, "ProjectConf.compressDataPackage", true);
            Set(serialized, "ProjectConf.CDN", "");
            Set(serialized, "ProjectConf.StreamCDN", "");
            Set(serialized, "ProjectConf.Orientation", 0);
            Set(serialized, "ProjectConf.MemorySize", 256);
            var cover = Resources.Load<Sprite>("Textures/challenge-map-bg");
            if (!cover) throw new Exception("Missing loading cover");
            Set(serialized, "ProjectConf.bgImageSrc", AssetDatabase.GetAssetPath(cover));
            Set(serialized, "ProjectConf.IOSDevicePixelRatio", 1.5f);
            Set(serialized, "SDKOptions.UseFriendRelation", false);
            Set(serialized, "SDKOptions.UseMiniGameChat", false);
            Set(serialized, "SDKOptions.PreloadWXFont", false);
            Set(serialized, "CompileOptions.DevelopBuild", settings.development);
            Set(serialized, "CompileOptions.AutoProfile", false);
            Set(serialized, "CompileOptions.ProfilingMemory", false);
            Set(serialized, "CompileOptions.profilingFuncs", false);
            Set(serialized, "CompileOptions.Il2CppOptimizeSize", true);
            Set(serialized, "CompileOptions.Webgl2", true);
            Set(serialized, "CompileOptions.DeleteStreamingAssets", true);
            Set(serialized, "CompileOptions.enableIOSPerformancePlus", false);
            Set(serialized, "CompileOptions.enableiOSMetal", false);
            Set(serialized, "CompileOptions.enableEmscriptenGLX", false);
            Set(serialized, "CompileOptions.showMonitorSuggestModal", false);
            serialized.ApplyModifiedPropertiesWithoutUndo(); EditorUtility.SetDirty(config); AssetDatabase.SaveAssets();
            var result = WXConvertCore.DoExport(buildWebGL);
            if (result != WXConvertCore.WXExportError.SUCCEED) throw new Exception("WXSDK export failed: " + result);
            string miniGame = Path.Combine(output, "minigame");
            EnsureProjectConfiguration(miniGame, appId);
            if (!settings.development) ArchiveUncompressedSymbols(miniGame, root);
            CopyMedia(Path.Combine(root, "work/wechat-integration/media"), Path.Combine(miniGame, "media"));
            var jsonPath = Path.Combine(miniGame, "game.json");
            var json = Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(jsonPath));
            var packages = (Newtonsoft.Json.Linq.JArray)json["subpackages"];
            packages.Add(new Newtonsoft.Json.Linq.JObject { ["name"] = "goose-media", ["root"] = "media/" });
            File.WriteAllText(jsonPath, json.ToString());
            long size = Directory.GetFiles(miniGame, "*", SearchOption.AllDirectories).Where(f => !f.EndsWith(".meta"))
                .Sum(f => new FileInfo(f).Length);
            Debug.Log($"[GooseWeChat] Exported {miniGame}; total bytes={size}; AppID={(appId == "touristappid" ? "pending registration" : appId)}");
            if (size > 30L * 1024 * 1024) throw new Exception("WeChat package exceeds 30 MiB: " + size);
            if (config.ProjectConf.assetLoadType != 1) throw new Exception("SDK fell back to remote CDN; bundle needs optimization");
        }
        static void Set(SerializedObject target, string path, object value)
        {
            var property = target.FindProperty(path);
            if (property == null) throw new Exception("WXSDK configuration field missing: " + path);
            if (value is string text) property.stringValue = text;
            else if (value is bool flag) property.boolValue = flag;
            else if (value is int number) property.intValue = number;
            else if (value is float real) property.floatValue = real;
        }
        static void ArchiveUncompressedSymbols(string miniGame, string root)
        {
            // SDK emits both raw and Brotli symbols. The raw JSON is an editor /
            // incremental-code-split input, not required by this unsplit release.
            // Retain compressed runtime diagnostics and preserve raw bytes locally.
            string source = Path.Combine(miniGame, "webgl.wasm.symbols.unityweb");
            if (!File.Exists(source)) return;
            byte[] bytes = File.ReadAllBytes(source);
            string hash;
            using (var sha = System.Security.Cryptography.SHA256.Create())
                hash = BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
            string target = Path.Combine(root, "work/wechat-integration/release-symbols", hash);
            Directory.CreateDirectory(target); File.Copy(source, Path.Combine(target, Path.GetFileName(source)), true);
            File.Delete(source);
            Debug.Log("[GooseWeChat] Raw symbols archived outside package: " + bytes.Length + " bytes; compressed symbols retained");
        }
        static void EnsureProjectConfiguration(string miniGame, string appId)
        {
            var path = Path.Combine(miniGame, "project.config.json");
            var template = File.ReadAllText("Packages/com.qq.weixin.minigame/Runtime/wechat-default/project.config.json")
                .Replace("$APP_ID", appId).Replace("$PROJECT_NAME", "CatchGoose").Replace("$GAME_NAME", "webgl");
            var project = Newtonsoft.Json.Linq.JObject.Parse(template);
            if (File.Exists(path)) project.Merge(Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(path)),
                new Newtonsoft.Json.Linq.JsonMergeSettings { MergeArrayHandling = Newtonsoft.Json.Linq.MergeArrayHandling.Union });
            project["compileType"] = "game"; project["appid"] = appId;
            project["setting"]["es6"] = true;
            File.WriteAllText(path, project.ToString());
        }
        static void CopyMedia(string source, string target)
        {
            if (!Directory.Exists(source)) throw new Exception("Run tools/unity/prepare_wechat_media.py first");
            Directory.CreateDirectory(target);
            foreach (string file in Directory.GetFiles(source)) File.Copy(file, Path.Combine(target, Path.GetFileName(file)), true);
        }
    }
}
