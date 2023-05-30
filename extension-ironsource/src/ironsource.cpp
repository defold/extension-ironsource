#define EXTENSION_NAME IronSourceExt
#define LIB_NAME "IronSource"
#define MODULE_NAME "ironsource"

#define DLIB_LOG_DOMAIN LIB_NAME
#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)

#include "ironsource_private.h"
#include "ironsource_callback_private.h"
#include "utils/LuaUtils.h"

namespace dmIronSource {

static int Lua_Init(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for app_key variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_appKey = luaL_checkstring(L, 1);
    Init(lua_appKey);
    return 0;
}

static int Lua_SetCallback(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    SetLuaCallback(L, 1);
    return 0;
}

static int Lua_ValidateIntegration(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    ValidateIntegration();
    return 0;
}

static int Lua_SetConsent(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    bool isConsentProvided = luaL_checkbool(L, 1);
    SetConsent(isConsentProvided);
    return 0;
}

static int Lua_SetMetaData(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char* lua_key = luaL_checkstring(L, 1);
    const char* lua_value = luaL_checkstring(L, 2);
    SetMetaData(lua_key, lua_value);
    return 0;
}

static int Lua_SetUserId(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char* lua_userId = luaL_checkstring(L, 1);
    SetUserId(lua_userId);
    return 0;
}

static int Lua_LaunchTestSuite(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    LaunchTestSuite();
    return 0;
}

static int Lua_SetAdaptersDebug(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    bool isDebugAdapters = luaL_checkbool(L, 1);
    SetAdaptersDebug(isDebugAdapters);
    return 0;
}

static int Lua_ShowConsentView(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char* lua_consentViewType = luaL_checkstring(L, 1);
    ShowConsentView(lua_consentViewType);
    return 0;
}

static int Lua_LoadConsentView(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char* lua_consentViewType = luaL_checkstring(L, 1);
    LoadConsentView(lua_consentViewType);
    return 0;
}

static int Lua_shouldTrackNetworkState(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    bool shouldTrackNetworkState = luaL_checkbool(L, 1);
    ShouldTrackNetworkState(shouldTrackNetworkState);
    return 0;
}

static int Lua_isRewardedVideoAvailable(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    bool isAvailable = IsRewardedVideoAvailable();
    lua_pushboolean(L, isAvailable);
    return 1;
}

static int Lua_showRewardedVideo(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    int type = lua_type(L, 1);
    if (type != LUA_TSTRING && type != LUA_TNONE && type != LUA_TNIL)
    {
        return DM_LUA_ERROR("Expected string with the placement name or nil/nothing for default placement, got %s. Wrong type for appKey variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    if (type == LUA_TSTRING)
    {
        const char* placementName = luaL_checkstring(L, 1);
        ShowRewardedVideo(placementName);
    }
    else
    {
        ShowRewardedVideo(NULL);
    }
    return 0;
}

static int Lua_getRewardedVideoPlacementInfo(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for placement name variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_placementName = luaL_checkstring(L, 1);
    const char* placementJson = GetRewardedVideoPlacementInfo(lua_placementName);
    if (placementJson == NULL)
    {
        lua_pushnil(L);
    }
    else
    {
        dmScript::JsonToLua(L, placementJson, strlen(placementJson)); // throws lua error if it fails
    }
    return 1;
}

static int Lua_isRewardedVideoPlacementCapped(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for placement name variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_placementName = luaL_checkstring(L, 1);
    bool isCapped = IsRewardedVideoPlacementCapped(lua_placementName);
    lua_pushboolean(L, isCapped);
    return 1;
}

static int Lua_setDynamicUserId(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for user_id variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_appKey = luaL_checkstring(L, 1);
    SetDynamicUserId(lua_appKey);
    return 0;
}

static int Lua_loadInterstitial(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    LoadInterstitial();
    return 0;
}

static int Lua_isInterstitialReady(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    bool isReady = IsInterstitialReady();
    lua_pushboolean(L, isReady);
    return 1;
}

static int Lua_getInterstitialPlacementInfo(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for placement name variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_placementName = luaL_checkstring(L, 1);
    const char* placementJson = GetInterstitialPlacementInfo(lua_placementName);
    if (placementJson == NULL)
    {
        lua_pushnil(L);
    }
    else
    {
        dmScript::JsonToLua(L, placementJson, strlen(placementJson)); // throws lua error if it fails
    }
    return 1;
}

static int Lua_isInterstitialPlacementCapped(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 1);
    if (lua_type(L, 1) != LUA_TSTRING)
    {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for placement name variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    const char* lua_placementName = luaL_checkstring(L, 1);
    bool isCapped = IsInterstitialPlacementCapped(lua_placementName);
    lua_pushboolean(L, isCapped);
    return 1;
}

static int Lua_showInterstitial(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    int type = lua_type(L, 1);
    if (type != LUA_TSTRING && type != LUA_TNONE && type != LUA_TNIL)
    {
        return DM_LUA_ERROR("Expected string with the placement name or nil/nothing for default placement, got %s. Wrong type for appKey variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
    }
    if (type == LUA_TSTRING)
    {
        const char* placementName = luaL_checkstring(L, 1);
        ShowInterstitial(placementName);
    }
    else
    {
        ShowInterstitial(NULL);
    }
    return 0;
}

static const luaL_reg Module_methods[] =
{
    {"init", Lua_Init},
    {"set_callback", Lua_SetCallback},
    {"validate_integration", Lua_ValidateIntegration},
    {"set_consent", Lua_SetConsent},
    {"set_metadata", Lua_SetMetaData},
    {"set_user_id", Lua_SetUserId},
    {"launch_test_suite", Lua_LaunchTestSuite},
    {"set_adapters_debug", Lua_SetAdaptersDebug},
    {"show_consent_view", Lua_LoadConsentView},
    {"load_consent_view", Lua_ShowConsentView},
    // rewarded
    {"should_track_network_state", Lua_shouldTrackNetworkState},
    {"is_rewarded_video_available", Lua_isRewardedVideoAvailable},
    {"show_rewarded_video", Lua_showRewardedVideo},
    {"get_rewarded_video_placement_info", Lua_getRewardedVideoPlacementInfo},
    {"is_rewarded_video_placement_capped", Lua_isRewardedVideoPlacementCapped},
    {"set_dynamic_user_id", Lua_setDynamicUserId},
    // Interstitial
    {"load_interstitial", Lua_loadInterstitial},
    {"is_interstitial_ready", Lua_isInterstitialReady},
    {"get_interstitial_placement_info", Lua_getInterstitialPlacementInfo},
    {"is_interstitial_placement_capped", Lua_isInterstitialPlacementCapped},
    {"show_interstitial", Lua_showInterstitial},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    luaL_register(L, MODULE_NAME, Module_methods);

    #define SETCONSTANT(name) \
    lua_pushnumber(L, (lua_Number) name); \
    lua_setfield(L, -2, #name); \

    SETCONSTANT(MSG_INTERSTITIAL)
    SETCONSTANT(MSG_REWARDED)
    SETCONSTANT(MSG_CONSENT)
    SETCONSTANT(MSG_INIT)

    SETCONSTANT(EVENT_AD_AVAILABLE)
    SETCONSTANT(EVENT_AD_UNAVAILABLE)
    SETCONSTANT(EVENT_AD_OPENED)
    SETCONSTANT(EVENT_AD_CLOSED)
    SETCONSTANT(EVENT_AD_REWARDED)
    SETCONSTANT(EVENT_AD_CLICKED)
    SETCONSTANT(EVENT_AD_SHOW_FAILED)
    SETCONSTANT(EVENT_AD_READY)
    SETCONSTANT(EVENT_AD_SHOW_SUCCEEDED)
    SETCONSTANT(EVENT_AD_LOAD_FAILED)
    SETCONSTANT(EVENT_JSON_ERROR)
    SETCONSTANT(EVENT_INIT_COMPLETE)
    SETCONSTANT(EVENT_CONSENT_LOADED)
    SETCONSTANT(EVENT_CONSENT_SHOWN)
    SETCONSTANT(EVENT_CONSENT_LOAD_FAILED)
    SETCONSTANT(EVENT_CONSENT_SHOW_FAILED)

    #undef SETCONSTANT

    lua_pop(L, 1);
}

static dmExtension::Result AppInitializeIronSource(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result InitializeIronSource(dmExtension::Params* params)
{
    LuaInit(params->m_L);
    Initialize_Ext();
    InitializeCallback();
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeIronSource(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeIronSource(dmExtension::Params* params)
{
    FinalizeCallback();
    return dmExtension::RESULT_OK;
}

static dmExtension::Result UpdateIronSource(dmExtension::Params* params)
{
    UpdateCallback();
    return dmExtension::RESULT_OK;
}

static void OnEventIronSource(dmExtension::Params* params, const dmExtension::Event* event)
 {
    switch(event->m_Event)
    {
        case dmExtension::EVENT_ID_ACTIVATEAPP:
            OnResume();
            break;
        case dmExtension::EVENT_ID_DEACTIVATEAPP:
            OnPause();
            break;
    }
 }

} //namespace dmIronSource

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, dmIronSource::AppInitializeIronSource, dmIronSource::AppFinalizeIronSource, dmIronSource::InitializeIronSource, dmIronSource::UpdateIronSource, dmIronSource::OnEventIronSource, dmIronSource::FinalizeIronSource)

#else

static dmExtension::Result InitializeIronSource(dmExtension::Params* params)
{
    dmLogInfo("Registered extension IronSource (null)");
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeIronSource(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, 0, 0, InitializeIronSource, 0, 0, FinalizeIronSource)

#endif // DM_PLATFORM_ANDROID || DM_PLATFORM_IOS
