public OPTIONS_SetDefaults(int client)
{
    PrintToServer("Loading OPTIONS Defaults!");

    g_iRefreshRate[client] = 1;
    g_iRefreshRateValue[client] = 10;
}

/////
//MENU
/////
public void OPTIONS_MENU(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(OPTIONS_MENU_Handler);

	SetMenuTitle(menu, "OPTIONS MODULE MENU\n \n");
    
	//Update Rate
	if (g_iRefreshRate[client] == 0)
		AddMenuItem(menu, "", "Update Rate | Slow");
	else if (g_iRefreshRate[client] == 1)
		AddMenuItem(menu, "", "Update Rate | Medium");
	else
		AddMenuItem(menu, "", "Update Rate | Fast");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int OPTIONS_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: OPTIONS_Refresh(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_MainMenu_Display(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void OPTIONS_Refresh(int client)
{
    if (g_iRefreshRate[client] != 2)
		g_iRefreshRate[client]++;
	else
		g_iRefreshRate[client] = 0;
    
    switch (g_iRefreshRate[client]) {
        case 0 : g_iRefreshRateValue[client] = 15;
        case 1 : g_iRefreshRateValue[client] = 10;
        case 2 : g_iRefreshRateValue[client] = 5;
    }

    OPTIONS_MENU(client);
}

public void db_LoadOPTIONS(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_OPTIONS WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadOPTIONSCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadOPTIONSCallback(Handle owner, Handle hndl, const char[] error, any client)
{
    if (hndl == null)
    {
        LogError("[Clean HUD] SQL Error (SQL_LoadOPTIONSCallback): %s", error);
        return;
    }

    if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

        g_iRefreshRate[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

        switch (g_iRefreshRate[client]) {
            case 0 : g_iRefreshRateValue[client] = 15;
            case 1 : g_iRefreshRateValue[client] = 10;
            case 2 : g_iRefreshRateValue[client] = 5;
        }

    }
    else {
        char szQuery[1024];
        Format(szQuery, sizeof szQuery, "INSERT INTO chud_OPTIONS (steamid) VALUES('%s')", g_szSteamID[client]);
        SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

        OPTIONS_SetDefaults(client);
    }

    LoadModule(client, 1);
}

public void db_SET_OPTIONS(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "UPDATE chud_OPTIONS SET refreshrate = '%i' WHERE steamid = '%s';", g_iRefreshRate[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_OPTIONSCallback, szQuery, client, DBPrio_Low);

}

public void db_SET_OPTIONSCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_OPTIONSCallback): %s", error);
		CloseHandle(client);
		return;
	}

	SaveModule(client, 1);
}