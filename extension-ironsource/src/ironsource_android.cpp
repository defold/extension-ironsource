#if defined(DM_PLATFORM_ANDROID)

#include <dmsdk/dlib/android.h>
#include "ironsource_private.h"
#include "com_defold_ironsource_IronSourceJNI.h"
#include "ironsource_callback_private.h"

JNIEXPORT void JNICALL Java_com_defold_ironsource_IronSourceJNI_ironSourceAddToQueue(JNIEnv * env, jclass cls, jint jmsg, jstring jjson)
{
    const char* json = env->GetStringUTFChars(jjson, 0);
    dmIronSource::AddToQueueCallback((dmIronSource::MessageId)jmsg, json);
    env->ReleaseStringUTFChars(jjson, json);
}

namespace dmIronSource {

struct IronSource
{
    jobject         m_IronSourceJNI;

    jmethodID       m_Init;
    jmethodID       m_OnPause;
    jmethodID       m_OnResume;
    jmethodID       m_ValidateIntegration;
    jmethodID       m_SetConsent;
    jmethodID       m_SetMetaData;
    jmethodID       m_SetUserId;
    jmethodID       m_ShouldTrackNetworkState;
    jmethodID       m_IsRewardedVideoAvailable;
    jmethodID       m_ShowRewardedVideo;
};

static IronSource   g_ironsource;

static void CallVoidMethod(jobject instance, jmethodID method)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    env->CallVoidMethod(instance, method);
}

static bool CallBoolMethod(jobject instance, jmethodID method)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    jboolean return_value = (jboolean)env->CallBooleanMethod(instance, method);
    return JNI_TRUE == return_value;
}

static void CallVoidMethodChar(jobject instance, jmethodID method, const char* cstr)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    jstring jstr = env->NewStringUTF(cstr);
    env->CallVoidMethod(instance, method, jstr);
    env->DeleteLocalRef(jstr);
}

static void CallVoidMethodCharChar(jobject instance, jmethodID method, const char* cstr_1, const char* cstr_2)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    jstring jstr_1 = env->NewStringUTF(cstr_1);
    jstring jstr_2 = env->NewStringUTF(cstr_2);
    env->CallVoidMethod(instance, method, jstr_1, jstr_2);
    env->DeleteLocalRef(jstr_1);
    env->DeleteLocalRef(jstr_2);
}

static void CallVoidMethodCharInt(jobject instance, jmethodID method, const char* cstr, int cint)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    jstring jstr = env->NewStringUTF(cstr);
    env->CallVoidMethod(instance, method, jstr, cint);
    env->DeleteLocalRef(jstr);
}

static void CallVoidMethodInt(jobject instance, jmethodID method, int cint)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    env->CallVoidMethod(instance, method, cint);
}

static void CallVoidMethodBool(jobject instance, jmethodID method, bool cbool)
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();

    env->CallVoidMethod(instance, method, cbool);
}

static void InitJNIMethods(JNIEnv* env, jclass cls)
{
    g_ironsource.m_Init = env->GetMethodID(cls, "init", "(Ljava/lang/String;)V");
    g_ironsource.m_OnPause = env->GetMethodID(cls, "onPause", "()V");
    g_ironsource.m_OnResume = env->GetMethodID(cls, "onResume", "()V");
    g_ironsource.m_ValidateIntegration = env->GetMethodID(cls, "validateIntegration", "()V");
    g_ironsource.m_SetConsent = env->GetMethodID(cls, "setConsent", "(Z)V");
    g_ironsource.m_SetMetaData = env->GetMethodID(cls, "setMetaData", "(Ljava/lang/String;Ljava/lang/String;)V");
    g_ironsource.m_SetUserId = env->GetMethodID(cls, "setUserId", "(Ljava/lang/String;)V");
    g_ironsource.m_ShouldTrackNetworkState = env->GetMethodID(cls, "shouldTrackNetworkState", "(Z)V");
    g_ironsource.m_IsRewardedVideoAvailable= env->GetMethodID(cls, "isRewardedVideoAvailable", "(Z)Z");
    g_ironsource.m_ShowRewardedVideo = env->GetMethodID(cls, "showRewardedVideo", "(Ljava/lang/String;)V");
}

void Initialize_Ext()
{
    dmAndroid::ThreadAttacher threadAttacher;
    JNIEnv* env = threadAttacher.GetEnv();
    jclass cls = dmAndroid::LoadClass(env, "com.defold.ironsource.IronSourceJNI");

    InitJNIMethods(env, cls);

    jmethodID jni_constructor = env->GetMethodID(cls, "<init>", "(Landroid/app/Activity;)V");

    g_ironsource.m_IronSourceJNI = env->NewGlobalRef(env->NewObject(cls, jni_constructor, threadAttacher.GetActivity()->clazz));
}

void Init(const char* appKey)
{
    CallVoidMethodChar(g_ironsource.m_IronSourceJNI, g_ironsource.m_Init, appKey);
}

void OnPause()
{
    CallVoidMethod(g_ironsource.m_IronSourceJNI, g_ironsource.m_OnPause);
}

void OnResume()
{
    CallVoidMethod(g_ironsource.m_IronSourceJNI, g_ironsource.m_OnResume);
}

void ValidateIntegration()
{
    CallVoidMethod(g_ironsource.m_IronSourceJNI, g_ironsource.m_ValidateIntegration);
}

void SetConsent(bool isConsentProvided)
{
    CallVoidMethodBool(g_ironsource.m_IronSourceJNI, g_ironsource.m_SetConsent, isConsentProvided);
}


void SetMetaData(const char* key, const char* value)
{
    CallVoidMethodCharChar(g_ironsource.m_IronSourceJNI, g_ironsource.m_SetMetaData, key, value);
}

void SetUserId(const char* userId)
{
    CallVoidMethodChar(g_ironsource.m_IronSourceJNI, g_ironsource.m_SetUserId, userId);
}

void ShouldTrackNetworkState(bool shouldTrackNetworkState)
{
    CallVoidMethodBool(g_ironsource.m_IronSourceJNI, g_ironsource.m_ShouldTrackNetworkState, shouldTrackNetworkState);
}

bool IsRewardedVideoAvailable()
{
    return CallBoolMethod(g_ironsource.m_IronSourceJNI, g_ironsource.m_IsRewardedVideoAvailable);
}

void ShowRewardedVideo(const char* placementName)
{
    //TODO: check when `placementName` is NULL (default value)
    CallVoidMethodChar(g_ironsource.m_IronSourceJNI, g_ironsource.m_ShowRewardedVideo, placementName);
}

}//namespace dmIronSource

#endif
