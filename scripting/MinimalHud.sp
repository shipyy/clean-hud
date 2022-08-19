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
#include "mh-csd.sp"
#include "mh-keys.sp"
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

    g_fTickrate = (1 / GetTickInterval());
    
    //HUD SUNCHRONIZERS
    HUD_Handle = CreateHudSynchronizer();
    Keys_Handle = CreateHudSynchronizer();
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client)) {
        return;
    }
    
    GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);
    
    if(!IsFakeClient(client) && IsValidClient(client)) {
        db_LoadCSD(client);
        db_LoadKeys(client);
    }
    
    g_iWaitingForResponse[client] = None;

    g_iCurrentTick[client] = 0;
    SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public void OnClientDisconnect(int client)
{
    if(IsValidClient(client) && !IsFakeClient(client)) {
        db_updateCSD(client);
        db_updateKeys(client);
    }
}