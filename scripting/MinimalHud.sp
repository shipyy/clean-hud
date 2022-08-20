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
#include "mh-queries.sp"
#include "mh-sql.sp"
#include "mh-runner.sp"

public void OnPluginStart()
{
    EngineVersion eGame = GetEngineVersion();
    if (eGame != Engine_CSGO) {
        SetFailState("[MapChallenge] This plugin is for CSGO only.");
    }
    
    db_setupDatabase();

    CreateCMDS();
    
    CreateHooks();
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;
    
    GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);
    
    if(!IsFakeClient(client))
        LoadSettings(client, 0);

    g_fLastSpeed[client] = 0.0;
    g_iLastButton[client] = 0;
    g_iWaitingForResponse[client] = None;

    for(int i = 0; i < 6; i++)
        g_iCurrentTick[client][i] = 0;

    SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void OnMapStart()
{   
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