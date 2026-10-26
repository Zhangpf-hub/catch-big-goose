using System;
using System.IO;
using System.Security.Cryptography;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace CatchGoose.Editor
{
    public static class GooseAlgorithmBuild
    {
        public static void Build()
        { BuildTo("Builds/AlgorithmQA/CatchGooseAlgorithmQA.exe"); }
        public static void BuildPerformance()
        { BuildTo("Builds/PerformanceQA/CatchGoosePerformanceQA.exe"); }
        static void BuildTo(string target)
        {
            GooseProjectSetup.Prepare();
            var result = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
                scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = target,
                target = BuildTarget.StandaloneWindows64, options = BuildOptions.Development
            });
            if (result.summary.result != BuildResult.Succeeded) throw new Exception("Algorithm QA player build failed");
            string project = Directory.GetParent(Application.dataPath).FullName;
            using (var hash = SHA256.Create())
            using (var writer = new StreamWriter(Path.Combine(project, Path.GetDirectoryName(target), "source-hashes.tsv")))
                foreach (string name in new[] { "GooseGeneration.cs", "GooseDepthPolicy.cs", "GoosePileDepth.cs", "GooseItem.cs", "GooseRules.cs", "GooseGame.cs", "GooseAlgorithmAcceptance.cs", "GooseLevelPolicy.cs" })
                    writer.WriteLine(name + "\t" + BitConverter.ToString(hash.ComputeHash(File.ReadAllBytes(Path.Combine(Application.dataPath, "Scripts", name)))).Replace("-", "").ToLowerInvariant());
            Debug.Log("[GooseAlgorithmQA] Independent runtime player built");
        }
    }
}
