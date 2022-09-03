public CSD_SetDefaults(int client)
{
	PrintToServer("Loading CSD Defaults!");

	g_bCSD[client] = false;
	g_iCSD_SpeedAxis[client] = 0;
}

public void SUBMODULE_CSD(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_CSD_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Center Speed Options Menu\n \n");

	// Toggle
	if (g_bCSD[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	// AXIS
	Format(szItem, sizeof szItem, "Axis | %d", g_iCSD_SpeedAxis[client]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CSD_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CSD_Toggle(param1);
			case 1: CSD_Axis(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void CSD_Toggle(int client)
{
    if (g_bCSD[client])
		g_bCSD[client] = false;
	else
		g_bCSD[client] = true;

    SUBMODULE_CSD(client);
}

/////
//AXIS
/////
void CSD_Axis(int client)
{
	if (g_iCSD_SpeedAxis[client] != 2)
		g_iCSD_SpeedAxis[client]++;
	else
		g_iCSD_SpeedAxis[client] = 0;

	SUBMODULE_CSD(client);
}

/////
//MISC
////
int[] GetSpeedColourCSD(int client, float speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) ) {
		displayColor[0] = g_szSPEED_MODULE[client][0][0];
		displayColor[1] = g_szSPEED_MODULE[client][0][1];
		displayColor[2] = g_szSPEED_MODULE[client][0][2];
	}
	//losing speed
	else if (g_fLastSpeed[client] > speed ) {
		displayColor[0] = g_szSPEED_MODULE[client][1][0];
		displayColor[1] = g_szSPEED_MODULE[client][1][1];
		displayColor[2] = g_szSPEED_MODULE[client][1][2];
	}
	//not moving (speed == 0)
	else {
		displayColor[0] = g_szSPEED_MODULE[client][2][0];
		displayColor[1] = g_szSPEED_MODULE[client][2][1];
		displayColor[2] = g_szSPEED_MODULE[client][2][2];
	}

	g_fLastSpeed[client] = speed;

	return displayColor;
}

/////
//DISPLAY
/////
public void CSD_Format(int client)
{
	if (g_bCSD[client] && !IsFakeClient(client)) {
		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		int target_style = surftimer_GetClientStyle(target);
		if (target_style == 5)
			g_fLastSpeed[target] /= 0.5;
		else if (target_style == 6)
			g_fLastSpeed[target] /= 1.5;

		Format(g_szCSD_SUBMODULE[client], sizeof g_szCSD_SUBMODULE, "%d", RoundToNearest(g_fLastSpeed[target]));

		//CHECK IF THIS SUBMODULES ID (CSD_ID -> 1) IS IN THE ORDER ID ARRAY OF ITS MODULE
		for(int i = 0; i < SPEED_SUBMODULES; i++)
			if (g_iSPEED_SUBMODULES_INDEXES[client][i] == CSD_ID)
				Format(g_szSPEED_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szSPEED_SUBMODULE_INDEXES_STRINGS[][], "%s", g_szCSD_SUBMODULE[client]);
	}
	else {
		Format(g_szCSD_SUBMODULE[client], sizeof g_szCSD_SUBMODULE, "");
	}
}

/////
//SQL
/////
public void db_GET_CSD(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_sub_CSD WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadCSDCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_LoadCSDCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadCSDCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bCSD[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
		g_iCSD_SpeedAxis[client] = SQL_FetchInt(hndl, 2);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_sub_CSD (steamid) VALUES('%s','%i','%i')", g_szSteamID[client], 0, 0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		CSD_SetDefaults(client);
	}

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (CSD_ID == g_SPEED_SUBMODULES)
		LoadModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		LoadSubModule(client, module, submodule + 1);
}

public void db_SET_CSD(int client, int module, int submodule)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(module);
	pack.WriteCell(submodule);

	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_sub_CSD SET enabled = '%i', speedaxis = '%i'  WHERE steamid = '%s';", g_bCSD[client] ? '1' : '0', g_iCSD_SpeedAxis[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_CSDCallback, szQuery, pack, DBPrio_Low);
}

public void db_SET_CSDCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SET_CSDCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int module = ReadPackCell(pack);
	int submodule = ReadPackCell(pack);
	CloseHandle(pack);

	//IF THIS IS THE LAST SUBMODULE GO TO THE NEXT MODULE
	if (CSD_ID == g_SPEED_SUBMODULES)
		SaveModule(client, module + 1);
	//OTHERWISE CONTINUE TO THE NEXT SUBMODULE
	else
		SaveSubModule(client, module, submodule + 1);
}