public MAPINFO_SetDefaults(int client)
{
    PrintToServer("Loading MAPINFO Defaults!");

    g_bMapInfo[client] = false;
    
    g_iMapInfo_CompareMode[client] = 1;
    g_iMapInfo_ShowMode[client] = 2;
}

public void SUBMODULE_MAPINFO(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(SUBMODULE_MAPINFO_Handler);
    char szItem[128];

    SetMenuTitle(menu, "MAPINFO Options Menu\n \n");

    // Toggle
    if (g_bMapInfo[client])
        AddMenuItem(menu, "", "Toggle    | On");
    else
        AddMenuItem(menu, "", "Toggle    | Off");
    
    // Show Mode
    Format(szItem, sizeof szItem, "Show      | %s", g_iMapInfo_ShowMode[client] == 1 ? "WR" : "PB");
    AddMenuItem(menu, "", szItem);

    // Compare Mode
    Format(szItem, sizeof szItem, "Compare | %s", g_iMapInfo_CompareMode[client] == 1 ? "WR\n \n" : "PB\n \n");
    AddMenuItem(menu, "", szItem);

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_MAPINFO_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: MAPINFO_Toggle(param1, true);
            case 1: MAPINFO_ShowMode(param1);
            case 2: MAPINFO_CompareMode(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		INFO_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void MAPINFO_Toggle(int client, bool from_menu)
{
    if (g_bMapInfo[client])
		g_bMapInfo[client] = false;
	else
		g_bMapInfo[client] = true;
    
    SUBMODULE_MAPINFO(client);
}

/////
//COMPARE MODE
/////
void MAPINFO_CompareMode(int client)
{
	if (g_iMapInfo_CompareMode[client] != 2)
		g_iMapInfo_CompareMode[client]++;
	else
		g_iMapInfo_CompareMode[client] = 1;

	SUBMODULE_MAPINFO(client);
}

/////
//SHOW MODE
/////
void MAPINFO_ShowMode(int client)
{
	if (g_iMapInfo_ShowMode[client] != 2)
		g_iMapInfo_ShowMode[client]++;
	else
		g_iMapInfo_ShowMode[client] = 1;

	SUBMODULE_MAPINFO(client);
}

/////
//DISPLAY
/////
public void MAPINFO_Display(int client)
{   
    if(g_bMapInfo[client] && !IsFakeClient(client)) {
        int target;

        if (IsPlayerAlive(client))
            target = client;
        else
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

        if(target == -1)
            return;

        if(IsFakeClient(target)) {
            for(int i = 0; i < INFO_SUBMODULES; i++)
                if (g_iINFO_SUBMODULES_INDEXES[client][i] == MAPINFO_ID)
                    Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
            return;
        }
        
        int wrcptimer;
        int pracmode;
        int stage;
        int bonus;
        surftimer_GetPlayerInfo(target, wrcptimer, pracmode, stage, bonus);
        
        char szWRName[MAX_NAME_LENGTH], szWRTime[32];
        float WRTime;
        float PBTime;
        int client_rank;
        char szClientCountry[16], szClientCountryCode[3], szClientContinentCode[3];

        if (bonus != 0) {
            surftimer_GetBonusData(target, szWRName, WRTime, PBTime);
        }
        else {
            surftimer_GetMapData(szWRName, szWRTime, WRTime);
            surftimer_GetPlayerData(target, PBTime, client_rank, szClientCountry, szClientCountryCode, szClientContinentCode);
        }

        char szShowModeFormatted[64];
        char szCompareModeFormatted[64];

        //FORMAT SHOW MODE
        //PB
        if (g_iMapInfo_ShowMode[client] == 2) {

            if (PBTime != -1.0) {
                Format_Time(client, PBTime, szShowModeFormatted, sizeof szShowModeFormatted, true);
                Format(szShowModeFormatted, sizeof szShowModeFormatted, "PB %s |", szShowModeFormatted);

                //FORMAT COMPARE MODE
                if (g_iMapInfo_CompareMode[client] == 2) {
                    Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s PB +00:00.000", szShowModeFormatted);
                }
                else if (g_iMapInfo_CompareMode[client] == 1) {
                    if(WRTime != 9999999.0) {
                        Format_Time(client, PBTime - WRTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s WR +%s", szShowModeFormatted, szCompareModeFormatted);
                    }
                    else {
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s WR N/A", szShowModeFormatted);
                    }
                }
            }
            else {
                //FORMAT COMPARE MODE
                if (g_iMapInfo_CompareMode[client] == 2) {
                    Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "PB N/A | PB N/A");
                }
                else if (g_iMapInfo_CompareMode[client] == 1) {
                    if(WRTime != 9999999.0) {
                        Format_Time(client, PBTime - WRTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "PB N/A | WR +%s", szCompareModeFormatted);
                    }
                    else {
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "PB N/A | WR N/A");
                    }
                }
            }

        }
        //WR
        else if (g_iMapInfo_ShowMode[client] == 1) {
            if (WRTime != 9999999.0) {
                Format_Time(client, WRTime, szShowModeFormatted, sizeof szShowModeFormatted, true);
                Format(szShowModeFormatted, sizeof szShowModeFormatted, "WR %s |", szShowModeFormatted);

                //FORMAT COMPARE MODE
                if ( g_iMapInfo_CompareMode[client] == 2) {
                    if (PBTime != -1.0) {
                        Format_Time(client, PBTime - WRTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s PB -%s", szShowModeFormatted, szCompareModeFormatted);
                    }
                    else {
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s PB N/A", szShowModeFormatted);
                    }
                }
                else if (g_iMapInfo_CompareMode[client] == 1) {
                    Format_Time(client, WRTime - PBTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                    Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "%s WR +00:00.000", szShowModeFormatted);
                }
            }
            else {
                //FORMAT COMPARE MODE
                if (g_iMapInfo_CompareMode[client] == 2) {
                    if (PBTime != -1.0) {
                        Format_Time(client, PBTime - WRTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "WR N/A | PB -%s", szCompareModeFormatted);
                    }
                    else {
                        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "WR N/A | PB N/A");
                    }
                }
                else if (g_iMapInfo_CompareMode[client] == 1) {
                    Format_Time(client, WRTime - PBTime, szCompareModeFormatted, sizeof szCompareModeFormatted, true);
                    Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "WR N/A | WR N/A");
                }
            }
        }

        //CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
        for(int i = 0; i < INFO_SUBMODULES; i++)
            if (g_iINFO_SUBMODULES_INDEXES[client][i] == MAPINFO_ID)
                Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szMAPINFO_SUBMODULE[client]);
    }
    else {
        Format(g_szMAPINFO_SUBMODULE[client], sizeof g_szMAPINFO_SUBMODULE[], "");
    }
}

/////
//SQL
/////
public void db_GET_MAPINFO(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_mapinfo WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadMAPINFOCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadMAPINFOCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadMAPINFOCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bMapInfo[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_mapinfo (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		MAPINFO_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (MAPINFO_ID == g_INFO_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_MAPINFO(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_mapinfo SET enabled = '%i' WHERE steamid = '%s';", g_bMapInfo[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_MAPINFOCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_MAPINFOCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_MAPINFOCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (MAPINFO_ID == g_INFO_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}