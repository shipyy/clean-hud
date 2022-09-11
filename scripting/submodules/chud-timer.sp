public STOPWATCH_SetDefaults(int client)
{
	PrintToServer("Loading Timer Defaults!");

	g_bStopwatch[client] = false;
}

public void SUBMODULE_STOPWATCH(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SUBMODULE_STOPWATCH_Handler);

	SetMenuTitle(menu, "Timer Options Menu\n \n");

	// Toggle
	if (g_bStopwatch[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_STOPWATCH_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Stopwatch_Toggle(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		TIMER_CUSTOMIZE_SUBMODULES(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void Stopwatch_Toggle(int client)
{
    if (g_bStopwatch[client])
		g_bStopwatch[client] = false;
	else
		g_bStopwatch[client] = true;

    SUBMODULE_STOPWATCH(client);
}

/////
//FORMAT
/////
public void STOPWATCH_Format(int client)
{
    if (g_bStopwatch[client] && !IsFakeClient(client)) {
            
		int target;
		
		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(target == -1)
			return;
			
		float PersonalBest;
		int MapRank;
		char country[16], countryCode[3], continentCode[3];
		surftimer_GetPlayerData(target, PersonalBest, MapRank, country, countryCode, continentCode);

		float CurrentTime;
		CurrentTime = surftimer_GetCurrentTime(target);

		if(CurrentTime >= 0.0)
			Format_Time(client, CurrentTime, g_szSTOPWATCH_SUBMODULE[client], sizeof g_szSTOPWATCH_SUBMODULE[], true);
		else
			Format_Time(client, 0.0, g_szSTOPWATCH_SUBMODULE[client], sizeof g_szSTOPWATCH_SUBMODULE[], true);

		//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
		for(int i = 0; i < TIMER_SUBMODULES; i++)
			if (g_iTIMER_SUBMODULES_INDEXES[client][i] == STOPWATCH_ID)
				Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szSTOPWATCH_SUBMODULE[client]);
	}
	else {
		Format(g_szSTOPWATCH_SUBMODULE[client], sizeof g_szSTOPWATCH_SUBMODULE[], "");
	}
}

/////
//SQL
/////
public void db_GET_STOPWATCH(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_stopwatch WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSTOPWATCHCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadSTOPWATCHCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadSTOPWATCHCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bStopwatch[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_stopwatch (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		STOPWATCH_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STOPWATCH_ID == g_TIMER_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_STOPWATCH(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_stopwatch SET enabled = '%i' WHERE steamid = '%s';", g_bStopwatch[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_STOPWATCHCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_STOPWATCHCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_STOPWATCHCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (STOPWATCH_ID == g_TIMER_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}