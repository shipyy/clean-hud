/////
// Plugin Info
/////
public Plugin myinfo =
{
	name        = "Clean HUD",
	author      = "https://github.com/shipyy",
	description = "hud for surftimer",
	version     = "1.1.1",
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
#include "chud-globals.sp"
#include "chud-commands.sp"
#include "chud-forwards.sp"
#include "chud-queries.sp"
#include "chud-sql.sp"
#include "modules/chud-OPTIONS.sp"
#include "modules/chud-SPEED.sp"
#include "modules/chud-TIMER.sp"
#include "modules/chud-INPUT.sp"
#include "modules/chud-INFO.sp"
#include "submodules/chud-csd.sp"
#include "submodules/chud-keys.sp"
#include "submodules/chud-sync.sp"
#include "submodules/chud-checkpoints.sp"
#include "submodules/chud-timer.sp"
#include "submodules/chud-finish.sp"
#include "submodules/chud-mapinfo.sp"
#include "submodules/chud-stageinfo.sp"
#include "submodules/chud-stageindicator.sp"
#include "chud-misc.sp"
#include "chud-runner.sp"

public void OnPluginStart()
{
    EngineVersion eGame = GetEngineVersion();
    if (eGame != Engine_CSGO) {
        SetFailState("[Clean HUD] This plugin is for CSGO only.");
    }

    //GET TICKRATE
    g_fTickrate = (1 / GetTickInterval());

    //DATABASE
    db_setupDatabase();

    //COMMANDS
    CreateCMDS();

    Init_SPEED_MODULE();
    Init_TIMER_MODULE();
    Init_INPUT_MODULE();
    Init_INFO_MODULE();
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;

    GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);

    SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);

    SetClientDefults(client);

    char szName[MAX_NAME_LENGTH];
    GetClientName(client, szName, MAX_NAME_LENGTH);
    if(!IsFakeClient(client)) {
        PrintToConsole(0, "+++ Loading %s CHUD options +++", szName);
        db_LoadOPTIONS(client);
    }
}

public void OnMapStart()
{
    //TRANSLATIONS
    LoadTranslations("cleanhud.phrases");
}

public void OnPluginEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsValidClient(i) && !IsFakeClient(i)) {
            PrintToConsole(0, "\n\n===SAVING PLAYER OPTIONS ONMAPEND()===\n\n");
            OnClientDisconnect(i);
        }
}