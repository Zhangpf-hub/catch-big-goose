using System;
using UnityEngine;
namespace CatchGoose
{
    [Serializable] public sealed class GooseInteractionProfile
    {
        public int version=5;
        public bool sceneDressing=false;
        public float gravity=-19.81f,staticFriction=.6f,dynamicFriction=.6f,bounce=0;
        public float shakeCooldown=1.5f,sensorThreshold=1.05f,sensorFilterSeconds=.30f;
        public float maxShakeVelocity=4.5f,maxShakeAngularVelocity=8;
        public int shakePulses=5,shakeMaxBodies=64;
        public float shakePulseInterval=.14f,shakeObserveSeconds=1.35f;
        public float shakeHorizontalSpeed=2.8f,shakeLiftSpeed=2.8f,shakeTurnSpeed=9.0f;
        public float shakeContactFriction=.12f;
        public float shakeForceWindowSeconds=.45f,shakeForceGain=8,shakeHorizontalBudget=2.4f,shakeVerticalBudget=5.4f;
        public float shakeLiftSupportSeconds=.14f;
        public float shrinkSpeed=.5f,lateSurfaceCapacity=5.5f,latePacking=.78f;
        public float rimHeightExponent=2,maxRimScale=4.5f;
        public float lateCameraAngle=84;
        public int lateStartCount=30,lateFullCount=18;
        static GooseInteractionProfile current;
        public static GooseInteractionProfile Current
        {
            get
            {
                if(current==null){var file=Resources.Load<TextAsset>("Data/interaction-r4");current=file?JsonUtility.FromJson<GooseInteractionProfile>(file.text):new GooseInteractionProfile();}
                return current;
            }
        }
    }
}
