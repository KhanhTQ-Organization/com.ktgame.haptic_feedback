// Copyright (c) Scott Doxey. All Rights Reserved. Licensed under the MIT License. See LICENSE in the project root for license information.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

}
