using System;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace CatchGoose.Editor
{
    // Development players need QA scripts, but do not need LAN discovery.
    // Run after every Windows builder, including builds from the Editor UI.
    public sealed class GoosePlayerNetworkPolicy : IPostprocessBuildWithReport
    {
        public int callbackOrder => int.MaxValue;

        public void OnPostprocessBuild(BuildReport report)
        {
            if (report.summary.platform != BuildTarget.StandaloneWindows &&
                report.summary.platform != BuildTarget.StandaloneWindows64) return;
            if ((report.summary.options & BuildOptions.Development) == 0) return;
            if (Environment.GetEnvironmentVariable("GOOSE_REMOTE_PROFILER") == "1") return;

            string player = Path.GetFullPath(report.summary.outputPath);
            string boot = Path.Combine(Path.GetDirectoryName(player),
                Path.GetFileNameWithoutExtension(player) + "_Data", "boot.config");
            if (!File.Exists(boot))
                throw new BuildFailedException("Missing Windows player boot.config: " + boot);
            ConfigureLocalConnection(boot);
            Debug.Log("[GooseNetwork] Local profiler only; LAN discovery disabled: " + player);
        }

        public static void ConfigureLocalConnection(string boot)
        {
            string[] keys = { "player-connection-mode=", "player-connection-multicast=",
                "player-connection-listen-address=", "player-connection-ip=" };
            var lines = File.ReadAllLines(boot)
                .Where(line => !keys.Any(key => line.StartsWith(key, StringComparison.Ordinal)))
                .Concat(new[] { "player-connection-mode=Listen", "player-connection-multicast=0",
                    "player-connection-listen-address=127.0.0.1", "player-connection-ip=127.0.0.1" });
            File.WriteAllLines(boot, lines, new UTF8Encoding(false));
        }
    }
}
