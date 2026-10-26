using System;
using UnityEngine;
namespace CatchGoose
{
    // Own mobile profile, not recovered competitor constants.
    public static class GooseRuntimePerformance
    {
        public static bool Mobile { get; private set; }
        public static void Configure()
        {
            Mobile = Application.platform == RuntimePlatform.WebGLPlayer || Array.IndexOf(Environment.GetCommandLineArgs(), "-gooseMobileProfile") >= 0;
            if (!Mobile) return;
            Application.targetFrameRate = 30; Time.fixedDeltaTime = 1f / 60;
            Time.maximumDeltaTime = 1f / 15;
            Physics.defaultSolverIterations = 6; Physics.defaultSolverVelocityIterations = 2;
            QualitySettings.shadows = ShadowQuality.Disable; QualitySettings.antiAliasing = 0;
            QualitySettings.pixelLightCount = 1;
        }
    }
}
