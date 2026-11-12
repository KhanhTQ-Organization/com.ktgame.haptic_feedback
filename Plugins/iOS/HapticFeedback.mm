// Based on HapticFeedback by Scott Doxey (CandyCoded), MIT License. See THIRD-PARTY-NOTICES.md.
// Modified by ktgame. Compiled with ARC (-fobjc-arc, set in the plugin importer).

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreHaptics/CoreHaptics.h>

// Cached generators: avoid allocation per call and keep the Taptic Engine prepared (lower latency).
static UIImpactFeedbackGenerator *ktLightGenerator = nil;
static UIImpactFeedbackGenerator *ktMediumGenerator = nil;
static UIImpactFeedbackGenerator *ktHeavyGenerator = nil;
static UINotificationFeedbackGenerator *ktNotificationGenerator = nil;

// CHHapticEngine (iOS 13+), typed as id to keep it usable without availability warnings.
static id ktHapticEngine = nil;
static BOOL ktHapticEngineUnsupported = NO;

static void KtRunOnMainThread(void (^block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static UIImpactFeedbackGenerator *KtImpactGenerator(UIImpactFeedbackStyle style)
{
    switch (style) {
        case UIImpactFeedbackStyleLight:
            if (ktLightGenerator == nil) ktLightGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            return ktLightGenerator;
        case UIImpactFeedbackStyleHeavy:
            if (ktHeavyGenerator == nil) ktHeavyGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            return ktHeavyGenerator;
        default:
            if (ktMediumGenerator == nil) ktMediumGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            return ktMediumGenerator;
    }
}

static void KtImpact(UIImpactFeedbackStyle style)
{
    UIImpactFeedbackGenerator *generator = KtImpactGenerator(style);
    [generator impactOccurred];
    [generator prepare];
}

static void KtNotification(UINotificationFeedbackType type)
{
    if (ktNotificationGenerator == nil) ktNotificationGenerator = [[UINotificationFeedbackGenerator alloc] init];
    [ktNotificationGenerator notificationOccurred:type];
    [ktNotificationGenerator prepare];
}

static void KtPerform(NSString *style)
{
    if ([style isEqualToString:@"success"]) {
        KtNotification(UINotificationFeedbackTypeSuccess);
    } else if ([style isEqualToString:@"warning"]) {
        KtNotification(UINotificationFeedbackTypeWarning);
    } else if ([style isEqualToString:@"error"]) {
        KtNotification(UINotificationFeedbackTypeError);
    } else if ([style isEqualToString:@"light"]) {
        KtImpact(UIImpactFeedbackStyleLight);
    } else if ([style isEqualToString:@"heavy"]) {
        KtImpact(UIImpactFeedbackStyleHeavy);
    } else {
        // "medium" and any unknown style: never throw (an NSException here would crash the app).
        KtImpact(UIImpactFeedbackStyleMedium);
    }
}

API_AVAILABLE(ios(13.0))
static CHHapticEngine *KtStartedEngine(void)
{
    if (ktHapticEngineUnsupported) {
        return nil;
    }

    if (ktHapticEngine == nil) {
        if (![CHHapticEngine capabilitiesForHardware].supportsHaptics) {
            ktHapticEngineUnsupported = YES;
            return nil;
        }

        NSError *error = nil;
        CHHapticEngine *engine = [[CHHapticEngine alloc] initAndReturnError:&error];
        if (engine == nil || error != nil) {
            NSLog(@"[HapticFeedback] Cannot create CHHapticEngine: %@", error);
            ktHapticEngineUnsupported = YES;
            return nil;
        }

        engine.playsHapticsOnly = YES;
        // The engine is stopped by the system (background, audio interruption...) and may be reset:
        // it is restarted before every play below, so the handlers only need to log / restart.
        engine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
            NSLog(@"[HapticFeedback] CHHapticEngine stopped: %ld", (long)reason);
        };
        engine.resetHandler = ^{
            NSError *restartError = nil;
            [(CHHapticEngine *)ktHapticEngine startAndReturnError:&restartError];
        };
        ktHapticEngine = engine;
    }

    CHHapticEngine *engine = (CHHapticEngine *)ktHapticEngine;
    NSError *startError = nil;
    if (![engine startAndReturnError:&startError]) {
        NSLog(@"[HapticFeedback] Cannot start CHHapticEngine: %@", startError);
        return nil;
    }

    return engine;
}

static void KtImpactFallback(float intensity)
{
    if (intensity < 0.34f) {
        KtImpact(UIImpactFeedbackStyleLight);
    } else if (intensity < 0.67f) {
        KtImpact(UIImpactFeedbackStyleMedium);
    } else {
        KtImpact(UIImpactFeedbackStyleHeavy);
    }
}

static void KtPlayCustom(float duration, float intensity)
{
    if (!(duration > 0.0f)) {
        return;
    }

    if (duration > 30.0f) duration = 30.0f;
    if (intensity < 0.0f) intensity = 0.0f;
    if (intensity > 1.0f) intensity = 1.0f;

    if (@available(iOS 13.0, *)) {
        CHHapticEngine *engine = KtStartedEngine();
        if (engine == nil) {
            KtImpactFallback(intensity);
            return;
        }

        CHHapticEventParameter *intensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
        CHHapticEventParameter *sharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:1.0f];
        CHHapticEvent *event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous
                                                             parameters:@[intensityParam, sharpnessParam]
                                                           relativeTime:0
                                                               duration:duration];

        NSError *error = nil;
        CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];
        if (pattern == nil || error != nil) {
            NSLog(@"[HapticFeedback] Cannot create pattern: %@", error);
            return;
        }

        id<CHHapticPatternPlayer> player = [engine createPlayerWithPattern:pattern error:&error];
        if (player == nil || error != nil) {
            NSLog(@"[HapticFeedback] Cannot create player: %@", error);
            return;
        }

        if (![player startAtTime:CHHapticTimeImmediate error:&error]) {
            NSLog(@"[HapticFeedback] Cannot start player: %@", error);
        }
    } else {
        KtImpactFallback(intensity);
    }
}

extern "C"
{
    // Symbol names are prefixed to avoid duplicate symbols with other haptic plugins.

    void _ktHapticPerform(const char *style)
    {
        NSString *styleString = style != NULL ? [NSString stringWithUTF8String:style] : nil;
        if (styleString == nil) {
            styleString = @"medium";
        }

        KtRunOnMainThread(^{
            KtPerform(styleString);
        });
    }

    void _ktHapticPlayCustom(float duration, float intensity)
    {
        KtRunOnMainThread(^{
            KtPlayCustom(duration, intensity);
        });
    }
}
