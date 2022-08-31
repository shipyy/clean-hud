/////
// Plugin Info
/////
public Plugin myinfo =
{
	name        = "Clean HUD",
	author      = "https://github.com/shipyy",
	description = "hud for surftimer",
	version     = "0.0.2",
	url         = "https://github.com/shipyy/clean-hud"
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
#include "chud-clientprefs.sp"
#include "chud-globals.sp"
#include "chud-commands.sp"
#include "chud-forwards.sp"
#include "chud-csd.sp"
#include "chud-keys.sp"
#include "chud-sync.sp"
#include "chud-checkpoints.sp"
#include "chud-timer.sp"
#include "chud-mapinfo.sp"
#include "chud-finish.sp"
#include "chud-misc.sp"
#include "chud-runner.sp"

public void OnPluginStart()
{
    EngineVersion eGame = GetEngineVersion();
    if (eGame != Engine_CSGO) {
        SetFailState("[Clean HUD] This plugin is for CSGO only.");
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

    //INIT MODULES
    CSD_Handle = CreateHudSynchronizer();
    Keys_Handle = CreateHudSynchronizer();
    Sync_Handle = CreateHudSynchronizer();
    CP_Handle = CreateHudSynchronizer();
    Timer_Handle = CreateHudSynchronizer();
    MapInfo_Handle = CreateHudSynchronizer();
    Finish_Handle = CreateHudSynchronizer();
    /*
    Init_CSD();
    Init_KEYS();
    Init_SYNC();
    Init_CP();
    Init_TIMER();
    Init_MAPINFO();
    Init_FINISH();
    */
}

public void OnPluginEnd()
{
    for (int x = 1; x <= MaxClients; x++)
        if (IsValidClient(x) && !IsFakeClient(x))
            SaveCookies(x);
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;
    
    if(AreClientCookiesCached(client))
        OnClientCookiesCached(client);

    g_fLastSpeed[client] = 0.0;
    g_iLastButton[client] = 0;
    WaitingForResponse[client] = None;
}

public void OnMapStart()
{
    //TRANSLATIONS
    LoadTranslations("cleanhud.phrases");
}

public void OnClientCookiesCached(int client)
{
    if(!IsClientInGame(client) || IsFakeClient(client))
        return;
    
    PrintToServer("\n=====LOADING COOKIES=====\n");
    LoadCookies(client);
    PrintToServer("\n=====COOKIES LOADED=====\n");
}