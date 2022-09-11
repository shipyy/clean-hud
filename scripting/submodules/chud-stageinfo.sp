public STAGEINFO_SetDefaults(int client)
{
    PrintToServer("Loading STAGEINFO Defaults!");

    g_bStageInfo[client] = false;
}

public void SUBMODULE_STAGEINFO(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(SUBMODULE_STAGEINFO_Handler);

    SetMenuTitle(menu, "Stage Info Options Menu\n \n");

    // Toggle
    if (g_bStageInfo[client])
        AddMenuItem(menu, "", "Toggle    | On");
    else
        AddMenuItem(menu, "", "Toggle    | Off");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_STAGEINFO_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: STAGEINFO_Toggle(param1, true);
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
public void STAGEINFO_Toggle(int client, bool from_menu)
{
    if (g_bStageInfo[client])
		g_bStageInfo[client] = false;
	else
		g_bStageInfo[client] = true;
    
    SUBMODULE_STAGEINFO(client);
}

/////
//DISPLAY
/////
public void STAGEINFO_Display(int client)
{   
    if(g_bStageInfo[client] && !IsFakeClient(client)) {
        int target;

        if (IsPlayerAlive(client))
            target = client;
        else
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

        if(target == -1)
            return;

        if(IsFakeClient(target)) {
            for(int i = 0; i < INFO_SUBMODULES; i++)
                if (g_iINFO_SUBMODULES_INDEXES[client][i] == STAGEINFO_ID)
                    Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
            return;
        }

        int total_stages = surftimer_GetMapStages();

        int wrcptimer;
        int pracmode;
        int stage;
        int bonus;
        surftimer_GetPlayerInfo(target, wrcptimer, pracmode, stage, bonus);

        //STAGE VARS
        char szStageWRName[MAX_NAME_LENGTH];
        float StageWRTime;
        float StagePBTime;
        char szStageInfo[128];
        char szStageWRDiffFormatted[32];
        char szStagePBFormatted[32];
        char szStageWRCPFormatted[32];

        if (total_stages != 0 && bonus == 0) {
            surftimer_GetStageData(target, szStageWRName, StageWRTime, StagePBTime);

            if (StagePBTime != -1.0) {
                Format_Time(client, StagePBTime, szStagePBFormatted, sizeof szStagePBFormatted, true);

                //FORMAT STAGE WR COMPARISON
                if (StageWRTime != -1.0) {
                    float stage_wr_diff = StageWRTime - StagePBTime;
                    if (stage_wr_diff != 0.0) {
                        Format_Time(client, stage_wr_diff, szStageWRDiffFormatted, sizeof szStageWRDiffFormatted, true);
                        
                        //SLOWER
                        if (stage_wr_diff <= 0.0) {
                            Format(szStageWRDiffFormatted, sizeof szStageWRDiffFormatted, "+%s", szStageWRDiffFormatted);
                        }
                        //FASTER
                        else {
                            Format(szStageWRDiffFormatted, sizeof szStageWRDiffFormatted, "-%s", szStageWRDiffFormatted);
                        }
                    }
                    else {
                        Format(szStageWRDiffFormatted, sizeof szStageWRDiffFormatted, "%s", "+00:00.000");
                    }
                }
                else {
                    Format(szStageWRDiffFormatted, sizeof szStageWRDiffFormatted, "N/A");
                }

                Format(szStageInfo, sizeof szStageInfo, "Stage %d | %s (%s)", stage, szStagePBFormatted, szStageWRDiffFormatted);
            }
            else {
                Format(szStageInfo, sizeof szStageInfo, "Stage %d | N/A", stage);
            }

            //FORMAT WRCP STRING WITH NAME
            //WRCP 00:00.000 (PLAYERNAME)
            //FORMAT STAGE PB
            if (StageWRTime != -1.0) {
                Format_Time(client, StageWRTime, szStageWRCPFormatted, sizeof szStageWRCPFormatted, true);
                Format(szStageWRCPFormatted, sizeof szStageWRCPFormatted , "WRCP %s (%s)", szStageWRCPFormatted, szStageWRName);
            }
            else
                Format(szStageWRCPFormatted, sizeof szStageWRCPFormatted, "%s", "WRCP N/A");

            Format(g_szSTAGEINFO_SUBMODULE[client], sizeof g_szSTAGEINFO_SUBMODULE[], "%s\n%s", szStageInfo, szStageWRCPFormatted);
        }
        if (total_stages == 0 && bonus == 0) {
            Format(g_szSTAGEINFO_SUBMODULE[client], sizeof g_szSTAGEINFO_SUBMODULE[], "%s", "Linear Map");
        }
        if (total_stages != 0 && bonus != 0) {
            Format(g_szSTAGEINFO_SUBMODULE[client], sizeof g_szSTAGEINFO_SUBMODULE[], "%s", "");
        }

        //CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
        for(int i = 0; i < INFO_SUBMODULES; i++)
            if (g_iINFO_SUBMODULES_INDEXES[client][i] == STAGEINFO_ID)
                Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szSTAGEINFO_SUBMODULE[client]);
    }
	else {
		Format(g_szSTAGEINFO_SUBMODULE[client], sizeof g_szSTAGEINFO_SUBMODULE[], "");
	}
}

/////
//SQL
/////
public void db_GET_STAGEINFO(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_stageinfo WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSTAGEINFOCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadSTAGEINFOCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadSTAGEINFOCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bStageInfo[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_stageinfo (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		STAGEINFO_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STAGEINFO_ID == g_INFO_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_STAGEINFO(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_stageinfo SET enabled = '%i' WHERE steamid = '%s';", g_bStageInfo[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_STAGEINFOCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_STAGEINFOCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_STAGEINFOCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STAGEINFO_ID == g_INFO_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}