public SYNC_SetDefaults(int client)
{
    PrintToServer("Loading SYNC Defaults!");

    g_bSync[client] = false;
}

public void SUBMODULE_SYNC(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SUBMODULE_SYNC_Handler);

	SetMenuTitle(menu, "SYNC Options Menu\n \n");

	// Toggle
	if (g_bSync[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_SYNC_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: SYNC_Toggle(param1, true);
		}
	}
	else if (action == MenuAction_Cancel)
		INPUT_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void SYNC_Toggle(int client, bool from_menu)
{
    if (g_bSync[client])
		g_bSync[client] = false;
	else
		g_bSync[client] = true;

    SUBMODULE_SYNC(client);
}

/////
//DISPlAY
/////
public void SYNC_Display(int client)
{   
    if (g_bSync[client] && !IsFakeClient(client)) {

		int target;
		
		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1 || IsFakeClient(target))
			return;

		Format(g_szSYNC_SUBMODULE[client], sizeof g_szSYNC_SUBMODULE[], "%.2f%", surftimer_GetClientSync(target));
		
		//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
		for(int i = 0; i < INPUT_SUBMODULES; i++)
			if (g_iINPUT_SUBMODULES_INDEXES[client][i] == SYNC_ID)
				Format(g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINPUT_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szSYNC_SUBMODULE[client]);
    }
	else {
		Format(g_szSYNC_SUBMODULE[client], sizeof g_szSYNC_SUBMODULE[], "");
	}
}

/////
//SQL
/////
public void db_GET_SYNC(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_sync WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSYNCCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadSYNCCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadSYNCCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bSync[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_sync (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		SYNC_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (SYNC_ID == g_INPUT_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_SYNC(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_sync SET enabled = '%i' WHERE steamid = '%s';", g_bSync[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_SYNCCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_SYNCCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_SYNCCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (SYNC_ID == g_INPUT_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}