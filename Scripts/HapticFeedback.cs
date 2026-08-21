// Copyright (c) Scott Doxey. All Rights Reserved. Licensed under the MIT License. See LICENSE in the project root for license information.

using UnityEngine;

namespace com.ktgame.haptic_feedback
{

    public static class HapticFeedback
    {
        public static bool IsEnabled = true;

        public static void LightFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("light");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.CONTEXT_CLICK);
#else
            Debug.Log("[Haptic] 📳 Rung NHẸ (Light Feedback)");
#endif

        }

        public static void MediumFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("medium");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.VIRTUAL_KEY);
#else
            Debug.Log("[Haptic] 📳 Rung VỪA (Medium Feedback)");
#endif

        }

        public static void HeavyFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("heavy");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.LONG_PRESS);
#else
            Debug.Log("[Haptic] 📳 Rung MẠNH (Heavy Feedback)");
#endif

        }

        public static void SuccessFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("success");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.CONFIRM);
#else
            Debug.Log("[Haptic] ✅ Rung THÀNH CÔNG (Success Feedback)");
#endif

        }

        public static void WarningFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("warning");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.ENTRY_BUMP);
#else
            Debug.Log("[Haptic] ⚠️ Rung CẢNH BÁO (Warning Feedback)");
#endif

        }

        public static void ErrorFeedback()
        {
            if (!IsEnabled) return;

#if UNITY_IOS && !UNITY_EDITOR
            iOS.iOSHapticsNative.PerformHapticFeedback("error");
#elif UNITY_ANDROID && !UNITY_EDITOR
            Android.AndroidHapticsNative.PerformHapticFeedback(Android.AndroidHapticFeedbackConstants.REJECT);
#else
            Debug.Log("[Haptic] ❌ Rung LỖI (Error Feedback)");
#endif

        }

    }

}
