public Init_INFO_MODULE(){
	Handle_INFO_MODULE = CreateHudSynchronizer();
}

public INFO_SetDefaults(int client)
{
    PrintToServer("Loading INFO Defaults!");

    g_bINFO_MODULE[client] = false;
    g_fINFO_MODULE_POSITION[client][0] = 0.5;
    g_fINFO_MODULE_POSITION[client][1] = 0.5;

    for (int i = 0; i < 3; i++)
        g_iINFO_MODULE_COLOR[client][i] = 255;

    for (int i = 0; i < INFO_SUBMODULES; i++)
		g_iINFO_SUBMODULES_INDEXES[client][i] = 0;
}

/////
//MENU
/////
public void INFO_MENU(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(INFO_MENU_Handler);
    char szItem[64];

    SetMenuTitle(menu, "INFO MODULE MENU\n \n");

    // Toggle
    if (g_bINFO_MODULE[client])
        AddMenuItem(menu, "", "Toggle   | On");
    else
        AddMenuItem(menu, "", "Toggle   | Off");

    // Position
    Format(szItem, sizeof szItem, "Position   | %.2f %.2f", g_fINFO_MODULE_POSITION[client][0], g_fINFO_MODULE_POSITION[client][1]);
    AddMenuItem(menu, "", szItem);

    // Color
    Format(szItem, sizeof szItem, "Color\n \n");
    AddMenuItem(menu, "", szItem);

    // FORMAT ORDER
    Format(szItem, sizeof szItem, "Format Order");
    AddMenuItem(menu, "", szItem);

    // SUB MODULES
    Format(szItem, sizeof szItem, "Customize Submodules\n \n");
    AddMenuItem(menu, "", szItem);

    // EXPORT
    Format(szItem, sizeof szItem, "Export");
    AddMenuItem(menu, "", szItem);

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INFO_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 0: INFO_Toggle(param1);
            case 1: INFO_Position(param1);
            case 2: INFO_Color(param1);
            case 3: INFO_FORMATORDER(param1);
            case 4: INFO_CUSTOMIZE_SUBMODULES(param1);
            case 5: Export(param1, 4, false, true);
        }
    }
    else if (action == MenuAction_Cancel) {
        CHUD_MainMenu_Display(param1);
    }
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

/////
//TOGGLE
/////
public void INFO_Toggle(int client)
{
    if (g_bINFO_MODULE[client])
		g_bINFO_MODULE[client] = false;
	else
		g_bINFO_MODULE[client] = true;

    INFO_MENU(client);
}

/////
//POSITION
/////
public void INFO_Position(int client)
{
	Menu menu = CreateMenu(INFO_Position_Handler);
	SetMenuTitle(menu, "INFO | Position\n \n");

	AddMenuItem(menu, "", "Right");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Up");
	AddMenuItem(menu, "", "Down");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INFO_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: INFO_PosX(param1, 1);
			case 1: INFO_PosX(param1, -1);
			case 2: INFO_PosY(param1, -1);
			case 3: INFO_PosY(param1, 1);
		}
	}
	else if (action == MenuAction_Cancel)
		INFO_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void INFO_PosX(int client, int direction)
{
    switch (direction) {
        case 1 : g_fINFO_MODULE_POSITION[client][0] = (g_fINFO_MODULE_POSITION[client][0] + 0.05) > 1.0 ? 1.0 : g_fINFO_MODULE_POSITION[client][0] + 0.05;
        case -1 : g_fINFO_MODULE_POSITION[client][0] = (g_fINFO_MODULE_POSITION[client][0] - 0.05) < 0.0 ? 0.0 : g_fINFO_MODULE_POSITION[client][0] - 0.05;
    }

    INFO_Position(client);
}

void INFO_PosY(int client, int direction)
{
    switch (direction) {
        case 1 : g_fINFO_MODULE_POSITION[client][1] = (g_fINFO_MODULE_POSITION[client][1] + 0.05) > 1.0 ? 1.0 : g_fINFO_MODULE_POSITION[client][1] + 0.05;
        case -1 : g_fINFO_MODULE_POSITION[client][1] = (g_fINFO_MODULE_POSITION[client][1] - 0.05) < 0.0 ? 0.0 : g_fINFO_MODULE_POSITION[client][1] - 0.05;
    }

    INFO_Position(client);
}

/////
//COLOR
/////
public void INFO_Color(int client)
{
    Menu menu = CreateMenu(INFO_Color_Change_Handler);
    SetMenuTitle(menu, "INFO | Color\n \n");

    //COLOR OPTIONS

    char szItemDisplay[32];

    Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iINFO_MODULE_COLOR[client][0]);
    AddMenuItem(menu, "", szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iINFO_MODULE_COLOR[client][1]);
    AddMenuItem(menu, "", szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iINFO_MODULE_COLOR[client][2]);
    AddMenuItem(menu, "", szItemDisplay);

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INFO_Color_Change_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		INFO_Color_Change(param1, param2);
	else if (action == MenuAction_Cancel)
		INFO_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void INFO_Color_Change(int client, int color_index)
{
    CPrintToChat(client, "%t", "Color_Input");
    g_iArrayToChange[client] = 4;
    g_iColorIndex[client] = color_index;
    g_iWaitingForResponse[client] = ChangeColor;
}

/////
//FORMAT ORDER
/////
public void INFO_FORMATORDER(int client)
{
	Menu menu = CreateMenu(INFO_FORMATORDER_MENU_Handler);

	for(int i = 0; i < INFO_SUBMODULES; i++)
		AddMenuItem(menu, "", g_szINFO_SUBMODULE_NAME[getSubModuleID(client, 4, g_iINFO_SUBMODULES_INDEXES[client][i])]);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INFO_FORMATORDER_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		CHANGE_INFO_FORMAT_ID(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		INFO_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CHANGE_INFO_FORMAT_ID(int client, int choice)
{
	Menu menu = CreateMenu(CHANGE_INFO_FORMAT_ID_MENU_Handler);

	char szBuffer[32];

	Format(szBuffer, sizeof szBuffer, "%d", choice);
	AddMenuItem(menu, szBuffer, "None\n \n");

	for(int i = 1; i <= TIMER_SUBMODULES; i++) {
		AddMenuItem(menu, szBuffer, g_szINFO_SUBMODULE_NAME[i]);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHANGE_INFO_FORMAT_ID_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char szBuffer[32];
        GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
        g_iINFO_SUBMODULES_INDEXES[param1][StringToInt(szBuffer)] = param2;
        INFO_FORMATORDER(param1);
    }
    else if (action == MenuAction_Cancel)
        INFO_FORMATORDER(param1);
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

/////
//SUBMODULES
/////
public void INFO_CUSTOMIZE_SUBMODULES(int client)
{
    Menu menu = CreateMenu(INFO_SUBMODULES_Handler);

    AddMenuItem(menu, "", "Map Info");

    AddMenuItem(menu, "", "Stage Info");

    AddMenuItem(menu, "", "Stage Indicator");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INFO_SUBMODULES_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){
        switch (param2) {
            case 0 : SUBMODULE_MAPINFO(param1);
            case 1 : SUBMODULE_STAGEINFO(param1);
            case 2 : SUBMODULE_STAGEINDICATOR(param1);
        }
	}
	else if (action == MenuAction_Cancel)
		INFO_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//DISPLAY
/////
public void INFO_DISPLAY(int client)
{
    if (g_bINFO_MODULE[client]  && !IsFakeClient(client)) {

        float posx = g_fINFO_MODULE_POSITION[client][0] == 0.5 ? -1.0 : g_fINFO_MODULE_POSITION[client][0];
        float posy = g_fINFO_MODULE_POSITION[client][1] == 0.5 ? -1.0 : g_fINFO_MODULE_POSITION[client][1];

        MAPINFO_Display(client);
        STAGEINFO_Display(client);
        STAGEINDICATOR_Display(client);

        //CHECK FOR NON-SELECTED SUBMODULES
        for(int i = 0; i < INFO_SUBMODULES; i++)
            if (g_iINFO_SUBMODULES_INDEXES[client][i] == 0)
                Format(g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINFO_SUBMODULE_INDEXES_STRINGS[][], "%s", "");


        for(int i = 0; i < INFO_SUBMODULES; i++) {
            if (i == 0)
                Format(g_szINFO_MODULE[client], sizeof g_szINFO_MODULE[], "%s", g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i]);
            else
                Format(g_szINFO_MODULE[client], sizeof g_szINFO_MODULE[], "%s\n%s", g_szINFO_MODULE[client], g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i]);
        }

        SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate + 0.1, g_iINFO_MODULE_COLOR[client][0], g_iINFO_MODULE_COLOR[client][1], g_iINFO_MODULE_COLOR[client][2], 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudText(client, Handle_INFO_MODULE, g_szINFO_MODULE[client]);
    }
}

/////
//SQL
/////
public void db_LoadINFO(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_INFO WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadINFOCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadINFOCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadINFOCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bINFO_MODULE[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char INFO_Pos[32];
		char INFO_Pos_SPLIT[2][16];
		SQL_FetchString(hndl, 2, INFO_Pos, sizeof INFO_Pos);
		ExplodeString(INFO_Pos, "|", INFO_Pos_SPLIT, sizeof INFO_Pos_SPLIT, sizeof INFO_Pos_SPLIT[]);
		g_fINFO_MODULE_POSITION[client][0] = StringToFloat(INFO_Pos_SPLIT[0]);
		g_fINFO_MODULE_POSITION[client][1] = StringToFloat(INFO_Pos_SPLIT[1]);

		char INFOColor_SPLIT[3][12];
		//GAIN COLOR
		char INFOColor_Gain[32];
		SQL_FetchString(hndl, 3, INFOColor_Gain, sizeof INFOColor_Gain);
		ExplodeString(INFOColor_Gain, "|", INFOColor_SPLIT, sizeof INFOColor_SPLIT, sizeof INFOColor_SPLIT[]);
		g_iINFO_MODULE_COLOR[client][0] = StringToInt(INFOColor_SPLIT[0]);
		g_iINFO_MODULE_COLOR[client][1] = StringToInt(INFOColor_SPLIT[1]);
		g_iINFO_MODULE_COLOR[client][2] = StringToInt(INFOColor_SPLIT[2]);

		//FORMAT ORDER
		char INFOFormatOrder[32];
		char INFOFormatOrder_SPLIT[INFO_SUBMODULES][12];
		SQL_FetchString(hndl, 4, INFOFormatOrder, sizeof INFOFormatOrder);
		ExplodeString(INFOFormatOrder, "|", INFOFormatOrder_SPLIT, sizeof INFOFormatOrder_SPLIT, sizeof INFOFormatOrder_SPLIT[]);
		for(int i = 0; i < INFO_SUBMODULES; i++)
			g_iINFO_SUBMODULES_INDEXES[client][i] = StringToInt(INFOFormatOrder_SPLIT[i]);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_INFO (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		INFO_SetDefaults(client);
	}

	LoadSubModule(client, 4, 1);
}

public void db_SET_INFO(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[8], szPosY[8];
	char szColor[24];
	char szColor_R[8], szColor_G[8], szColor_B[8];
	char szFormatOrder[32];
	char szFormatOrder_temp[32];

	//POSITION
	Format(szPosX, sizeof szPosX, "%.2f", g_fINFO_MODULE_POSITION[client][0]);
	Format(szPosY, sizeof szPosY, "%.2f", g_fINFO_MODULE_POSITION[client][1]);
	Format(szPosition, sizeof szPosition, "%s|%s", szPosX, szPosY);

	//COLORS
	IntToString(g_iINFO_MODULE_COLOR[client][0], szColor_R, sizeof szColor_R);
	IntToString(g_iINFO_MODULE_COLOR[client][1], szColor_G, sizeof szColor_G);
	IntToString(g_iINFO_MODULE_COLOR[client][2], szColor_B, sizeof szColor_B);
	Format(szColor, sizeof szColor, "%s|%s|%s", szColor_R, szColor_G, szColor_B);

	//FORMAT ORDER BY ID
	for(int i = 0; i < INFO_SUBMODULES; i++) {
		IntToString(g_iINFO_SUBMODULES_INDEXES[client][i], szFormatOrder_temp, sizeof szFormatOrder_temp);
		Format(szFormatOrder_temp, sizeof szFormatOrder_temp, "%s|", szFormatOrder_temp);
		StrCat(szFormatOrder, sizeof szFormatOrder, szFormatOrder_temp);
	}
	for(int i = 0; i < 32; i++) {
		if (szFormatOrder[i] == '|' && szFormatOrder[i+1] == '\0') {
			szFormatOrder[i] = '\0';
			break;
		}
	}

	Format(szQuery, sizeof szQuery, "UPDATE chud_INFO SET enabled = '%i', pos = '%s', color = '%s', FormatOrderbyID = '%s' WHERE steamid = '%s';", g_bINFO_MODULE[client] ? 1 : 0, szPosition, szColor, szFormatOrder, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_INFOCallback, szQuery, client, DBPrio_Low);

}

public void db_SET_INFOCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_INFOCallback): %s", error);
		CloseHandle(client);
		return;
	}

	SaveSubModule(client, 4, 1);
}