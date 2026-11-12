// Based on HapticFeedback by Scott Doxey (CandyCoded), MIT License. See THIRD-PARTY-NOTICES.md.
// Modified by ktgame.

using System.Runtime.InteropServices;

namespace com.ktgame.haptic_feedback.iOS
{
	public static class iOSHapticsNative
	{
		[DllImport("__Internal", EntryPoint = "_ktHapticPerform")]
		public static extern void PerformHapticFeedback(string style = "medium");
		
		[DllImport("__Internal", EntryPoint = "_ktHapticPlayCustom")]
		public static extern void PlayCustomHaptic(float duration, float intensity);
	}
}
