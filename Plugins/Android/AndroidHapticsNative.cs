// Based on HapticFeedback by Scott Doxey (CandyCoded), MIT License. See THIRD-PARTY-NOTICES.md.
// Modified by ktgame.

using System;
using UnityEngine;

namespace com.ktgame.haptic_feedback.Android
{
	public enum AndroidHapticFeedbackConstants
	{
		LONG_PRESS = 0,
		VIRTUAL_KEY = 1,
		KEYBOARD_TAP = 3,
		CLOCK_TICK = 4,
		CALENDAR_DATE = 5,
		CONTEXT_CLICK = 6,
		KEYBOARD_PRESS = KEYBOARD_TAP,
		KEYBOARD_RELEASE = 7,
		VIRTUAL_KEY_RELEASE = 8,
		TEXT_HANDLE_MOVE = 9,
		ENTRY_BUMP = 10,
		DRAG_CROSSING = 11,
		GESTURE_START = 12,
		GESTURE_END = 13,
		EDGE_SQUEEZE = 14,
		EDGE_RELEASE = 15,
		CONFIRM = 16,
		REJECT = 17
	}
	
	public enum AndroidHapticEffect
	{
		Light = 0,
		Medium = 1,
		Heavy = 2,
		Success = 3,
		Warning = 4,
		Error = 5
	}

	public static class AndroidHapticsNative
	{
		private const string PluginClass = "com.ktgame.hapticfeedback.AndroidPlugin";

		private static AndroidJavaObject _androidPlugin;
		private static bool _unavailable;
		
		private static AndroidJavaObject AndroidPlugin
		{
			get
			{
				if (_androidPlugin != null || _unavailable)
				{
					return _androidPlugin;
				}

				try
				{
					using (var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
					using (var currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
					{
						_androidPlugin = new AndroidJavaObject(PluginClass, currentActivity);
					}
				}
				catch (Exception e)
				{
					_unavailable = true;
					Debug.LogWarning($"[HapticFeedback] Android plugin unavailable: {e.Message}");
				}

				return _androidPlugin;
			}
		}
		
		public static bool HasVibrator()
		{
			try
			{
				var plugin = AndroidPlugin;
				return plugin != null && plugin.Call<bool>("HasVibrator");
			}
			catch (Exception e)
			{
				Debug.LogWarning($"[HapticFeedback] HasVibrator failed: {e.Message}");
				return false;
			}
		}
		
		public static void PlayEffect(AndroidHapticEffect effect)
		{
			Invoke("PlayEffect", (int)effect);
		}
		
		public static void PerformHapticFeedback(AndroidHapticFeedbackConstants hapticFeedbackConstants)
		{
			Invoke("PerformHapticFeedback", (int)hapticFeedbackConstants);
		}
		
		public static void Vibrate(long milliseconds, int amplitude)
		{
			if (milliseconds <= 0)
			{
				return;
			}

			Invoke("Vibrate", milliseconds, amplitude);
		}

		private static void Invoke(string method, params object[] args)
		{
			try
			{
				AndroidPlugin?.Call(method, args);
			}
			catch (Exception e)
			{
				Debug.LogWarning($"[HapticFeedback] {method} failed: {e.Message}");
			}
		}
	}
}
