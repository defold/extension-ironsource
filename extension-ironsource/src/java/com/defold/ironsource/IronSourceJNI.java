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

public class IronSourceJNI {

  private static final String TAG = "IronSourceJNI";

  public static native void ironSourceAddToQueue(int msg, String json);

  // duplicate of enums from ironsource_callback_private.h:
  // CONSTANTS:

  private static final int EVENT_JSON_ERROR =            11;

  // END CONSTANTS

  private Activity activity;

  public IronSourceJNI(Activity activity) {
      this.activity = activity;
  }

  public void init(String appKey) {
    IronSource.setLevelPlayRewardedVideoListener(new DefoldLevelPlayRewardedVideoListener());
    IronSource.init(activity, appKey);
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
          obj.put("reward_name", placement.getRewardName());
          obj.put("reward_amount", placement.getRewardAmount());
          message = obj.toString();
      } catch (JSONException e) {
          message = getJsonConversionErrorMessage(e.getLocalizedMessage());
      }
      return message;
  }

  public boolean isRewardedVideoPlacementCapped(String placementName) {
    return IronSource.isRewardedVideoPlacementCapped(placementName);
  }

  private class DefoldLevelPlayRewardedVideoListener implements LevelPlayRewardedVideoListener {
    // Indicates that there's an available ad. 
    // The adInfo object includes information about the ad that was loaded successfully
    // Use this callback instead of onRewardedVideoAvailabilityChanged(true)
    @Override
    public void onAdAvailable(AdInfo adInfo) {
        // String AdUnit = adInfo.getAdUnit();
        // String AuctionId = adInfo.getAuctionId();
        // String AdNetwork = adInfo.getAdNetwork();
        // String Ab = adInfo.getAb();
        // String Country = adInfo.getCountry();
        // String InstanceId = adInfo.getInstanceId();
    }
    // Indicates that no ads are available to be displayed 
    // Use this callback instead of onRewardedVideoAvailabilityChanged(false) 
    @Override
    public void onAdUnavailable() {

    }
    // The Rewarded Video ad view has opened. Your activity will loose focus
    @Override
    public void onAdOpened(AdInfo adInfo) {

    }
    // The Rewarded Video ad view is about to be closed. Your activity will regain its focus
    @Override
    public void onAdClosed(AdInfo adInfo) {

    }
    // The user completed to watch the video, and should be rewarded. 
    // The placement parameter will include the reward data.
    // When using server-to-server callbacks, you may ignore this event and wait for the ironSource server callback
    @Override
    public void onAdRewarded(Placement placement, AdInfo adInfo) {

    }
    // The rewarded video ad was failed to show
    @Override
    public void onAdShowFailed(IronSourceError error, AdInfo adInfo) {

    }
    // Invoked when the video ad was clicked. 
    // This callback is not supported by all networks, and we recommend using it 
    // only if it's supported by all networks you included in your build
    @Override
    public void onAdClicked(Placement placement, AdInfo adInfo) {

    }
  }


//--------------------------------------------------
// Interstitial ADS
  

//--------------------------------------------------
// Banner ADS


//--------------------------------------------------
// Helpers

  // https://www.baeldung.com/java-json-escaping
  private String getJsonConversionErrorMessage(String messageText) {
    String message = null;
      try {
          JSONObject obj = new JSONObject();
          obj.put("error", messageText);
          obj.put("event", EVENT_JSON_ERROR);
          message = obj.toString();
      } catch (JSONException e) {
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
      } catch (JSONException e) {
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
      } catch (JSONException e) {
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
    } catch (JSONException e) {
        message = getJsonConversionErrorMessage(e.getLocalizedMessage());
    }
    ironSourceAddToQueue(msg, message);
  }

}
