local log = require("example.log")

local M = {}

local function callback_logger(self, message_id, message)
    print("cbk: "..log.msg(message_id).." "..log.event(message.event))
    local msg = log.get_table_as_str(message)
    if msg then
        print("msg: "..msg)
    end
end

local function ironsource_callback(self, message_id, message)
    callback_logger(self, message_id, message)
    if message_id == ironsource.MSG_INIT then
        if message.event == ironsource.EVENT_INIT_COMPLETE then
            -- ironSource SDK is initialized
            -- massage{}
        end
    elseif message_id == ironsource.MSG_REWARDED then
        if message.event == ironsource.EVENT_AD_AVAILABLE then
            -- Indicates that there's an available ad. 
            -- The adInfo object includes information about the ad that was loaded successfully
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_UNAVAILABLE then
            -- Indicates that no ads are available to be displayed
            -- massage{}
        elseif message.event == ironsource.EVENT_AD_OPENED then
            -- The Rewarded Video ad view has opened. Your activity will loose focus
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_CLOSED then
            -- The Rewarded Video ad view is about to be closed. Your activity will regain its focus
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_REWARDED then
            -- The user completed to watch the video, and should be rewarded.
            -- The placement parameter will include the reward data.
            -- When using server-to-server callbacks, you may ignore this event and wait for the ironSource server callback
            -- massage{AdInfo, Placement}
        elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
            -- The rewarded video ad was failed to show
            -- massage{AdInfo, IronSourceError}
        elseif message.event == ironsource.EVENT_AD_CLICKED then
            -- Invoked when the video ad was clicked.
            -- This callback is not supported by all networks, and we recommend using it 
            -- only if it's supported by all networks you included in your build
            -- massage{AdInfo, Placement}
        end
    elseif message_id == ironsource.MSG_INTERSTITIAL then
        if message.event == ironsource.EVENT_AD_READY then
            -- Invoked when the interstitial ad was loaded successfully.
            -- AdInfo parameter includes information about the loaded ad
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_LOAD_FAILED then
            -- Indicates that the ad failed to be loaded
            -- massage{IronSourceError}
        elseif message.event == ironsource.EVENT_AD_OPENED then
            -- Invoked when the Interstitial Ad Unit has opened, and user left the application screen.
            -- This is the impression indication.
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_CLOSED then
            -- Invoked when the interstitial ad closed and the user went back to the application screen.
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
            -- Invoked when the ad failed to show
            -- massage{AdInfo, IronSourceError}
        elseif message.event == ironsource.EVENT_AD_CLICKED then
            -- Invoked when end user clicked on the interstitial ad
            -- massage{AdInfo}
        elseif message.event == ironsource.EVENT_AD_SHOW_SUCCEEDED then
            -- Invoked before the interstitial ad was opened, and before the InterstitialOnAdOpenedEvent is reported.
            -- This callback is not supported by all networks, and we recommend using it only if
            -- it's supported by all networks you included in your build.
            -- massage{AdInfo}
        end
    elseif message_id == ironsource.MSG_CONSENT then
        if message.event == ironsource.EVENT_CONSENT_LOADED then
            -- Consent View was loaded successfully
            -- massage.consent_view_type
        elseif message.event == ironsource.EVENT_CONSENT_SHOWN then
            -- Consent view was displayed successfully 
            -- massage.consent_view_type
        elseif message.event == ironsource.EVENT_CONSENT_LOAD_FAILED then
            -- Consent view was failed to load
            -- massage.consent_view_type, massage.error_code, massage.error_message
        elseif message.event == ironsource.EVENT_CONSENT_SHOW_FAILED then
            -- Consent view was not displayed, due to error
            -- massage.consent_view_type, massage.error_code, massage.error_message
        elseif message.event == ironsource.EVENT_CONSENT_ACCEPTED then
            -- The user pressed the Settings or Next buttons
            -- massage.consent_view_type
        elseif message.event == ironsource.EVENT_CONSENT_DISMISSED then
            -- The user dismiss consent
            -- massage.consent_view_type
        end
    end
end

function M.set()
    ironsource.set_callback(ironsource_callback)
end

return M