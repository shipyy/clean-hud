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
#include "chud-globals.sp"
#include "chud-commands.sp"
#include "chud-forwards.sp"
#include "chud-queries.sp"
#include "chud-sql.sp"
#include "modules/chud-SPEED.sp"
#include "submodules/chud-csd.sp"
#include "submodules/chud-keys.sp"
#include "submodules/chud-sync.sp"
#include "submodules/chud-checkpoints.sp"
#include "submodules/chud-timer.sp"
#include "submodules/chud-mapinfo.sp"
#include "submodules/chud-finish.sp"
#include "chud-misc.sp"
#include "chud-runner.sp"

public void OnPluginStart()
{
    EngineVersion eGame = GetEngineVersion();
    if (eGame != Engine_CSGO) {
        SetFailState("[Clean HUD] This plugin is for CSGO only.");
    }

    //DATABASE
    db_setupDatabase();

    //COMMANDS
    CreateCMDS();
    
    //HOOKS
    CreateHooks();

    Init_SPEED_MODULE();
    //Init_TIMER_MODULE();
    //Init_INPUT_MODULE();
    //Init_INFO_MODULE();
}

public void OnPluginEnd()
{
    //for (int x = 1; x <= MaxClients; x++)
        //if (IsValidClient(x) && !IsFakeClient(x))
            //SAVEOPTIONS(X);
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;

    GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);

    if(!IsFakeClient(client))
        LoadSettings(client, 0);
    
    //if (!IsFakeClient(x))
        //LOADOPTIONS(X);

    g_fLastSpeed[client] = 0.0;
    g_iLastButton[client] = 0;
    g_iWaitingForResponse[client] = None;
}

public void OnMapStart()
{
    //TRANSLATIONS
    LoadTranslations("cleanhud.phrases");
}