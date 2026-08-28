// Copyright (c) Scott Doxey. All Rights Reserved. Licensed under the MIT License. See LICENSE in the project root for license information.

using UnityEngine;

namespace com.ktgame.haptic_feedback
{

    public class HapticFeedbackController : MonoBehaviour
    {

        public void LightFeedback()
        {
            HapticFeedback.LightFeedback();
        }

        public void MediumFeedback()
        {
            HapticFeedback.MediumFeedback();
        }

        public void HeavyFeedback()
        {
            HapticFeedback.HeavyFeedback();
        }

        public void SuccessFeedback()
        {
            HapticFeedback.SuccessFeedback();
        }

        public void WarningFeedback()
        {
            HapticFeedback.WarningFeedback();
        }

        public void ErrorFeedback()
        {
            HapticFeedback.ErrorFeedback();
        }

        public void CustomFeedback(float durationSeconds, float intensity0to1)
        {
            HapticFeedback.CustomFeedback(durationSeconds, intensity0to1);
        }

    }

}
