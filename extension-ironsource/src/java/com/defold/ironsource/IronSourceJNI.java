package com.defold.ironsource;

import androidx.annotation.NonNull;
import android.util.Log;
import android.util.DisplayMetrics;
import android.app.Activity;
import android.view.Display;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewGroup.MarginLayoutParams;
import android.content.Context;
import android.content.SharedPreferences;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import com.ironsource.mediationsdk.IronSource;
import com.ironsource.mediationsdk.integration.IntegrationHelper;
import com.ironsource.mediationsdk.sdk.LevelPlayRewardedVideoListener;
import com.ironsource.mediationsdk.adunit.adapter.utility.AdInfo;
import com.ironsource.mediationsdk.model.Placement;
import com.ironsource.mediationsdk.logger.IronSourceError;
import com.ironsource.mediationsdk.sdk.LevelPlayInterstitialListener;
import com.ironsource.mediationsdk.sdk.InitializationListener;
import com.ironsource.mediationsdk.model.InterstitialPlacement;

public class IronSourceJNI {

    private static final String TAG = "IronSourceJNI";

    public static native void ironSourceAddToQueue(int msg, String json);

    // duplicate of enums from ironsource_callback_private.h:
    // CONSTANTS:
    private static final int MSG_INTERSTITIAL =             1;
    private static final int MSG_REWARDED =                 2;
    private static final int MSG_INIT =                     4;

    private static final int EVENT_AD_AVAILABLE =           1;
    private static final int EVENT_AD_UNAVAILABLE =         2;
    private static final int EVENT_AD_OPENED =              3;
    private static final int EVENT_AD_CLOSED =              4;
    private static final int EVENT_AD_REWARDED =            5;
    private static final int EVENT_AD_CLICKED =             6;
    private static final int EVENT_AD_SHOW_FAILED =         7;
    private static final int EVENT_AD_READY =               8;
    private static final int EVENT_AD_SHOW_SUCCEEDED =      9;
    private static final int EVENT_AD_LOAD_FAILED =         10;
    private static final int EVENT_JSON_ERROR =             11;
    private static final int EVENT_INIT_COMPLETE =          12;

    // END CONSTANTS

    private Activity activity;

    public IronSourceJNI(Activity activity) {
            this.activity = activity;
    }

    public void init(String appKey) {
        IronSource.setLevelPlayRewardedVideoListener(new DefoldLevelPlayRewardedVideoListener());
        IronSource.setLevelPlayInterstitialListener(new DefoldLevelPlayInterstitialListener());
        IronSource.init(activity, appKey, new InitializationListener() { 
            @Override public void onInitializationComplete() {
                sendSimpleMessage(MSG_INIT, EVENT_INIT_COMPLETE);
            } 
        });
    }

    public void validateIntegration() {
        IntegrationHelper.validateIntegration(activity);
    }

    public void setConsent(boolean isConsentProvided) {
        IronSource.setConsent(isConsentProvided);
    }

    public void setMetaData(String key, String value) {
        IronSource.setMetaData(key, value);
    }

    public void setUserId(String userId) {
        IronSource.setUserId(userId);
    }

    public void launchTestSuite() {
        IronSource.launchTestSuite(activity.getApplicationContext());
    }

//--------------------------------------------------
// Lifecycle

    public void onResume() {
        IronSource.onResume(activity);
    }

    public void onPause() {
        IronSource.onPause(activity);
    }

//--------------------------------------------------
// Rewarded ADS

    public void shouldTrackNetworkState(boolean shouldTrackNetworkState) {
        IronSource.shouldTrackNetworkState(activity, shouldTrackNetworkState);
    }

    public boolean isRewardedVideoAvailable() {
        return IronSource.isRewardedVideoAvailable();
    }

    public void showRewardedVideo(final String placementName) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                IronSource.showRewardedVideo(placementName);
            }
        });
    }

    public String getRewardedVideoPlacementInfo(String placementName) {
        Placement placement = IronSource.getRewardedVideoPlacementInfo(placementName);
            // Null can be returned instead of a placement if the placementName is not valid.
            if (placement == null) {
                return null;
            }
            String message;
            try {
                JSONObject obj = new JSONObject();
                addPlacement(obj, placement);
                message = obj.toString();
            } catch (JSONException e) {
                message = getJsonConversionErrorMessage(e.getLocalizedMessage());
            }
            return message;
    }

    public boolean isRewardedVideoPlacementCapped(String placementName) {
        return IronSource.isRewardedVideoPlacementCapped(placementName);
    }

    public boolean setDynamicUserId(String userID) {
        return IronSource.setDynamicUserId(userID);
    }

    private class DefoldLevelPlayRewardedVideoListener implements LevelPlayRewardedVideoListener {
        // Indicates that there's an available ad. 
        // The adInfo object includes information about the ad that was loaded successfully
        // Use this callback instead of onRewardedVideoAvailabilityChanged(true)
        @Override
        public void onAdAvailable(AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_AVAILABLE, adInfo);
        }
        // Indicates that no ads are available to be displayed 
        // Use this callback instead of onRewardedVideoAvailabilityChanged(false) 
        @Override
        public void onAdUnavailable() {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_UNAVAILABLE);
        }
        // The Rewarded Video ad view has opened. Your activity will loose focus
        @Override
        public void onAdOpened(AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_OPENED, adInfo);
        }
        // The Rewarded Video ad view is about to be closed. Your activity will regain its focus
        @Override
        public void onAdClosed(AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_CLOSED, adInfo);
        }
        // The user completed to watch the video, and should be rewarded. 
        // The placement parameter will include the reward data.
        // When using server-to-server callbacks, you may ignore this event and wait for the ironSource server callback
        @Override
        public void onAdRewarded(Placement placement, AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_REWARDED, adInfo, placement);
        }
        // The rewarded video ad was failed to show
        @Override
        public void onAdShowFailed(IronSourceError error, AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_SHOW_FAILED, adInfo, error);
        }
        // Invoked when the video ad was clicked. 
        // This callback is not supported by all networks, and we recommend using it 
        // only if it's supported by all networks you included in your build
        @Override
        public void onAdClicked(Placement placement, AdInfo adInfo) {
            sendSimpleMessage(MSG_REWARDED, EVENT_AD_CLICKED, adInfo, placement);
        }
    }

//--------------------------------------------------
// Interstitial ADS
    
    public void loadInterstitial() {
        IronSource.loadInterstitial();
    }

    public boolean isInterstitialReady() {
        return IronSource.isInterstitialReady();
    }

    public String getInterstitialPlacementInfo(String placementName) {
        InterstitialPlacement placement = IronSource.getInterstitialPlacementInfo(placementName);
        // Null can be returned instead of a placement if the placementName is not valid.
        if (placement == null) {
            return null;
        }
        String message;
        try {
            JSONObject obj = new JSONObject();
            addPlacement(obj, placement);
            message = obj.toString();
        } catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        return message;
    }

    public boolean isInterstitialPlacementCapped(String placementName) {
        return IronSource.isInterstitialPlacementCapped(placementName);
    }

    public void showInterstitial(final String placementName) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                IronSource.showInterstitial(placementName);
            }
        });
    }

    private class DefoldLevelPlayInterstitialListener implements LevelPlayInterstitialListener {
       // Invoked when the interstitial ad was loaded successfully.
       // AdInfo parameter includes information about the loaded ad   
       @Override
       public void onAdReady(AdInfo adInfo) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_READY, adInfo);
       }
       // Indicates that the ad failed to be loaded 
       @Override
       public void onAdLoadFailed(IronSourceError error) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_LOAD_FAILED, error);
       }
       // Invoked when the Interstitial Ad Unit has opened, and user left the application screen.
       // This is the impression indication. 
       @Override
       public void onAdOpened(AdInfo adInfo) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_OPENED, adInfo);
       }
       // Invoked when the interstitial ad closed and the user went back to the application screen.
       @Override
       public void onAdClosed(AdInfo adInfo) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_CLOSED, adInfo);
       }
       // Invoked when the ad failed to show 
       @Override
       public void onAdShowFailed(IronSourceError error, AdInfo adInfo) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_SHOW_FAILED, adInfo, error);
       }
       // Invoked when end user clicked on the interstitial ad
       @Override
       public void onAdClicked(AdInfo adInfo) {
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_CLICKED, adInfo);
       }
       // Invoked before the interstitial ad was opened, and before the InterstitialOnAdOpenedEvent is reported.
       // This callback is not supported by all networks, and we recommend using it only if  
       // it's supported by all networks you included in your build. 
       @Override
       public void onAdShowSucceeded(AdInfo adInfo){
            sendSimpleMessage(MSG_INTERSTITIAL, EVENT_AD_SHOW_SUCCEEDED, adInfo);
       }
    }

//--------------------------------------------------
// Banner ADS


//--------------------------------------------------
// Helpers

    private void addPlacement(JSONObject obj, Placement placement) throws JSONException {
        obj.put("placement_id", placement.getPlacementId());
        obj.put("placement_name", placement.getPlacementName());
        obj.put("is_default", placement.isDefault());

        obj.put("reward_name", placement.getRewardName());
        obj.put("reward_amount", placement.getRewardAmount());
    }

    private void addPlacement(JSONObject obj, InterstitialPlacement placement) throws JSONException {
        obj.put("placement_id", placement.getPlacementId());
        obj.put("placement_name", placement.getPlacementName());
        obj.put("is_default", placement.isDefault());
    }

    private void addAdInfo(JSONObject obj, AdInfo adInfo) throws JSONException {
        obj.put("ad_unit", adInfo.getAdUnit());
        obj.put("auction_id", adInfo.getAuctionId());
        obj.put("ad_network", adInfo.getAdNetwork());
        obj.put("ab", adInfo.getAb());
        obj.put("country", adInfo.getCountry());
        obj.put("instance_id", adInfo.getInstanceId());
        obj.put("instance_name", adInfo.getInstanceName());
        obj.put("segment_name", adInfo.getSegmentName());
        obj.put("revenue", adInfo.getRevenue());
        obj.put("precision", adInfo.getPrecision());
        obj.put("encrypted_cpm", adInfo.getEncryptedCPM());
    }

    private void addIronSourceError(JSONObject obj, IronSourceError error) throws JSONException {
        obj.put("error_code", error.getErrorCode());
        obj.put("error_message", error.getErrorMessage());
    }

    // https://www.baeldung.com/java-json-escaping
    private String getJsonConversionErrorMessage(String messageText) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("error", messageText);
            obj.put("event", EVENT_JSON_ERROR);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = "{ \"error\": \"Error while converting simple message to JSON.\", \"event\": "+EVENT_JSON_ERROR+" }";
        }
        return message;
    }

    private void sendSimpleMessage(int msg, int eventId) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            message = obj.toString();
        } catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, String key_2, String value_2) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            obj.put(key_2, value_2);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, String key_2, int value_2, String key_3, String value_3) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            obj.put(key_2, value_2);
            obj.put(key_3, value_3);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, String key_2, int value_2, String key_3, int value_3) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            obj.put(key_2, value_2);
            obj.put(key_3, value_3);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, AdInfo adInfo) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            addAdInfo(obj, adInfo);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, AdInfo adInfo, Placement placement) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            addAdInfo(obj, adInfo);
            addPlacement(obj, placement);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, AdInfo adInfo, IronSourceError error) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            addAdInfo(obj, adInfo);
            addIronSourceError(obj, error);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

    private void sendSimpleMessage(int msg, int eventId, IronSourceError error) {
        String message = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("event", eventId);
            addIronSourceError(obj, error);
            message = obj.toString();
        }
        catch (JSONException e) {
            message = getJsonConversionErrorMessage(e.getLocalizedMessage());
        }
        ironSourceAddToQueue(msg, message);
    }

}
