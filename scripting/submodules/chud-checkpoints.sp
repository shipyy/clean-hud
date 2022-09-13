public CP_SetDefaults(int client)
{
	PrintToServer("Loading CP Defaults!");

	g_bCP[client] = false;
	g_iCP_CompareMode[client] = 1;
}

public void SUBMODULE_CP(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SUBMODULE_CP_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Checkpoints Options Menu\n \n");

	// Toggle
	if (g_bCP[client])
		AddMenuItem(menu, "", "Toggle     | On");
	else
		AddMenuItem(menu, "", "Toggle     | Off");

	// Compare Mode
	Format(szItem, sizeof szItem, "Compare  | %s", g_iCP_CompareMode[client] == 0 ? "PB\n \n" : "WR\n \n");
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_CP_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CP_Toggle(param1);
			case 1: CP_CompareMode(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		TIMER_CUSTOMIZE_SUBMODULES(param1);
	else if (action == MenuAction_End) {
		delete menu;
	}

	return 0;
}

/////
//TOGGLE
/////
public void CP_Toggle(int client)
{
    if (g_bCP[client])
		g_bCP[client] = false;
	else
		g_bCP[client] = true;

    SUBMODULE_CP(client);
}

/////
//COMPARE MODE
/////
void CP_CompareMode(int client)
{
	if (g_iCP_CompareMode[client] != 1)
		g_iCP_CompareMode[client]++;
	else
		g_iCP_CompareMode[client] = 0;

	SUBMODULE_CP(client);
}

/////
//FORMAT
/////
public void CP_Format(int client, float runtime, float pb_runtime, float wr_runtime)
{
	char szPBFormatted[32];
	char szWRFormatted[32];

	if (g_iCP_CompareMode[client] == 0) {

		if (pb_runtime != -1.0) {

			Format_Time(client, runtime - pb_runtime, szPBFormatted, sizeof szPBFormatted, true);

			if (pb_runtime - runtime > 0) {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "PB -%s", szPBFormatted);
			}
			else if (pb_runtime - runtime < 0) {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "PB +%s", szPBFormatted);
			}
			else {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "PB %s", szPBFormatted);
			}
		}
		else {
			Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "PB N/A");
		}

	}
	else {
		if (wr_runtime != 0.0) {

			Format_Time(client, runtime - wr_runtime, szWRFormatted, sizeof szWRFormatted, true);

			if (wr_runtime - runtime > 0) {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "WR -%s", szWRFormatted);
			}
			else if (wr_runtime - runtime < 0) {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "WR +%s", szWRFormatted);
			}
			else {
				Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "WR %s", szWRFormatted);
			}

		}
		else {
			Format(g_szCP_SUBMODULE[client], sizeof g_szCP_SUBMODULE, "WR N/A");
		}
	}

	g_fLastDifferenceTime[client] = GetGameTime();
}

/////
//DISPLAY
/////
public void CP_Display(int client)
{
	if (g_bCP[client]) {
		
		if (IsFakeClient(client))
			return;

		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		if (GetGameTime() - g_fLastDifferenceTime[target] < g_iTIMER_HOLDTIME[client]) {
			//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
			for(int i = 0; i < TIMER_SUBMODULES; i++)
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == CHECKPOINTS_ID)
					Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szCP_SUBMODULE[client]);
		}
		else {
			//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
			for(int i = 0; i < TIMER_SUBMODULES; i++)
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == CHECKPOINTS_ID)
					Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
		}
	}
}

/////
//SQL
/////
public void db_GET_CP(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_checkpoints WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadCPCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadCPCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadCPCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bCP[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
		g_iCP_CompareMode[client] = SQL_FetchInt(hndl, 2);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_checkpoints (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		CP_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (CHECKPOINTS_ID == g_TIMER_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_CP(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_checkpoints SET enabled = '%i', comparetype = '%i' WHERE steamid = '%s';", g_bCP[client] ? 1 : 0,  g_iCP_CompareMode[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_CPCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_CPCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_CPCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (CHECKPOINTS_ID == g_TIMER_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}