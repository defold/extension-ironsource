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
    if (lua_type(L, 1) != LUA_TSTRING) {
        return DM_LUA_ERROR("Expected string, got %s. Wrong type for appKey variable '%s'.", luaL_typename(L, 1), lua_tostring(L, 1));
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

static const luaL_reg Module_methods[] =
{
    {"init", Lua_Init},
    {"set_callback", Lua_SetCallback},
    {"validate_integration", Lua_ValidateIntegration},
    {"set_consent", Lua_SetConsent},
    {"set_metadata", Lua_SetMetaData},
    {"set_user_id", Lua_SetUserId},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    luaL_register(L, MODULE_NAME, Module_methods);

    #define SETCONSTANT(name) \
    lua_pushnumber(L, (lua_Number) name); \
    lua_setfield(L, -2, #name); \

    // SETCONSTANT(MSG_INTERSTITIAL)
   

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

static  dmExtension::Result InitializeIronSource(dmExtension::Params* params)
{
    dmLogInfo("Registered extension IronSource (null)");
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeIronSource(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, 0, 0, InitializeIronSource, 0, 0, FinalizeIronSource)

#endif // IOS/Android
