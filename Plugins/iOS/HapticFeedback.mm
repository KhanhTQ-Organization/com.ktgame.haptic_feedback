// Copyright (c) Scott Doxey. All Rights Reserved. Licensed under the MIT License. See LICENSE in the project root for license information.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreHaptics/CoreHaptics.h>

extern "C"
{

    void PerformHapticFeedback(const char* style) {

        const NSString* styleString = [NSString stringWithUTF8String: style];

        if ([styleString isEqualToString:@"success"]) {
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            return;
        } else if ([styleString isEqualToString:@"warning"]) {
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator notificationOccurred:UINotificationFeedbackTypeWarning];
            return;
        } else if ([styleString isEqualToString:@"error"]) {
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator notificationOccurred:UINotificationFeedbackTypeError];
            return;
        }

        UIImpactFeedbackStyle feedbackStyle;

        if ([styleString isEqualToString:@"light"]) {

            feedbackStyle = UIImpactFeedbackStyleLight;

        } else if ([styleString isEqualToString:@"medium"]) {

            feedbackStyle = UIImpactFeedbackStyleMedium;

        } else if ([styleString isEqualToString:@"heavy"]) {

            feedbackStyle = UIImpactFeedbackStyleHeavy;

        } else {

            NSException* exception = [NSException
                                      exceptionWithName:NSInvalidArgumentException
                                      reason:@"Invalid impact feedback style."
                                      userInfo:nil];

            [exception raise];

        }

        UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:feedbackStyle];

        [feedbackGenerator impactOccurred];

    }

    static CHHapticEngine *hapticEngine = nil;

    void PlayCustomHaptic(float duration, float intensity) {
        if (@available(iOS 13.0, *)) {
            if (hapticEngine == nil) {
                NSError *error = nil;
                hapticEngine = [[CHHapticEngine alloc] initAndReturnError:&error];
                if (error) {
                    hapticEngine = nil;
                    return;
                }
                [hapticEngine startAndReturnError:nil];
            }
            
            CHHapticEventParameter *intensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
            CHHapticEventParameter *sharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:1.0];
            
            CHHapticEvent *event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intensityParam, sharpnessParam] relativeTime:0 duration:duration];
            
            NSError *error = nil;
            CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];
            if (!error) {
                id<CHHapticPatternPlayer> player = [hapticEngine createPlayerWithPattern:pattern error:&error];
                if (!error) {
                    [player startAtTime:0 error:nil];
                }
            }
        } else {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [generator impactOccurred];
            }
        }
    }

}
