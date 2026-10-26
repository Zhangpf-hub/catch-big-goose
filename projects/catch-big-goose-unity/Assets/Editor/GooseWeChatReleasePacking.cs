using System;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;

namespace CatchGoose.Editor
{
    public static class GooseWeChatReleasePacking
    {
        public static void Compact(string directory, string root)
        {
            string script=Path.Combine(root,"tools/unity/compact-wechat-export.mjs");
            if(!File.Exists(script))throw new InvalidOperationException("Missing WeChat release compactor: "+script);
            var info=new ProcessStartInfo("node","\""+script+"\" \""+directory+"\""){
                WorkingDirectory=root,UseShellExecute=false,CreateNoWindow=true,
                RedirectStandardOutput=true,RedirectStandardError=true};
            using(var process=Process.Start(info))
            {
                var output=process.StandardOutput.ReadToEndAsync();var errors=process.StandardError.ReadToEndAsync();
                process.WaitForExit();
                if(process.ExitCode!=0)throw new InvalidOperationException("Release JS compaction failed: "+errors.GetAwaiter().GetResult());
                string report=output.GetAwaiter().GetResult();
                string evidence=Path.Combine(root,"work/wechat-integration/release-js-packing.json");
                Directory.CreateDirectory(Path.GetDirectoryName(evidence));File.WriteAllText(evidence,report);
                UnityEngine.Debug.Log("[GooseWeChat] "+report);
            }
        }

        // Recover an otherwise complete SDK export stopped by the local budget
        // gate; never rebuild or alter its game/video assets here.
        public static void PublishPrepared()
        {
            string root=GooseWorkspace.Root,directory=Path.GetFullPath("Builds/WeChat/minigame");
            if(!File.Exists(Path.Combine(directory,"project.config.json"))||!Directory.Exists(Path.Combine(directory,"media")))
                throw new InvalidOperationException("A complete prepared SDK export is required");
            if(!Regex.IsMatch(File.ReadAllText(Path.Combine(directory,"unity-namespace.js")),@"\buseBrotliMT:\s*false\b"))
                throw new InvalidOperationException("Prepared export must use single-thread Brotli");
            Compact(directory,root);
            long bytes=GooseWeChatBuild.PackagedBytes(directory,root);
            if(bytes>GooseWeChatBuild.LocalReleaseBudget)throw new InvalidOperationException("Compacted release exceeds the shared release budget: "+bytes);
            GooseWeChatBuild.PublishExport(directory);
        }
    }
}
