/////
// Plugin Info
/////
public Plugin myinfo =
{
	name        = "Minimal HUD",
	author      = "https://github.com/shipyy",
	description = "hud for surftimer",
	version     = "0.0.0",
	url         = "https://github.com/shipyy/minimal-hud"
};

#pragma semicolon 1
#pragma newdecls required

/////
// INCLUDES
/////
#include <colorlib>
#include <sourcemod>
#include <surftimer>
#include <sdkhooks>
#include <clientprefs>
#include <chat-processor>
#include "mh-globals.sp"
#include "mh-commands.sp"
#include "mh-forwards.sp"
#include "mh-csd.sp"
#include "mh-keys.sp"
#include "mh-sync.sp"
#include "mh-checkpoints.sp"
#include "mh-timer.sp"
#include "mh-mapinfo.sp"
#include "mh-finish.sp"
#include "mh-misc.sp"
#include "mh-runner.sp"
#include "mh-clientprefs.sp"

public void OnPluginStart()
{
    EngineVersion eGame = GetEngineVersion();
    if (eGame != Engine_CSGO) {
        SetFailState("[Minimal HUD] This plugin is for CSGO only.");
    }

    //COMMANDS
    CreateCMDS();
    
    //HOOKS
    CreateHooks();

    //COOKI HANDLES
    g_hCSD_Cookie = RegClientCookie("CSD-cookie", "CSD data", CookieAccess_Public);
    g_hKeys_Cookie = RegClientCookie("Keys-cookie", "Keys data", CookieAccess_Public);
    g_hSync_Cookie = RegClientCookie("Sync-cookie", "Sync data", CookieAccess_Public);
    g_hCP_Cookie = RegClientCookie("CP-cookie", "CP data", CookieAccess_Public);
    g_hTimer_Cookie = RegClientCookie("Timer-cookie", "Timer data", CookieAccess_Public);
    g_hMapInfo_Cookie = RegClientCookie("MapInfo-cookie", "MapInfo data", CookieAccess_Public);
    g_hFinish_Cookie = RegClientCookie("Finish-cookie", "Finish data", CookieAccess_Public);
}

public void OnPluginEnd()
{
    for (int x = 1; x <= MaxClients; x++)
        if (IsValidClient(x)) {
            if (!IsFakeClient(x))
                SaveCookies(x);
            SDKUnhook(x, SDKHook_PostThinkPost, Hook_PostThinkPost);
        }
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;

    if(IsFakeClient(client) || !AreClientCookiesCached(client))
        return;
    
    if(AreClientCookiesCached(client))
        OnClientCookiesCached(client);

    g_fLastSpeed[client] = 0.0;
    g_iLastButton[client] = 0;
    g_iWaitingForResponse[client] = None;

    for(int i = 0; i < 6; i++)
        g_iCurrentTick[client][i] = 0;

    //HOOK FOR TICK COUNTING
    SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void OnMapStart()
{
    //TRANSLATIONS
    LoadTranslations("minimalhud.phrases");

    //GET TICKRATE
    g_fTickrate = (1 / GetTickInterval());

    //INIT MODULES
    Init_CSD();
    Init_KEYS();
    Init_SYNC();
    Init_CP();
    Init_TIMER();
    Init_MAPINFO();
    Init_FINISH();
}

public void OnClientCookiesCached(int client)
{
    if(!IsClientInGame(client) || IsFakeClient(client))
        return;

    PrintToServer("\n=====LOADING COOKIES=====\n");
    LoadCookies(client);
}