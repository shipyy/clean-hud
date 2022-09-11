public STAGEINDICATOR_SetDefaults(int client)
{
    PrintToServer("Loading STAGEINDICATOR Defaults!");

    g_bStageIndicator[client] = false;
}

public void SUBMODULE_STAGEINDICATOR(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(SUBMODULE_STAGEINDICATOR_Handler);

    SetMenuTitle(menu, "Stage Info Options Menu\n \n");

    // Toggle
    if (g_bStageIndicator[client])
        AddMenuItem(menu, "", "Toggle    | On");
    else
        AddMenuItem(menu, "", "Toggle    | Off");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_STAGEINDICATOR_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: STAGEINDICATOR_Toggle(param1, true);
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
public void STAGEINDICATOR_Toggle(int client, bool from_menu)
{
    if (g_bStageIndicator[client])
		g_bStageIndicator[client] = false;
	else
		g_bStageIndicator[client] = true;
    
    SUBMODULE_STAGEINDICATOR(client);
}

/////
//DISPLAY
/////
public void STAGEINDICATOR_Display(int client)
{   
    if(g_bStageIndicator[client] && !IsFakeClient(client)) {
        int target;

        if (IsPlayerAlive(client))
            target = client;
        else
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

        if(target == -1)
            return;

        if(IsFakeClient(target)){
            for(int i = 0; i < INFO_SUBMODULES; i++)
                if (g_iINFO_SUBMODULES_INDEXES[client][i] == STAGEINDICATOR_ID)
                    Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
            return;
        }
            

        int total_stages = surftimer_GetMapStages();

        int wrcptimer;
        int pracmode;
        int stage;
        int bonus;

        if (total_stages != 0) {
            surftimer_GetPlayerInfo(target, wrcptimer, pracmode, stage, bonus);

            Format(g_szSTAGEINDICATOR_SUBMODULE[client], sizeof g_szSTAGEINDICATOR_SUBMODULE[], "Stage %d/%d", stage, total_stages);
        }
        else {
            Format(g_szSTAGEINDICATOR_SUBMODULE[client], sizeof g_szSTAGEINDICATOR_SUBMODULE[], "");
        }

        //CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
        for(int i = 0; i < INFO_SUBMODULES; i++)
            if (g_iINFO_SUBMODULES_INDEXES[client][i] == STAGEINDICATOR_ID)
                Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szSTAGEINDICATOR_SUBMODULE[client]);
    }
    else {
        Format(g_szSTAGEINDICATOR_SUBMODULE[client], sizeof g_szSTAGEINDICATOR_SUBMODULE[], "");
    }
}

/////
//SQL
/////
public void db_GET_STAGEINDICATOR(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_stageindicator WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSTAGEINDICATORCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadSTAGEINDICATORCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadSTAGEINDICATORCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bStageIndicator[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_stageindicator (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		STAGEINDICATOR_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STAGEINDICATOR_ID == g_INFO_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_STAGEINDICATOR(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_stageindicator SET enabled = '%i' WHERE steamid = '%s';", g_bStageIndicator[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_STAGEINDICATORCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_STAGEINDICATORCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_STAGEINDICATORCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STAGEINDICATOR_ID == g_INFO_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}