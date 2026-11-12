// Based on HapticFeedback by Scott Doxey (CandyCoded), MIT License. See THIRD-PARTY-NOTICES.md.
// Modified by ktgame.

using System;
using UnityEngine;

namespace com.ktgame.haptic_feedback
{
	public static class HapticFeedback
	{
		public static bool IsEnabled = true;
		
		public static bool LogInEditor = false;

		private enum HapticType
		{
			Light = 0,
			Medium = 1,
			Heavy = 2,
			Success = 3,
			Warning = 4,
			Error = 5
		}

		private static bool? _isSupported;
		
		public static bool IsSupported
		{
			get
			{
				if (_isSupported.HasValue)
				{
					return _isSupported.Value;
				}

#if UNITY_ANDROID && !UNITY_EDITOR
				_isSupported = Android.AndroidHapticsNative.HasVibrator();
#elif UNITY_IOS && !UNITY_EDITOR
				_isSupported = SystemInfo.supportsVibration;
#else
				_isSupported = false;
#endif
				return _isSupported.Value;
			}
		}

		public static void LightFeedback()
		{
			Play(HapticType.Light);
		}

		public static void MediumFeedback()
		{
			Play(HapticType.Medium);
		}

		public static void HeavyFeedback()
		{
			Play(HapticType.Heavy);
		}

		public static void SuccessFeedback()
		{
			Play(HapticType.Success);
		}

		public static void WarningFeedback()
		{
			Play(HapticType.Warning);
		}

		public static void ErrorFeedback()
		{
			Play(HapticType.Error);
		}
		
		public static void CustomFeedback(float durationSeconds, float intensity0to1)
		{
			if (!IsEnabled || float.IsNaN(durationSeconds) || durationSeconds <= 0f)
			{
				return;
			}

			var intensity = Mathf.Clamp01(intensity0to1);

#if UNITY_IOS && !UNITY_EDITOR
			SafeNative(() => iOS.iOSHapticsNative.PlayCustomHaptic(durationSeconds, intensity));
#elif UNITY_ANDROID && !UNITY_EDITOR
			var milliseconds = (long)(durationSeconds * 1000f);
			var amplitude = (int)Mathf.Clamp(intensity * 255f, 1f, 255f);
			Android.AndroidHapticsNative.Vibrate(milliseconds, amplitude);
#else
			LogEditor($"Custom ({durationSeconds}s, intensity {intensity})");
#endif
		}
		
		public static void CustomFeedback(long milliseconds, int amplitude)
		{
			if (!IsEnabled || milliseconds <= 0)
			{
				return;
			}

			var clampedAmplitude = Mathf.Clamp(amplitude, 1, 255);

#if UNITY_IOS && !UNITY_EDITOR
			SafeNative(() => iOS.iOSHapticsNative.PlayCustomHaptic(milliseconds / 1000f, clampedAmplitude / 255f));
#elif UNITY_ANDROID && !UNITY_EDITOR
			Android.AndroidHapticsNative.Vibrate(milliseconds, clampedAmplitude);
#else
			LogEditor($"Custom ({milliseconds}ms, amplitude {clampedAmplitude})");
#endif
		}

		private static void Play(HapticType type)
		{
			if (!IsEnabled)
			{
				return;
			}

#if UNITY_IOS && !UNITY_EDITOR
			SafeNative(() => iOS.iOSHapticsNative.PerformHapticFeedback(ToIOSStyle(type)));
#elif UNITY_ANDROID && !UNITY_EDITOR
			Android.AndroidHapticsNative.PlayEffect((Android.AndroidHapticEffect)(int)type);
#else
			LogEditor(type.ToString());
#endif
		}

#if UNITY_IOS && !UNITY_EDITOR
		private static string ToIOSStyle(HapticType type)
		{
			switch (type)
			{
				case HapticType.Light: return "light";
				case HapticType.Heavy: return "heavy";
				case HapticType.Success: return "success";
				case HapticType.Warning: return "warning";
				case HapticType.Error: return "error";
				default: return "medium";
			}
		}

		private static bool _nativeFailed;

		private static void SafeNative(Action action)
		{
			if (_nativeFailed)
			{
				return;
			}

			try
			{
				action();
			}
			catch (Exception e)
			{
				_nativeFailed = true;
				Debug.LogWarning($"[HapticFeedback] iOS native call failed, haptics disabled: {e.Message}");
			}
		}
#endif

		[System.Diagnostics.Conditional("UNITY_EDITOR")]
		private static void LogEditor(string message)
		{
			if (LogInEditor)
			{
				Debug.Log($"[HapticFeedback] {message}");
			}
		}
	}
}
