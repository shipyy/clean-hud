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

    //DATABASE
    db_setupDatabase();

    //COMMANDS
    CreateCMDS();
    
    //HOOKS
    CreateHooks();

    Init_SPEED_MODULE();
    Init_TIMER_MODULE();
    Init_INPUT_MODULE();
    Init_INFO_MODULE();
}

public void OnPluginEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsValidClient(i) && !IsFakeClient(i))
            SaveModule(i, 1);
}

public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client))
        return;

    GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);

    SetClientDefults(client);

    if(!IsFakeClient(client))
        LoadModule(client, 1);
    
    for(int i = 0; i < 4; i++)
        g_bEditing[client][i] = false;
    
    for(int i = 0; i < 3; i++)
        g_bEditingColor[client][i] = false;

    g_fLastSpeed[client] = 0.0;
    g_iLastButton[client] = 0;
    g_iWaitingForResponse[client] = None;
}

public void OnMapStart()
{
    //TRANSLATIONS
    LoadTranslations("cleanhud.phrases");
}

public void OnMapEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsValidClient(i) && !IsFakeClient(i))
            SaveModule(i, 1);
}