#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)
#pragma once

#include "ironsource_private.h"
#include <dmsdk/sdk.h>

namespace dmIronSource {

// The same events and messages are in IronSourceJNI.java
// If you change enums here, pls make sure you update the constants there as well

enum MessageId
{
    MSG_REWARDED =                        2,
    // MSG_INIT =                         4
};

enum MessageEvent
{
    EVENT_AD_AVAILABLE =                 1,
    EVENT_AD_UNAVAILABLE =               2,
    EVENT_AD_OPENED =                    3,
    EVENT_AD_CLOSED =                    4,
    EVENT_AD_REWARDED =                  5,
    EVENT_AD_CLICKED =                   6,
    EVENT_AD_SHOW_FAILED =               7,
    EVENT_JSON_ERROR =                   11
};

struct CallbackData
{
    MessageId msg;
    char* json;
};

void SetLuaCallback(lua_State* L, int pos);
void UpdateCallback();
void InitializeCallback();
void FinalizeCallback();

void AddToQueueCallback(MessageId type, const char*json);

} //namespace

#endif
