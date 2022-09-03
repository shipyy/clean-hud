public FINISH_SetDefaults(int client)
{
	PrintToServer("Loading Finish Defaults!");

	g_bFinish[client] = false;
	g_iFinish_CompareMode[client] = 1;
}

public void SUBMODULE_FINISH(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SUBMODULE_FINISH_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Finish Menu\n \n");

	// Toggle
	if (g_bFinish[client])
		AddMenuItem(menu, "", "Toggle     | On");
	else
		AddMenuItem(menu, "", "Toggle     | Off");

	// Compare Mode
	Format(szItem, sizeof szItem, "Compare  | %s", g_iFinish_CompareMode[client] == 0 ? "PB\n \n" : "WR\n \n");
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_FINISH_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Finish_Toggle(param1);
			case 1: Finish_CompareMode(param1);
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
public void Finish_Toggle(int client)
{
	if (g_bFinish[client])
		g_bFinish[client] = false;
	else
		g_bFinish[client] = true;

	SUBMODULE_FINISH(client);
}

/////
//COMPARE MODE
/////
void Finish_CompareMode(int client)
{
	if (g_iFinish_CompareMode[client] != 1)
		g_iFinish_CompareMode[client]++;
	else
		g_iFinish_CompareMode[client] = 0;

	SUBMODULE_FINISH(client);
}

/////
//FORMAT
/////
public void Finish_Format(int client, float runtime, float pb_diff, float wr_diff, int zonegroup)
{
	char szCurrentRunFormatted[64];
	char szPBDiffFormatted[64];
	char szWRDiffFormatted[64];

	Format_Time(client, runtime, szCurrentRunFormatted, sizeof szCurrentRunFormatted, true);

	if (g_iFinish_CompareMode[client] == 0) {
		Format_Time(client, pb_diff, szPBDiffFormatted, sizeof szPBDiffFormatted, true);

		if( zonegroup == 0) {
			if( pb_diff >= 0)
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Map Finished in %s | PB +%s", szCurrentRunFormatted, szPBDiffFormatted);
			else
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Map Finished in %s | PB -%s", szCurrentRunFormatted, szPBDiffFormatted);
		}
		else {
			if( pb_diff >= 0)
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Bonus %d Finished in %s | PB +%s", zonegroup, szCurrentRunFormatted, szPBDiffFormatted);
			else
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Bonus %d Finished in %s | PB -%s", zonegroup, szCurrentRunFormatted, szPBDiffFormatted);
		}
	}
	else {
		Format_Time(client, wr_diff, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
		
		if( zonegroup == 0) {
			if (wr_diff >= 0)
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Map Finished in %s | WR +%s", szCurrentRunFormatted, szWRDiffFormatted);
			else
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Map Finished in %s | WR -%s", szCurrentRunFormatted, szWRDiffFormatted);
		}
		else {
			if (wr_diff >= 0)
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Bonus %d Finished in %s | WR +%s", zonegroup, szCurrentRunFormatted, szWRDiffFormatted);
			else
				Format(g_szFINISH_SUBMODULE[client], sizeof g_szFINISH_SUBMODULE, "Bonus %d Finished in %s | WR -%s", zonegroup, szCurrentRunFormatted, szWRDiffFormatted);
		}
	}

	g_fLastDifferenceFinishTime[client] = GetGameTime();
}

/////
//DISPLAY
/////
public void FINISH_Display(int client)
{
    if (!IsFakeClient(client) && g_bFinish[client]) {
		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(target == -1)
			return;

		if (GetGameTime() - g_fLastDifferenceFinishTime[target] < g_iTIMER_HOLDTIME[client]) {
			//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
			for(int i = 0; i < TIMER_SUBMODULES; i++)
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == FINISH_ID)
					Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szFINISH_SUBMODULE[client]);
		}
		else {
			//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
			for(int i = 0; i < TIMER_SUBMODULES; i++)
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == FINISH_ID)
					Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
		}
	}
}

/////
//SQL
/////
public void db_GET_FINISH(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_finish WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadFINISHCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadFINISHCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadFINISHCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bFinish[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
		g_iFinish_CompareMode[client] = SQL_FetchInt(hndl, 2);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_finish (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		FINISH_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (FINISH_ID == g_TIMER_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_FINISH(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_finish SET enabled = '%i', comparetype = '%i'  WHERE steamid = '%s';", g_bFinish[client] ? 1 : 0, g_iFinish_CompareMode[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_FINISHCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_FINISHCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_FINISHCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (FINISH_ID == g_TIMER_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}
