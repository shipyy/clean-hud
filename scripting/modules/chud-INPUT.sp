public Init_INPUT_MODULE(){
	Handle_INPUT_MODULE = CreateHudSynchronizer();
}

public INPUT_SetDefaults(int client)
{
    PrintToServer("Loading INPUT Defaults!");

    g_bINPUT_MODULE[client] = false;
    g_fINPUT_MODULE_POSITION[client][0] = 0.5;
    g_fINPUT_MODULE_POSITION[client][1] = 0.5;

    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            g_iINPUT_MODULE_COLOR[client][i][j] = 255;

    for (int i = 0; i < INPUT_SUBMODULES; i++)
        g_iINPUT_SUBMODULES_INDEXES[client][i] = 0;
}

/////
//MENU
/////
public void INPUT_MENU(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(INPUT_MENU_Handler);
    char szItem[64];

    SetMenuTitle(menu, "INPUT MODULE MENU\n \n");

    // Toggle
    if (g_bINPUT_MODULE[client])
        AddMenuItem(menu, "", "Toggle   | On");
    else
        AddMenuItem(menu, "", "Toggle   | Off");

    // Position
    Format(szItem, sizeof szItem, "Position   | %.2f %.2f", g_fINPUT_MODULE_POSITION[client][0], g_fINPUT_MODULE_POSITION[client][1]);
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

public int INPUT_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 0: INPUT_Toggle(param1);
            case 1: INPUT_Position(param1);
            case 2: INPUT_Color(param1);
            case 3: INPUT_FORMATORDER(param1);
            case 4: INPUT_CUSTOMIZE_SUBMODULES(param1);
            case 5: Export(param1, 3, false, true);
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
public void INPUT_Toggle(int client)
{
    if (g_bINPUT_MODULE[client])
		g_bINPUT_MODULE[client] = false;
	else
		g_bINPUT_MODULE[client] = true;

    INPUT_MENU(client);
}

/////
//POSITION
/////
public void INPUT_Position(int client)
{
	Menu menu = CreateMenu(INPUT_Position_Handler);
	SetMenuTitle(menu, "INPUT | Position\n \n");

	AddMenuItem(menu, "", "Right");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Up");
	AddMenuItem(menu, "", "Down");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INPUT_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: INPUT_PosX(param1, 1);
			case 1: INPUT_PosX(param1, -1);
			case 2: INPUT_PosY(param1, -1);
			case 3: INPUT_PosY(param1, 1);
		}
	}
	else if (action == MenuAction_Cancel)
		INPUT_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void INPUT_PosX(int client, int direction)
{
    switch (direction) {
        case 1 : g_fINPUT_MODULE_POSITION[client][0] = (g_fINPUT_MODULE_POSITION[client][0] + 0.05) > 1.0 ? 1.0 : g_fINPUT_MODULE_POSITION[client][0] + 0.05;
        case -1 : g_fINPUT_MODULE_POSITION[client][0] = (g_fINPUT_MODULE_POSITION[client][0] - 0.05) < 0.0 ? 0.0 : g_fINPUT_MODULE_POSITION[client][0] - 0.05;
    }

    INPUT_Position(client);
}

void INPUT_PosY(int client, int direction)
{
    switch (direction) {
        case 1 : g_fINPUT_MODULE_POSITION[client][1] = (g_fINPUT_MODULE_POSITION[client][1] + 0.05) > 1.0 ? 1.0 : g_fINPUT_MODULE_POSITION[client][1] + 0.05;
        case -1 : g_fINPUT_MODULE_POSITION[client][1] = (g_fINPUT_MODULE_POSITION[client][1] - 0.05) < 0.0 ? 0.0 : g_fINPUT_MODULE_POSITION[client][1] - 0.05;
    }

    INPUT_Position(client);
}

/////
//COLOR
/////
public void INPUT_Color(int client)
{
	Menu menu = CreateMenu(INPUT_Color_Handler);
	char szItem[64];

	SetMenuTitle(menu, "INPUT MODULE | Color\n \n");

	Format(szItem, sizeof szItem, "Gain     | %d %d %d", g_iINPUT_MODULE_COLOR[client][0][0], g_iINPUT_MODULE_COLOR[client][0][1], g_iINPUT_MODULE_COLOR[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Loss     | %d %d %d", g_iINPUT_MODULE_COLOR[client][1][0], g_iINPUT_MODULE_COLOR[client][1][1], g_iINPUT_MODULE_COLOR[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Maintain | %d %d %d", g_iINPUT_MODULE_COLOR[client][2][0], g_iINPUT_MODULE_COLOR[client][2][1], g_iINPUT_MODULE_COLOR[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INPUT_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select) {
        INPUT_Color_Change_MENU(param1, param2);
    }
    else if (action == MenuAction_Cancel)
        INPUT_MENU(param1);
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

public void INPUT_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(INPUT_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Gain Color\n \n");
		case 1: SetMenuTitle(menu, "Loss Color\n \n");
		case 2: SetMenuTitle(menu, "Maintain Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iINPUT_MODULE_COLOR[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iINPUT_MODULE_COLOR[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iINPUT_MODULE_COLOR[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INPUT_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    char szBuffer[32];
    if (action == MenuAction_Select){
        GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
        INPUT_Color_Change(param1, StringToInt(szBuffer), param2);
    }
    else if (action == MenuAction_Cancel) {
        GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
        INPUT_Color(param1);
    }
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

public void INPUT_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 3;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

int[] GetINPUTColour(int client, float sync)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining sync or mainting
	if (RoundToNearest(g_fLastSync[client]) < sync || (g_fLastSync[client] == sync && sync != 0.0) ) {
		displayColor[0] = g_iINPUT_MODULE_COLOR[client][0][0];
		displayColor[1] = g_iINPUT_MODULE_COLOR[client][0][1];
		displayColor[2] = g_iINPUT_MODULE_COLOR[client][0][2];
	}
	//losing sync
	else if (RoundToNearest(g_fLastSync[client]) > sync ) {
		displayColor[0] = g_iINPUT_MODULE_COLOR[client][1][0];
		displayColor[1] = g_iINPUT_MODULE_COLOR[client][1][1];
		displayColor[2] = g_iINPUT_MODULE_COLOR[client][1][2];
	}
	//not moving (sync == 0)
	else {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][2][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][2][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][2][2];
	}

	return displayColor;
}

/////
//FORMAT ORDER
/////
public void INPUT_FORMATORDER(int client)
{
	Menu menu = CreateMenu(INPUT_FORMATORDER_MENU_Handler);

	for(int i = 0; i < INPUT_SUBMODULES; i++)
		AddMenuItem(menu, "", g_szINPUT_SUBMODULE_NAME[getSubModuleID(client, 3, g_iINPUT_SUBMODULES_INDEXES[client][i])]);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INPUT_FORMATORDER_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		CHANGE_INPUT_FORMAT_ID(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		INPUT_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CHANGE_INPUT_FORMAT_ID(int client, int choice)
{
	Menu menu = CreateMenu(CHANGE_INPUT_FORMAT_ID_MENU_Handler);

	char szBuffer[32];

	Format(szBuffer, sizeof szBuffer, "%d", choice);
	AddMenuItem(menu, szBuffer, "None\n \n");

	for(int i = 1; i <= INPUT_SUBMODULES; i++) {
		AddMenuItem(menu, szBuffer, g_szINPUT_SUBMODULE_NAME[i]);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHANGE_INPUT_FORMAT_ID_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char szBuffer[32];
        GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
        g_iINPUT_SUBMODULES_INDEXES[param1][StringToInt(szBuffer)] = param2;
        INPUT_FORMATORDER(param1);
    }
    else if (action == MenuAction_Cancel)
        INPUT_FORMATORDER(param1);
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

/////
//SUBMODULES
/////
public void INPUT_CUSTOMIZE_SUBMODULES(int client)
{
    Menu menu = CreateMenu(INPUT_SUBMODULES_Handler);

    AddMenuItem(menu, "", "Keys");

    AddMenuItem(menu, "", "Sync");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int INPUT_SUBMODULES_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){
        switch (param2) {
            case 0 : SUBMODULE_KEYS(param1);
            case 1 : SUBMODULE_SYNC(param1);
        }
	}
	else if (action == MenuAction_Cancel)
		INPUT_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//DISPLAY
/////
public void INPUT_DISPLAY(int client)
{
	if (g_bINPUT_MODULE[client]  && !IsFakeClient(client)) {

		float posx = g_fINPUT_MODULE_POSITION[client][0] == 0.5 ? -1.0 : g_fINPUT_MODULE_POSITION[client][0];
		float posy = g_fINPUT_MODULE_POSITION[client][1] == 0.5 ? -1.0 : g_fINPUT_MODULE_POSITION[client][1];

		KEYS_Display(client);
		SYNC_Display(client);

		bool bSyncInFormatOrder;

		//CHECK FOR NON-SELECTED SUBMODULES
		for(int i = 0; i < INPUT_SUBMODULES; i++) {
			if (g_iINPUT_SUBMODULES_INDEXES[client][i] == 0)
				Format(g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szINPUT_SUBMODULE_INDEXES_STRINGS[][], "%s", "");
			
			if (g_iINPUT_SUBMODULES_INDEXES[client][i] == SYNC_ID)
				bSyncInFormatOrder = true;
		}


		for(int i = 0; i < INPUT_SUBMODULES; i++) {
			if (i == 0)
				Format(g_szINPUT_MODULE[client], sizeof g_szINPUT_MODULE[], "%s", g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i]);
			else
				Format(g_szINPUT_MODULE[client], sizeof g_szINPUT_MODULE[], "%s\n%s", g_szINPUT_MODULE[client], g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i]);
		}

		if (g_bSync[client] && bSyncInFormatOrder) {
			int displayColor[3];
			displayColor = GetINPUTColour(client, StringToFloat(g_szSYNC_SUBMODULE[client]));

			SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
		}
		else {
			SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate + 0.1, g_iINPUT_MODULE_COLOR[client][2][0], g_iINPUT_MODULE_COLOR[client][2][1], g_iINPUT_MODULE_COLOR[client][2][2], 255, 0, 0.0, 0.0, 0.0);
		}

		ShowSyncHudText(client, Handle_INPUT_MODULE, g_szINPUT_MODULE[client]);
	}
}

/////
//SQL
/////
public void db_LoadINPUT(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_INPUT WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadINPUTCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadINPUTCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadINPUTCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bINPUT_MODULE[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char INPUT_Pos[32];
		char INPUT_Pos_SPLIT[2][16];
		SQL_FetchString(hndl, 2, INPUT_Pos, sizeof INPUT_Pos);
		ExplodeString(INPUT_Pos, "|", INPUT_Pos_SPLIT, sizeof INPUT_Pos_SPLIT, sizeof INPUT_Pos_SPLIT[]);
		g_fINPUT_MODULE_POSITION[client][0] = StringToFloat(INPUT_Pos_SPLIT[0]);
		g_fINPUT_MODULE_POSITION[client][1] = StringToFloat(INPUT_Pos_SPLIT[1]);

		char INPUTColor_SPLIT[3][12];
		//GAIN COLOR
		char INPUTColor_Gain[32];
		SQL_FetchString(hndl, 3, INPUTColor_Gain, sizeof INPUTColor_Gain);
		ExplodeString(INPUTColor_Gain, "|", INPUTColor_SPLIT, sizeof INPUTColor_SPLIT, sizeof INPUTColor_SPLIT[]);
		g_iINPUT_MODULE_COLOR[client][0][0] = StringToInt(INPUTColor_SPLIT[0]);
		g_iINPUT_MODULE_COLOR[client][0][1] = StringToInt(INPUTColor_SPLIT[1]);
		g_iINPUT_MODULE_COLOR[client][0][2] = StringToInt(INPUTColor_SPLIT[2]);

		//LOSS COLOR
		char INPUTColor_Loss[32];
		SQL_FetchString(hndl, 4, INPUTColor_Loss, sizeof INPUTColor_Loss);
		ExplodeString(INPUTColor_Loss, "|", INPUTColor_SPLIT, sizeof INPUTColor_SPLIT, sizeof INPUTColor_SPLIT[]);
		g_iINPUT_MODULE_COLOR[client][1][0] = StringToInt(INPUTColor_SPLIT[0]);
		g_iINPUT_MODULE_COLOR[client][1][1] = StringToInt(INPUTColor_SPLIT[1]);
		g_iINPUT_MODULE_COLOR[client][1][2] = StringToInt(INPUTColor_SPLIT[2]);

		//MAINTAIN COLOR
		char INPUTColor_Maintain[32];
		SQL_FetchString(hndl, 5, INPUTColor_Maintain, sizeof INPUTColor_Maintain);
		ExplodeString(INPUTColor_Maintain, "|", INPUTColor_SPLIT, sizeof INPUTColor_SPLIT, sizeof INPUTColor_SPLIT[]);
		g_iINPUT_MODULE_COLOR[client][2][0] = StringToInt(INPUTColor_SPLIT[0]);
		g_iINPUT_MODULE_COLOR[client][2][1] = StringToInt(INPUTColor_SPLIT[1]);
		g_iINPUT_MODULE_COLOR[client][2][2] = StringToInt(INPUTColor_SPLIT[2]);

		//FORMAT ORDER
		char INPUTFormatOrder[32];
		char INPUTFormatOrder_SPLIT[INPUT_SUBMODULES][12];
		SQL_FetchString(hndl, 6, INPUTFormatOrder, sizeof INPUTFormatOrder);
		ExplodeString(INPUTFormatOrder, "|", INPUTFormatOrder_SPLIT, sizeof INPUTFormatOrder_SPLIT, sizeof INPUTFormatOrder_SPLIT[]);
		for(int i = 0; i < INPUT_SUBMODULES; i++)
			g_iINPUT_SUBMODULES_INDEXES[client][i] = StringToInt(INPUTFormatOrder_SPLIT[i]);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_INPUT (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		INPUT_SetDefaults(client);
	}

	LoadSubModule(client, 3, 1);
}

public void db_SET_INPUT(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[8], szPosY[8];
	char szGain[32];
	char szLoss[32];
	char szMaintain[32];
	char szGain_R[8], szGain_G[8], szGain_B[8];
	char szLoss_R[8], szLoss_G[8], szLoss_B[8];
	char szMaintain_R[8], szMaintain_G[8], szMaintain_B[8];
	char szFormatOrder[32];
	char szFormatOrder_temp[32];

	//POSITION
	Format(szPosX, sizeof szPosX, "%.2f", g_fINPUT_MODULE_POSITION[client][0]);
	Format(szPosY, sizeof szPosY, "%.2f", g_fINPUT_MODULE_POSITION[client][1]);
	Format(szPosition, sizeof szPosition, "%s|%s", szPosX, szPosY);

	//COLORS
	IntToString(g_iINPUT_MODULE_COLOR[client][0][0], szGain_R, sizeof szGain_R);
	IntToString(g_iINPUT_MODULE_COLOR[client][0][1], szGain_G, sizeof szGain_G);
	IntToString(g_iINPUT_MODULE_COLOR[client][0][2], szGain_B, sizeof szGain_B);
	Format(szGain, sizeof szGain, "%s|%s|%s", szGain_R, szGain_G, szGain_B);

	IntToString(g_iINPUT_MODULE_COLOR[client][1][0], szLoss_R, sizeof szLoss_R);
	IntToString(g_iINPUT_MODULE_COLOR[client][1][1], szLoss_G, sizeof szLoss_G);
	IntToString(g_iINPUT_MODULE_COLOR[client][1][2], szLoss_B, sizeof szLoss_B);
	Format(szLoss, sizeof szLoss, "%s|%s|%s", szLoss_R, szLoss_G, szLoss_B);

	IntToString(g_iINPUT_MODULE_COLOR[client][2][0], szMaintain_R, sizeof szMaintain_R);
	IntToString(g_iINPUT_MODULE_COLOR[client][2][1], szMaintain_G, sizeof szMaintain_G);
	IntToString(g_iINPUT_MODULE_COLOR[client][2][2], szMaintain_B, sizeof szMaintain_B);
	Format(szMaintain, sizeof szMaintain, "%s|%s|%s", szMaintain_R, szMaintain_G, szMaintain_B);

	//FORMAT ORDER BY ID
	for(int i = 0; i < INPUT_SUBMODULES; i++) {
		IntToString(g_iINPUT_SUBMODULES_INDEXES[client][i], szFormatOrder_temp, sizeof szFormatOrder_temp);
		Format(szFormatOrder_temp, sizeof szFormatOrder_temp, "%s|", szFormatOrder_temp);
		StrCat(szFormatOrder, sizeof szFormatOrder, szFormatOrder_temp);
	}
	for(int i = 0; i < 32; i++) {
		if (szFormatOrder[i] == '|' && szFormatOrder[i+1] == '\0') {
			szFormatOrder[i] = '\0';
			break;
		}
	}

	Format(szQuery, sizeof szQuery, "UPDATE chud_INPUT SET enabled = '%i', pos = '%s', gaincolor = '%s', losscolor = '%s', maintaincolor = '%s', FormatOrderbyID = '%s' WHERE steamid = '%s';", g_bINPUT_MODULE[client] ? 1 : 0, szPosition, szGain, szLoss, szMaintain, szFormatOrder, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_INPUTCallback, szQuery, client, DBPrio_Low);

}

public void db_SET_INPUTCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_INPUTCallback): %s", error);
		CloseHandle(client);
		return;
	}

	SaveSubModule(client, 3, 1);
}