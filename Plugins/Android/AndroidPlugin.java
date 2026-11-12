// Based on HapticFeedback by Scott Doxey (CandyCoded), MIT License. See THIRD-PARTY-NOTICES.md.
// Modified by ktgame.

package com.ktgame.hapticfeedback;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.Log;
import android.view.HapticFeedbackConstants;
import android.view.View;

public class AndroidPlugin {

    private static final String TAG = "KtHaptic";

    // Must match HapticEffect in AndroidHapticsNative.cs
    public static final int EFFECT_LIGHT = 0;
    public static final int EFFECT_MEDIUM = 1;
    public static final int EFFECT_HEAVY = 2;
    public static final int EFFECT_SUCCESS = 3;
    public static final int EFFECT_WARNING = 4;
    public static final int EFFECT_ERROR = 5;

    private static final long MAX_DURATION_MS = 30000L;

    private final Activity activity;
    private final Vibrator vibrator;

    @SuppressWarnings("deprecation")
    public AndroidPlugin(Context context) {
        this.activity = context instanceof Activity ? (Activity) context : null;
        Vibrator v = null;
        try {
            v = (Vibrator) context.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        } catch (Throwable t) {
            Log.w(TAG, "Cannot get Vibrator: " + t);
        }
        this.vibrator = v;
    }

    public boolean HasVibrator() {
        try {
            return vibrator != null && vibrator.hasVibrator();
        } catch (Throwable t) {
            return false;
        }
    }

    /**
     * Plays a predefined effect through Vibrator: does not depend on the system "touch feedback"
     * setting and does not need the UI thread.
     */
    public void PlayEffect(int effect) {
        if (!HasVibrator()) {
            return;
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                vibrator.vibrate(createEffectQ(effect));
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(createEffectO(effect));
            } else {
                vibrateLegacy(effect);
            }
        } catch (Throwable t) {
            Log.w(TAG, "PlayEffect(" + effect + ") failed: " + t);
        }
    }

    /** Kept for compatibility: View based haptic (depends on the system "touch feedback" setting). */
    @SuppressWarnings("deprecation")
    public void PerformHapticFeedback(final int hapticFeedbackConstant) {
        if (activity == null) {
            return;
        }

        try {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        View view = activity.getWindow().getDecorView().findViewById(android.R.id.content);
                        if (view != null) {
                            view.performHapticFeedback(hapticFeedbackConstant, HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING);
                        }
                    } catch (Throwable t) {
                        Log.w(TAG, "PerformHapticFeedback failed: " + t);
                    }
                }
            });
        } catch (Throwable t) {
            Log.w(TAG, "PerformHapticFeedback failed: " + t);
        }
    }

    /** Custom vibration. milliseconds <= 0 is ignored; amplitude is clamped to 1..255. */
    @SuppressWarnings("deprecation")
    public void Vibrate(long milliseconds, int amplitude) {
        if (milliseconds <= 0 || !HasVibrator()) {
            return;
        }

        long duration = Math.min(milliseconds, MAX_DURATION_MS);
        int clampedAmplitude = Math.max(1, Math.min(255, amplitude));

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(duration, clampedAmplitude));
            } else {
                vibrator.vibrate(duration);
            }
        } catch (Throwable t) {
            Log.w(TAG, "Vibrate failed: " + t);
        }
    }

    private static VibrationEffect createEffectQ(int effect) {
        switch (effect) {
            case EFFECT_LIGHT:
                return VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK);
            case EFFECT_HEAVY:
                return VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK);
            case EFFECT_SUCCESS:
                return VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK);
            case EFFECT_WARNING:
            case EFFECT_ERROR:
                return createEffectO(effect);
            case EFFECT_MEDIUM:
            default:
                return VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK);
        }
    }

    private static VibrationEffect createEffectO(int effect) {
        switch (effect) {
            case EFFECT_LIGHT:
                return VibrationEffect.createOneShot(10, 80);
            case EFFECT_HEAVY:
                return VibrationEffect.createOneShot(30, 255);
            case EFFECT_SUCCESS:
                return VibrationEffect.createWaveform(new long[]{0, 20, 80, 30}, new int[]{0, 150, 0, 255}, -1);
            case EFFECT_WARNING:
                return VibrationEffect.createWaveform(new long[]{0, 40, 100, 40}, new int[]{0, 200, 0, 200}, -1);
            case EFFECT_ERROR:
                return VibrationEffect.createWaveform(new long[]{0, 50, 60, 50, 60, 50}, new int[]{0, 255, 0, 255, 0, 255}, -1);
            case EFFECT_MEDIUM:
            default:
                return VibrationEffect.createOneShot(20, 160);
        }
    }

    @SuppressWarnings("deprecation")
    private void vibrateLegacy(int effect) {
        switch (effect) {
            case EFFECT_LIGHT:
                vibrator.vibrate(10);
                break;
            case EFFECT_HEAVY:
                vibrator.vibrate(30);
                break;
            case EFFECT_SUCCESS:
                vibrator.vibrate(new long[]{0, 20, 80, 30}, -1);
                break;
            case EFFECT_WARNING:
                vibrator.vibrate(new long[]{0, 40, 100, 40}, -1);
                break;
            case EFFECT_ERROR:
                vibrator.vibrate(new long[]{0, 50, 60, 50, 60, 50}, -1);
                break;
            case EFFECT_MEDIUM:
            default:
                vibrator.vibrate(20);
                break;
        }
    }
}
