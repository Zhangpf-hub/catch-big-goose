using System;
using UnityEngine;
namespace CatchGoose
{
    // Own mobile profile, not recovered competitor constants.
    public static class GooseRuntimePerformance
    {
        public const string BuildId = "20261026-VISIBILITY1-SHAKE9";
        public static bool Mobile { get; private set; }
        public static int PreferredFrameRate { get; private set; }=60;
        public static void SetHomeVisible(bool home)
        {
            PreferredFrameRate=home||!Mobile?60:30;
            Application.targetFrameRate=PreferredFrameRate;
        }
        public static CollisionDetectionMode DynamicCollision => Mobile ? CollisionDetectionMode.ContinuousSpeculative : CollisionDetectionMode.ContinuousDynamic;
        public static void Configure()
        {
            Mobile = Application.platform == RuntimePlatform.WebGLPlayer || Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseMobileProfile") >= 0;
            SetHomeVisible(true);
            if (!Mobile) return;
            Application.backgroundLoadingPriority=ThreadPriority.Low;
            Time.fixedDeltaTime = 1f / 30;
            Time.maximumDeltaTime = 1f / 15;
            Physics.defaultSolverIterations = 6; Physics.defaultSolverVelocityIterations = 2;
            QualitySettings.shadows = ShadowQuality.Disable; QualitySettings.antiAliasing = 2;
            QualitySettings.pixelLightCount = 1;
        }
    }
}
