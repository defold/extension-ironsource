#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)

#pragma once

namespace dmIronSource {


// The same constants/enums are in IronSourceJNI.java
// If you change enums here, pls make sure you update the constants there as well

// enum 
// {
// };

void Initialize_Ext(const char* version);
bool IsIDFASupported();

void Init(const char* appKey);
void OnPause();
void OnResume();
void ValidateIntegration();
void SetConsent(bool isConsentProvided);
void SetMetaData(const char* key, const char* value);
void SetUserId(const char* userId);
void LaunchTestSuite();
void RequestIDFA();
int  GetIDFAStatus();
void SetAdaptersDebug(bool isDebugAdapters);
void LoadConsentView(const char* consentViewType);
void ShowConsentView(const char* consentViewType);

void ShouldTrackNetworkState(bool shouldTrackNetworkState);
bool IsRewardedVideoAvailable();
void ShowRewardedVideo(const char* placementName);
const char* GetRewardedVideoPlacementInfo(const char* placementName);
bool IsRewardedVideoPlacementCapped(const char* placementName);
void SetDynamicUserId(const char* userID);

void LoadInterstitial();
bool IsInterstitialReady();
const char* GetInterstitialPlacementInfo(const char* placementName);
bool IsInterstitialPlacementCapped(const char* placementName);
void ShowInterstitial(const char* placementName);

} //namespace dmIronSource

#endif
