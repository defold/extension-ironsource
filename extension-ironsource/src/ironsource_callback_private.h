#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)
#pragma once

#include "ironsource_private.h"
#include <dmsdk/sdk.h>

namespace dmIronSource {

// The same events and messages are in IronSourceJNI.java
// If you change enums here, pls make sure you update the constants there as well

enum MessageId
{
    MSG_INIT =                         4
};

enum MessageEvent
{
    EVENT_JSON_ERROR =              11
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
