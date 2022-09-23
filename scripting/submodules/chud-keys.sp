public KEYS_SetDefaults(int client)
{
	PrintToServer("Loading KEYS Defaults!");

	g_bKeys[client] = false;
}

public void SUBMODULE_KEYS(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SUBMODULE_KEYS_Handler);
	SetMenuTitle(menu, "Key Options Menu\n \n");

	// Toggle
	if (g_bKeys[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SUBMODULE_KEYS_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: KEYS_Toggle(param1, true);
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
public void KEYS_Toggle(int client, bool from_menu)
{
	if (g_bKeys[client])
		g_bKeys[client] = false;
	else
		g_bKeys[client] = true;

	SUBMODULE_KEYS(client);
}

/////
//DISPLAY
/////
public void KEYS_Display(int client)
{
	if (g_bKeys[client]) {

		if (IsFakeClient(client))
			return;

		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		//KEYS
		int Buttons;
		Buttons = g_iLastButton[target];
		char KEYS[10][5];

		KEYS[0] = (Buttons & IN_FORWARD == IN_FORWARD) ? "W" : "_";
		KEYS[1] = (Buttons & IN_MOVELEFT == IN_MOVELEFT) ? "A" : "_";
		KEYS[2] = (Buttons & IN_BACK == IN_BACK) ? "S" : "_";
		KEYS[3] = (Buttons & IN_MOVERIGHT == IN_MOVERIGHT) ? "D" : "_";
		KEYS[4] = (Buttons & IN_DUCK == IN_DUCK) ? "C" : "_";
		KEYS[5] = (Buttons & IN_JUMP == IN_JUMP) ? "J" : "_";
		KEYS[6] = (Buttons & IN_LEFT == IN_LEFT) ? "←" : "_";
		KEYS[7] = (Buttons & IN_RIGHT == IN_RIGHT) ? "→" : "_";
		KEYS[8] = (g_imouseDir[target][0] < 0)  ? "<" : "_";
		KEYS[9] = (g_imouseDir[target][0] > 0)  ? ">" : "_";

		//FINAL STRING
		Format(g_szKEYS_SUBMODULE[client], sizeof g_szKEYS_SUBMODULE[], "%s %s %s\n%s %s %s\n%s    %s\n%s    %s", KEYS[8], KEYS[0], KEYS[9], KEYS[1], KEYS[2], KEYS[3], KEYS[4], KEYS[5], KEYS[6], KEYS[7]);

		//CHECK IF THIS SUBMODULES ID (TIMER_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
		for(int i = 0; i < INPUT_SUBMODULES; i++)
			if (g_iINPUT_SUBMODULES_INDEXES[client][i] == KEYS_ID)
				Format(g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINPUT_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szKEYS_SUBMODULE[client]);

	}
	else {
		Format(g_szKEYS_SUBMODULE[client], sizeof g_szKEYS_SUBMODULE[], "");
	}
}

/////
//SQL
/////
public void db_GET_KEYS(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_keys WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadKEYSCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadKEYSCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadKEYSCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bKeys[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_keys (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		KEYS_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (KEYS_ID == g_INPUT_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_KEYS(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_keys SET enabled = '%i' WHERE steamid = '%s';", g_bKeys[client] ? 1 : 0, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_KEYSCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_KEYSCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_KEYSCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (KEYS_ID == g_INPUT_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}