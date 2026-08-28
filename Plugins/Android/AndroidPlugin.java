// Copyright (c) Scott Doxey. All Rights Reserved. Licensed under the MIT License. See LICENSE in the project root for license information.

package com.candycoded.hapticfeedbacklibrary;

import android.app.Activity;
import android.content.Context;
import android.view.HapticFeedbackConstants;
import android.view.View;
import android.os.Vibrator;
import android.os.VibrationEffect;
import android.os.Build;

public class AndroidPlugin {

    private Context context;

    private Activity activity;

    public AndroidPlugin(Context context) {
        this.context = context;
        this.activity = (Activity)context;
    }

    public void PerformHapticFeedback(int hapticFeedbackConstant) {
        View view = activity.getWindow().getDecorView().findViewById(android.R.id.content);
        view.performHapticFeedback(hapticFeedbackConstant, HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING);
    }

    public void Vibrate(long milliseconds, int amplitude) {
        Vibrator vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator != null && vibrator.hasVibrator()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(milliseconds, amplitude));
            } else {
                vibrator.vibrate(milliseconds);
            }
        }
    }

}
