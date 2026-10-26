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
        {
            GooseProjectSetup.Prepare();
            const string target = "Builds/AlgorithmQA/CatchGooseAlgorithmQA.exe";
            var result = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
                scenes = new[] { "Assets/Scenes/Main.unity" }, locationPathName = target,
                target = BuildTarget.StandaloneWindows64, options = BuildOptions.Development
            });
            if (result.summary.result != BuildResult.Succeeded) throw new Exception("Algorithm QA player build failed");
            string project = Directory.GetParent(Application.dataPath).FullName;
            using (var hash = SHA256.Create())
            using (var writer = new StreamWriter(Path.Combine(project, "Builds/AlgorithmQA/source-hashes.tsv")))
                foreach (string name in new[] { "GooseGeneration.cs", "GooseDepthPolicy.cs", "GoosePileDepth.cs", "GooseItem.cs", "GooseRules.cs", "GooseGame.cs", "GooseAlgorithmAcceptance.cs" })
                    writer.WriteLine(name + "\t" + BitConverter.ToString(hash.ComputeHash(File.ReadAllBytes(Path.Combine(Application.dataPath, "Scripts", name)))).Replace("-", "").ToLowerInvariant());
            Debug.Log("[GooseAlgorithmQA] Independent runtime player built");
        }
    }
}
