#if defined(DM_PLATFORM_IOS)
#include "ironsource_private.h"
#include "ironsource_callback_private.h"

#include <UIKit/UIKit.h>
#import "IronSource/IronSource.h"

@interface IronSourceExtInitAdDelegate : NSObject<ISInitializationDelegate>
@end

@interface IronSourceExtLevelPlayRewardedVideoDelegate : NSObject<LevelPlayRewardedVideoDelegate>
@end

@interface IronSourceExtLevelPlayInterstitialDelegate : NSObject<LevelPlayInterstitialDelegate>
@end

namespace dmIronSource {

static IronSourceExtInitAdDelegate                  *ironSourceExtInitAdDelegate;
static IronSourceExtLevelPlayRewardedVideoDelegate  *ironSourceExtLevelPlayRewardedVideoDelegate;
static IronSourceExtLevelPlayInterstitialDelegate   *ironSourceExtLevelPlayInterstitialDelegate;
static UIViewController *uiViewController = nil;

void SendSimpleMessage(MessageId msg, id obj) {
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:obj options:(NSJSONWritingOptions)0 error:&error];
    if (jsonData)
    {
        NSString* nsstring = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        AddToQueueCallback(msg, (const char*)[nsstring UTF8String]);
        [nsstring release];
    }
    else
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:error.localizedDescription forKey:@"error"];
        [dict setObject:[NSNumber numberWithInt:EVENT_JSON_ERROR] forKey:@"event"];
        NSError* error2;
        NSData* errorJsonData = [NSJSONSerialization dataWithJSONObject:dict options:(NSJSONWritingOptions)0 error:&error2];
        if (errorJsonData)
        {
            NSString* nsstringError = [[NSString alloc] initWithData:errorJsonData encoding:NSUTF8StringEncoding];
            AddToQueueCallback(msg, (const char*)[nsstringError UTF8String]);
            [nsstringError release];
        }
        else
        {
            AddToQueueCallback(msg, [[NSString stringWithFormat:@"{ \"error\": \"Error while converting simple message to JSON.\", \"event\": %d }", EVENT_JSON_ERROR] UTF8String]);
        }
    }
}

void SendSimpleMessage(MessageId msg, MessageEvent event) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    SendSimpleMessage(msg, dict);
}

void Initialize_Ext() {
    UIWindow* window = dmGraphics::GetNativeiOSUIWindow();
    uiViewController = window.rootViewController;

    ironSourceExtInitAdDelegate = [[IronSourceExtInitAdDelegate alloc] init];
    ironSourceExtLevelPlayRewardedVideoDelegate =[[IronSourceExtLevelPlayRewardedVideoDelegate alloc] init];
    [IronSource setLevelPlayRewardedVideoDelegate:ironSourceExtLevelPlayRewardedVideoDelegate];
    ironSourceExtLevelPlayInterstitialDelegate = [[IronSourceExtLevelPlayInterstitialDelegate alloc] init];
    [IronSource setLevelPlayInterstitialDelegate:ironSourceExtLevelPlayInterstitialDelegate];
}

void Init(const char* appKey) {
    [IronSource initWithAppKey:[NSString stringWithUTF8String:appKey]];
}

void OnPause() {
    // no-op
}

void OnResume() {
    // no-op
}

void ValidateIntegration() {
    [ISIntegrationHelper validateIntegration];
}

void SetConsent(bool isConsentProvided) {
    [IronSource setConsent:isConsentProvided ? YES : NO];
}

void SetMetaData(const char* key, const char* value) {
    [IronSource setMetaDataWithKey:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
}

void SetUserId(const char* userId) {
    [IronSource setUserId:[NSString stringWithUTF8String:userId]];
}

void LaunchTestSuite() {
    [IronSource launchTestSuite:uiViewController];
}

void SetAdaptersDebug(bool isDebugAdapters) {
    [IronSource setAdaptersDebug:isDebugAdapters ? YES : NO];
}

//--------------------------------------------------
// Rewarded ADS

void ShouldTrackNetworkState(bool shouldTrackNetworkState) {
    [IronSource shouldTrackReachability:shouldTrackNetworkState ? YES : NO];
}

bool IsRewardedVideoAvailable() {
    return [IronSource hasRewardedVideo] == YES;
}

void ShowRewardedVideo(const char* placementName) {

}

const char* GetRewardedVideoPlacementInfo(const char* placementName) {

}

bool IsRewardedVideoPlacementCapped(const char* placementName) {
    return [IronSource isRewardedVideoCappedForPlacement:[NSString stringWithUTF8String:placementName]] == YES;
}

void SetDynamicUserId(const char* userID) {
    [IronSource setDynamicUserId:[NSString stringWithUTF8String:userID]];
}

//--------------------------------------------------
// Interstitial ADS

void LoadInterstitial() {

}

bool IsInterstitialReady() {
    return [IronSource hasInterstitial] == YES;
}

const char* GetInterstitialPlacementInfo(const char* placementName) {

}

bool IsInterstitialPlacementCapped(const char* placementName) {
    return [IronSource isInterstitialCappedForPlacement:[NSString stringWithUTF8String:placementName]] == YES;
}

void ShowInterstitial(const char* placementName) {

}

} //namespace

@implementation IronSourceExtInitAdDelegate

- (void)initializationDidComplete {
    // ironSource SDK is initialized
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INIT, dmIronSource::EVENT_INIT_COMPLETE);
}

@end

@implementation IronSourceExtLevelPlayRewardedVideoDelegate

@end

@implementation IronSourceExtLevelPlayInterstitialDelegate

@end

#endif
