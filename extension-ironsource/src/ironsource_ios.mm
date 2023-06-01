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

@interface IronSourceExtConsentViewDelegate : NSObject<ISConsentViewDelegate>
@end

namespace dmIronSource {

static IronSourceExtInitAdDelegate                  *ironSourceExtInitAdDelegate;
static IronSourceExtLevelPlayRewardedVideoDelegate  *ironSourceExtLevelPlayRewardedVideoDelegate;
static IronSourceExtLevelPlayInterstitialDelegate   *ironSourceExtLevelPlayInterstitialDelegate;
static IronSourceExtConsentViewDelegate             *ironSourceExtConsentViewDelegate;
static UIViewController *uiViewController = nil;

//--------------------------------------------------
// Helpers

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

void AddPlacement(id dict, ISPlacementInfo *placementInfo) {
    if ([placementInfo placementName]) {
        [dict setObject:[placementInfo placementName] forKey:@"placement_name"];
    }
    if ([placementInfo rewardAmount]) {
        [dict setObject:[placementInfo rewardAmount] forKey:@"reward_amount"];
    }
    if ([placementInfo rewardName]) {
        [dict setObject:[placementInfo rewardName] forKey:@"reward_name"];
    }
}

void AddAdInfo(id dict, ISAdInfo *adInfo) {
    if ([adInfo ad_unit]) {
        [dict setObject:[adInfo ad_unit] forKey:@"ad_unit"];
    }
    if ([adInfo auction_id]) {
        [dict setObject:[adInfo auction_id] forKey:@"auction_id"];
    }
    if ([adInfo ad_network]) {
        [dict setObject:[adInfo ad_network] forKey:@"ad_network"];
    }
    if ([adInfo ab]) {
        [dict setObject:[adInfo ab] forKey:@"ab"];
    }
    if ([adInfo country]) {
        [dict setObject:[adInfo country] forKey:@"country"];
    }
    if ([adInfo instance_id]) {
        [dict setObject:[adInfo instance_id] forKey:@"instance_id"];
    }
    if ([adInfo instance_name]) {
        [dict setObject:[adInfo instance_name] forKey:@"instance_name"];
    }
    if ([adInfo segment_name]) {
        [dict setObject:[adInfo segment_name] forKey:@"segment_name"];
    }
    if ([adInfo precision]) {
        [dict setObject:[adInfo precision] forKey:@"precision"];
    }
    if ([adInfo encrypted_cpm]) {
        [dict setObject:[adInfo encrypted_cpm] forKey:@"encrypted_cpm"];
    }
    if ([adInfo revenue]) {
        [dict setObject:[adInfo revenue] forKey:@"revenue"];
    }
    if ([adInfo lifetime_revenue]) {
        [dict setObject:[adInfo lifetime_revenue] forKey:@"lifetime_revenue"];
    }
    if ([adInfo conversion_value]) {
        [dict setObject:[adInfo conversion_value] forKey:@"conversion_value"];
    }
}

void AddError(id dict, NSError *error) {
    if ([error code]) {
        [dict setObject:[NSNumber numberWithInt:[error code]] forKey:@"error_code"];
    }
    if ([error localizedDescription]) {
        [dict setObject:[error localizedDescription] forKey:@"error_message"];
    }
}

void SendSimpleMessage(MessageId msg, MessageEvent event, ISAdInfo *adInfo) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    AddAdInfo(dict, adInfo);
    SendSimpleMessage(msg, dict);
}

void SendSimpleMessage(MessageId msg, MessageEvent event, ISAdInfo *adInfo, ISPlacementInfo *placementInfo) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    AddAdInfo(dict, adInfo);
    AddPlacement(dict, placementInfo);
    SendSimpleMessage(msg, dict);
}

void SendSimpleMessage(MessageId msg, MessageEvent event, ISAdInfo *adInfo, NSError *error) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    AddAdInfo(dict, adInfo);
    AddError(dict, error);
    SendSimpleMessage(msg, dict);
}

void SendSimpleMessage(MessageId msg, MessageEvent event, NSError *error) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    AddError(dict, error);
    SendSimpleMessage(msg, dict);
}

 void SendSimpleMessage(MessageId msg, MessageEvent event, NSString *key_2, NSString *value_2) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    [dict setObject:value_2 forKey:key_2];
    SendSimpleMessage(msg, dict);
}

void SendSimpleMessage(MessageId msg, MessageEvent event, NSString *key_2, NSString *value_2, NSError *error) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    [dict setObject:value_2 forKey:key_2];
    AddError(dict, error);
    SendSimpleMessage(msg, dict);
}

const char* GetDictAsJSON(NSMutableDictionary *dict) {
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:(NSJSONWritingOptions)0 error:&error];
    if (jsonData)
    {
        NSString* nsstring = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *nsstring_lua = [nsstring UTF8String];
        [nsstring release];
        return nsstring_lua;
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
            const char *nsstringError_lua = [nsstringError UTF8String];
            [nsstringError release];
            return nsstringError_lua;
        }
        else
        {
            return [[NSString stringWithFormat:@"{ \"error\": \"Error while converting simple message to JSON.\", \"event\": %d }", EVENT_JSON_ERROR] UTF8String];
        }
    }
}

NSString* GetNSStringOrNULL(const char* str) {
    return str ? [NSString stringWithUTF8String:str] : NULL;
}

//--------------------------------------------------
// Main functions

void Initialize_Ext() {
    UIWindow* window = dmGraphics::GetNativeiOSUIWindow();
    uiViewController = window.rootViewController;

    ironSourceExtInitAdDelegate = [[IronSourceExtInitAdDelegate alloc] init];
    ironSourceExtLevelPlayRewardedVideoDelegate =[[IronSourceExtLevelPlayRewardedVideoDelegate alloc] init];
    [IronSource setLevelPlayRewardedVideoDelegate:ironSourceExtLevelPlayRewardedVideoDelegate];
    ironSourceExtLevelPlayInterstitialDelegate = [[IronSourceExtLevelPlayInterstitialDelegate alloc] init];
    [IronSource setLevelPlayInterstitialDelegate:ironSourceExtLevelPlayInterstitialDelegate];
    ironSourceExtConsentViewDelegate = [[IronSourceExtConsentViewDelegate alloc] init];
    [IronSource setConsentViewWithDelegate:ironSourceExtConsentViewDelegate];
}

void Init(const char* appKey) {
    [IronSource initWithAppKey:[NSString stringWithUTF8String:appKey] delegate:ironSourceExtInitAdDelegate];
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

void LoadConsentView(const char* consentViewType) {
    [IronSource loadConsentViewWithType:[NSString stringWithUTF8String:consentViewType]];
}

void ShowConsentView(const char* consentViewType) {
    [IronSource showConsentViewWithViewController:uiViewController andType:[NSString stringWithUTF8String:consentViewType]];
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
    [IronSource showRewardedVideoWithViewController:uiViewController placement:GetNSStringOrNULL(placementName)];
}

const char* GetRewardedVideoPlacementInfo(const char* placementName) {
    ISPlacementInfo *placementInfo = [IronSource rewardedVideoPlacementInfo:GetNSStringOrNULL(placementName)];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    AddPlacement(dict, placementInfo);

    const char *json_lua = GetDictAsJSON(dict);
    return json_lua;
}

bool IsRewardedVideoPlacementCapped(const char* placementName) {
    return [IronSource isRewardedVideoCappedForPlacement:GetNSStringOrNULL(placementName)] == YES;
}

void SetDynamicUserId(const char* userID) {
    [IronSource setDynamicUserId:[NSString stringWithUTF8String:userID]];
}

//--------------------------------------------------
// Interstitial ADS

void LoadInterstitial() {
    [IronSource loadInterstitial];
}

bool IsInterstitialReady() {
    return [IronSource hasInterstitial] == YES;
}

const char* GetInterstitialPlacementInfo(const char* placementName) {
    // this method isn't implemented in IronSource SDK
    return NULL;
}

bool IsInterstitialPlacementCapped(const char* placementName) {
    return [IronSource isInterstitialCappedForPlacement: GetNSStringOrNULL(placementName)] == YES;
}

void ShowInterstitial(const char* placementName) {
    [IronSource showInterstitialWithViewController:uiViewController placement:GetNSStringOrNULL(placementName)];
}

} //namespace

@implementation IronSourceExtInitAdDelegate

- (void)initializationDidComplete {
    // ironSource SDK is initialized
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INIT, dmIronSource::EVENT_INIT_COMPLETE);
}

@end

@implementation IronSourceExtLevelPlayRewardedVideoDelegate
/**
 Called after a rewarded video has changed its availability to true.
 @param adInfo The info of the ad.
 Replaces the delegate rewardedVideoHasChangedAvailability:(true)available 
 */
- (void)hasAdAvailableWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_AVAILABLE, adInfo);
}
/**
 Called after a rewarded video has changed its availability to false.
 Replaces the delegate rewardedVideoHasChangedAvailability:(false)available 
 */
- (void)hasNoAvailableAd {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_UNAVAILABLE);
}
/**
 Called after a rewarded video has been viewed completely and the user is eligible for a reward.
 @param placementInfo An object that contains the placement's reward name and amount.
 @param adInfo The info of the ad.
 */
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_REWARDED, adInfo, placementInfo);
}
/**
 Called after a rewarded video has attempted to show but failed.
 @param error The reason for the error
 @param adInfo The info of the ad.
 */
- (void)didFailToShowWithError:(NSError *)error andAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_SHOW_FAILED, adInfo, error);
}
/**
 Called after a rewarded video has been opened.
 @param adInfo The info of the ad.
 */
- (void)didOpenWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_OPENED, adInfo);
}
/**
 Called after a rewarded video has been dismissed.
 @param adInfo The info of the ad.
 */
- (void)didCloseWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_CLOSED, adInfo);
}
/**
 Called after a rewarded video has been clicked. 
 This callback is not supported by all networks, and we recommend using it 
 only if it's supported by all networks you included in your build
 @param adInfo The info of the ad.
 */
- (void)didClick:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_REWARDED, dmIronSource::EVENT_AD_CLICKED, adInfo, placementInfo);
}
@end

@implementation IronSourceExtLevelPlayInterstitialDelegate
/**
 Called after an interstitial has been loaded
 @param adInfo The info of the ad.
 */
- (void)didLoadWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_READY, adInfo);
}
/**
 Called after an interstitial has attempted to load but failed.
 @param error The reason for the error
 */
- (void)didFailToLoadWithError:(NSError *)error {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_LOAD_FAILED, error);
}
/**
 Called after an interstitial has been opened. 
 This is the indication for impression. 
 @param adInfo The info of the ad.
 */
- (void)didOpenWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_OPENED, adInfo);
}
/**
 Called after an interstitial has been dismissed.
 @param adInfo The info of the ad.
 */
- (void)didCloseWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_CLOSED, adInfo);
}
/**
 Called after an interstitial has attempted to show but failed.
 @param error The reason for the error
 @param adInfo The info of the ad.
 */
- (void)didFailToShowWithError:(NSError *)error andAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_SHOW_FAILED, adInfo, error);

}
/**
 Called after an interstitial has been clicked.
 @param adInfo The info of the ad.
 */
- (void)didClickWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_CLICKED, adInfo);
}
/**
 Called after an interstitial has been displayed on the screen.
 This callback is not supported by all networks, and we recommend using it 
 only if it's supported by all networks you included in your build. 
 @param adInfo The info of the ad.
 */
- (void)didShowWithAdInfo:(ISAdInfo *)adInfo {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_INTERSTITIAL, dmIronSource::EVENT_AD_SHOW_SUCCEEDED, adInfo);
}
@end

@implementation IronSourceExtConsentViewDelegate
// Consent View was loaded successfully
- (void)consentViewDidLoadSuccess:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_LOADED, @"consent_view_type", consentViewType);
}

// Consent view was failed to load
- (void)consentViewDidFailToLoadWithError:(NSError *)error consentViewType:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_LOAD_FAILED, @"consent_view_type", consentViewType, error);
}

// Consent view was displayed successfully 
- (void)consentViewDidShowSuccess:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_SHOWN, @"consent_view_type", consentViewType);
}

// Consent view was not displayed, due to error
- (void)consentViewDidFailToShowWithError:(NSError *)error consentViewType:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_SHOW_FAILED, @"consent_view_type", consentViewType, error);
}
// The user pressed the Settings or Next buttons
- (void)consentViewDidAccept:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_ACCEPTED, @"consent_view_type", consentViewType);
}

- (void)consentViewDidDismiss:(NSString *)consentViewType {
    dmIronSource::SendSimpleMessage(dmIronSource::MSG_CONSENT, dmIronSource::EVENT_CONSENT_DISMISSED, @"consent_view_type", consentViewType);
}

@end

#endif
