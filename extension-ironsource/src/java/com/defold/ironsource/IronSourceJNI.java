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

public class IronSourceJNI {

  private static final String TAG = "IronSourceJNI";

  public static native void ironSourceAddToQueue(int msg, String json);

  // duplicate of enums from ironsource_callback_private.h:
  // CONSTANTS:
  private static final int MSG_INIT =                    4;


  private static final int EVENT_JSON_ERROR =            11;

  // END CONSTANTS


  private Activity activity;

  public IronSourceJNI(Activity activity) {
      this.activity = activity;
  }

  public void init(String appKey) {
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

//--------------------------------------------------
// Interstitial ADS

 

//--------------------------------------------------
// Rewarded ADS

  

//--------------------------------------------------
// Banner ADS


}
