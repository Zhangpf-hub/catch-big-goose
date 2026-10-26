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
            string root = GooseWorkspace.Root;
            string settingsPath = Path.Combine(Application.dataPath, "../WeChatBuild.local.json");
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
            Set(serialized, "ProjectConf.projectName", GooseWorkspace.ProjectName);
            Set(serialized, "ProjectConf.Appid", appId);
            Set(serialized, "ProjectConf.relativeDST", "Builds/WeChat");
            Set(serialized, "ProjectConf.DST", output);
            Set(serialized, "ProjectConf.assetLoadType", 1);
            Set(serialized, "ProjectConf.compressDataPackage", true);
            Set(serialized, "ProjectConf.CDN", "");
            Set(serialized, "ProjectConf.StreamCDN", "");
            Set(serialized, "ProjectConf.Orientation", 0);
            Set(serialized, "ProjectConf.MemorySize", 256);
            const string cover="Assets/loading-art/duck-loading.jpg";
            if (!File.Exists(cover)) throw new Exception("Missing 抓鸭子 loading cover");
            Set(serialized, "ProjectConf.bgImageSrc", cover);
            Set(serialized, "ProjectConf.IOSDevicePixelRatio", 2f);
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
            ApplyDuckLoadingBrand(miniGame);
            if (!settings.development) ArchiveUncompressedSymbols(miniGame, root);
            CopyMedia(Path.Combine(root, "work/wechat-integration/media"), Path.Combine(miniGame, "media"));
            var jsonPath = Path.Combine(miniGame, "game.json");
            var json = Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(jsonPath));
            var packages = (Newtonsoft.Json.Linq.JArray)json["subpackages"];
            packages.Add(new Newtonsoft.Json.Linq.JObject { ["name"] = "goose-media", ["root"] = "media/" });
            File.WriteAllText(jsonPath, json.ToString());
            long size = PackagedBytes(miniGame, root);
            Debug.Log($"[GooseWeChat] Exported {miniGame}; total bytes={size}; AppID={(appId == "touristappid" ? "pending registration" : appId)}");
            if (size > 30L * 1024 * 1024) throw new Exception("WeChat package exceeds 30 MiB: " + size);
            if (config.ProjectConf.assetLoadType != 1) throw new Exception("SDK fell back to remote CDN; bundle needs optimization");
            PublishExport(miniGame);
        }
        static void ApplyDuckLoadingBrand(string directory)
        {
            string script=Path.Combine(directory,"game.js"),text=File.ReadAllText(script);
            if(!text.Contains("images/duck-loading.jpg"))throw new Exception("Loading configuration is not using the 抓鸭子 cover");
            text=text.Replace("firstStartText: '首次加载请耐心等待'","firstStartText: '抓鸭子正在准备，请稍候'")
                .Replace("downloadingText: ['正在加载资源']","downloadingText: ['正在加载鸭子与场景']")
                .Replace("completeText: '开始游戏'","completeText: '开始抓鸭'")
                .Replace("backgroundColor: '#07C160'","backgroundColor: '#14b9ed'");
            File.WriteAllText(script,text);
            string image=Path.Combine(directory,"images/duck-loading.jpg");
            if(!File.Exists(image)||!File.ReadAllBytes(image).SequenceEqual(File.ReadAllBytes("Assets/loading-art/duck-loading.jpg")))
                throw new Exception("Published duck loading cover does not match source artwork");
        }
        static long PackagedBytes(string directory,string root)
        {
            // The SDK excludes diagnostic symbols in project.config.json.
            // Use that same published file set for the unchanged 30 MiB gate.
            var config=Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(Path.Combine(directory,"project.config.json")));
            var ignores=(Newtonsoft.Json.Linq.JArray)config["packOptions"]?["ignore"]??new Newtonsoft.Json.Linq.JArray();
            var included=new List<object>();var excluded=new List<object>();long bytes=0,rawBytes=0;
            foreach(string file in Directory.GetFiles(directory,"*",SearchOption.AllDirectories))
            {
                string relative=file.Substring(directory.Length).TrimStart(Path.DirectorySeparatorChar).Replace('\\','/');
                long length=new FileInfo(file).Length;rawBytes+=length;bool skip=relative.EndsWith(".meta",StringComparison.Ordinal);
                foreach(var rule in ignores)
                {
                    string type=(string)rule["type"],value=((string)rule["value"]??"").Trim('/');
                    if(string.IsNullOrEmpty(value))throw new Exception("Empty package ignore rule");
                    if(type=="suffix")skip|=relative.EndsWith(value,StringComparison.Ordinal);
                    else if(type=="file")skip|=relative==value;
                    else if(type=="folder")skip|=relative==value||relative.StartsWith(value+"/",StringComparison.Ordinal);
                    else throw new Exception("Unsupported package ignore rule: "+type);
                }
                var row=new{path=relative,bytes=length};if(skip)excluded.Add(row);else{included.Add(row);bytes+=length;}
            }
            string audit=Path.Combine(root,"work/wechat-integration/package-file-audit.json");Directory.CreateDirectory(Path.GetDirectoryName(audit));
            File.WriteAllText(audit,Newtonsoft.Json.JsonConvert.SerializeObject(new{rawBytes,packagedBytes=bytes,maximumBytes=30L*1024*1024,included,excluded},Newtonsoft.Json.Formatting.Indented));
            Debug.Log($"[GooseWeChat] Package file audit: {bytes} bytes included, {rawBytes-bytes} bytes excluded by project configuration");
            return bytes;
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
                .Replace("$APP_ID", appId).Replace("$PROJECT_NAME", GooseWorkspace.ProjectName).Replace("$GAME_NAME", "webgl");
            var project = Newtonsoft.Json.Linq.JObject.Parse(template);
            if (File.Exists(path)) project.Merge(Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(path)),
                new Newtonsoft.Json.Linq.JsonMergeSettings { MergeArrayHandling = Newtonsoft.Json.Linq.MergeArrayHandling.Union });
            project["compileType"] = "game"; project["appid"] = appId;
            project["projectname"] = GooseWorkspace.ProjectName;
            project["setting"]["es6"] = true;
            File.WriteAllText(path, project.ToString());
        }
        static void CopyMedia(string source, string target)
        {
            if (!Directory.Exists(source)) throw new Exception("Run tools/unity/prepare_wechat_media.py first");
            Directory.CreateDirectory(target);
            foreach (string file in Directory.GetFiles(source)) File.Copy(file, Path.Combine(target, Path.GetFileName(file)), true);
        }
        static void PublishExport(string source)
        {
            // SDK requires its internal minigame folder. Only this named export is
            // exposed to DevTools; retain the last working export until conversion passes.
            string target = GooseWorkspace.WeChatProject;
            string previous = Path.GetFullPath("Builds/WeChat/previous-minigame");
            string buildRoot = Path.GetFullPath("Builds") + Path.DirectorySeparatorChar;
            if (!previous.StartsWith(buildRoot, StringComparison.OrdinalIgnoreCase))
                throw new Exception("Invalid previous-export directory");
            Directory.CreateDirectory(Path.GetDirectoryName(target));
            if (Directory.Exists(previous)) Directory.Delete(previous, true);
            if (Directory.Exists(target)) Directory.Move(target, previous);
            try { Directory.Move(source, target); }
            catch
            {
                if (!Directory.Exists(target) && Directory.Exists(previous)) Directory.Move(previous, target);
                throw;
            }
            if (Directory.Exists(previous)) Directory.Delete(previous, true);
            Debug.Log("[GooseWeChat] Developer Tools project: " + target);
        }
    }
}
