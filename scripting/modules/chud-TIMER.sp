public Init_TIMER_MODULE(){
	Handle_TIMER_MODULE = CreateHudSynchronizer();
}

public TIMER_SetDefaults(int client)
{
	PrintToServer("Loading TIMER Defaults!");

	g_bTIMER_MODULE[client] = false;
	g_fTIMER_MODULE_POSITION[client][0] = 0.5;
	g_fTIMER_MODULE_POSITION[client][1] = 0.5;

	g_iTIMER_HOLDTIME[client] = 3;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iTIMER_MODULE_COLOR[client][i][j] = 255;

	for (int i = 0; i < TIMER_SUBMODULES; i++)
		g_iTIMER_SUBMODULES_INDEXES[client][i] = 0;
}

/////
//MENU
/////
public void TIMER_MENU(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(TIMER_MENU_Handler);
    char szItem[128];

    SetMenuTitle(menu, "TIMER MODULE MENU\n \n");

    // Toggle
    if (g_bTIMER_MODULE[client])
        AddMenuItem(menu, "", "Toggle   | On");
    else
        AddMenuItem(menu, "", "Toggle   | Off");

    // Position
    Format(szItem, sizeof szItem, "Position   | %.2f %.2f", g_fTIMER_MODULE_POSITION[client][0], g_fTIMER_MODULE_POSITION[client][1]);
    AddMenuItem(menu, "", szItem);

    // Color
    Format(szItem, sizeof szItem, "Color\n \n");
    AddMenuItem(menu, "", szItem);

    // Hold Time
    Format(szItem, sizeof szItem, "Hold         | %d", g_iTIMER_HOLDTIME[client]);
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

    g_bEditing[client][1] = true;

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 0: TIMER_Toggle(param1);
            case 1: TIMER_Position(param1);
            case 2: TIMER_Color(param1);
            case 3: TIMER_HoldTime(param1); 
            case 4: TIMER_FORMATORDER(param1);
            case 5: TIMER_CUSTOMIZE_SUBMODULES(param1);
            case 6: Export(param1, 2, false, true);
        }
    }
    else if (action == MenuAction_Cancel) {
        g_bEditing[param1][1] = false;
        CHUD_MainMenu_Display(param1);
    }
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

/////
//HOLD TIME
/////
void TIMER_HoldTime(int client)
{
	if (g_iTIMER_HOLDTIME[client] < 5)
		g_iTIMER_HOLDTIME[client]++;
	else
		g_iTIMER_HOLDTIME[client] = 0;

	TIMER_MENU(client);
}

/////
//TOGGLE
/////
public void TIMER_Toggle(int client)
{
    if (g_bTIMER_MODULE[client])
		g_bTIMER_MODULE[client] = false;
	else
		g_bTIMER_MODULE[client] = true;

    TIMER_MENU(client);
}

/////
//POSITION
/////
public void TIMER_Position(int client)
{
	Menu menu = CreateMenu(TIMER_Position_Handler);
	SetMenuTitle(menu, "TIMER | Position\n \n");

	AddMenuItem(menu, "", "Right");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Up");
	AddMenuItem(menu, "", "Down");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: TIMER_PosX(param1, 1);
			case 1: TIMER_PosX(param1, -1);
			case 2: TIMER_PosY(param1, -1);
			case 3: TIMER_PosY(param1, 1);
		}
	}
	else if (action == MenuAction_Cancel)
		TIMER_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void TIMER_PosX(int client, int direction)
{
    switch (direction) {
        case 1 : g_fTIMER_MODULE_POSITION[client][0] = (g_fTIMER_MODULE_POSITION[client][0] + 0.05) > 1.0 ? 1.0 : g_fTIMER_MODULE_POSITION[client][0] + 0.05;
        case -1 : g_fTIMER_MODULE_POSITION[client][0] = (g_fTIMER_MODULE_POSITION[client][0] - 0.05) < 0.0 ? 0.0 : g_fTIMER_MODULE_POSITION[client][0] - 0.05;
    }

    TIMER_Position(client);
}

void TIMER_PosY(int client, int direction)
{
    switch (direction) {
        case 1 : g_fTIMER_MODULE_POSITION[client][1] = (g_fTIMER_MODULE_POSITION[client][1] + 0.05) > 1.0 ? 1.0 : g_fTIMER_MODULE_POSITION[client][1] + 0.05;
        case -1 : g_fTIMER_MODULE_POSITION[client][1] = (g_fTIMER_MODULE_POSITION[client][1] - 0.05) < 0.0 ? 0.0 : g_fTIMER_MODULE_POSITION[client][1] - 0.05;
    }

    TIMER_Position(client);
}

/////
//COLOR
/////
public void TIMER_Color(int client)
{
	Menu menu = CreateMenu(TIMER_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "TIMER MODULE | Color\n \n");

	Format(szItem, sizeof szItem, "Gain     | %d %d %d", g_iTIMER_MODULE_COLOR[client][0][0], g_iTIMER_MODULE_COLOR[client][0][1], g_iTIMER_MODULE_COLOR[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Loss     | %d %d %d", g_iTIMER_MODULE_COLOR[client][1][0], g_iTIMER_MODULE_COLOR[client][1][1], g_iTIMER_MODULE_COLOR[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Maintain | %d %d %d", g_iTIMER_MODULE_COLOR[client][2][0], g_iTIMER_MODULE_COLOR[client][2][1], g_iTIMER_MODULE_COLOR[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select) {
        g_bEditingColor[param1][param2] = true;
        TIMER_Color_Change_MENU(param1, param2);
    }
    else if (action == MenuAction_Cancel)
        TIMER_MENU(param1);
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

public void TIMER_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(TIMER_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Gain Color\n \n");
		case 1: SetMenuTitle(menu, "Loss Color\n \n");
		case 2: SetMenuTitle(menu, "Maintain Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iTIMER_MODULE_COLOR[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iTIMER_MODULE_COLOR[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iTIMER_MODULE_COLOR[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	char szBuffer[32];
	if (action == MenuAction_Select){
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		TIMER_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel) {
		GetMenuItem(menu, 0, szBuffer, sizeof(szBuffer));
		g_bEditingColor[param1][StringToInt(szBuffer)] = false;
		TIMER_Color(param1);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void TIMER_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 2;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//FORMAT ORDER
/////
public void TIMER_FORMATORDER(int client)
{
	Menu menu = CreateMenu(TIMER_FORMATORDER_MENU_Handler);

	for(int i = 0; i < TIMER_SUBMODULES; i++)
		AddMenuItem(menu, "", g_szTIMER_SUBMODULE_NAME[getSubModuleID(client, 2, g_iTIMER_SUBMODULES_INDEXES[client][i])]);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_FORMATORDER_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		CHANGE_TIMER_FORMAT_ID(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		TIMER_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CHANGE_TIMER_FORMAT_ID(int client, int choice)
{
	Menu menu = CreateMenu(CHANGE_TIMER_FORMAT_ID_MENU_Handler);

	char szBuffer[32];

	Format(szBuffer, sizeof szBuffer, "%d", choice);
	AddMenuItem(menu, szBuffer, "None\n \n");

	for(int i = 1; i <= TIMER_SUBMODULES; i++) {
		AddMenuItem(menu, szBuffer, g_szTIMER_SUBMODULE_NAME[i]);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHANGE_TIMER_FORMAT_ID_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char szBuffer[32];
        GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
        g_iTIMER_SUBMODULES_INDEXES[param1][StringToInt(szBuffer)] = param2;
        TIMER_FORMATORDER(param1);
    }
    else if (action == MenuAction_Cancel)
        TIMER_FORMATORDER(param1);
    else if (action == MenuAction_End)
        delete menu;

    return 0;
}

/////
//SUBMODULES
/////
public void TIMER_CUSTOMIZE_SUBMODULES(int client)
{
    Menu menu = CreateMenu(TIMER_SUBMODULES_Handler);

    AddMenuItem(menu, "", "Stopwatch");

    AddMenuItem(menu, "", "Checkpoints");

    AddMenuItem(menu, "", "Finish");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TIMER_SUBMODULES_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){
        switch (param2) {
            case 0 : SUBMODULE_STOPWATCH(param1);
            case 1 : SUBMODULE_CP(param1);
            case 2 : SUBMODULE_FINISH(param1);
        }
	}
	else if (action == MenuAction_Cancel)
		TIMER_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//DISPLAY
/////
public void TIMER_DISPLAY(int client)
{
	if ((g_bTIMER_MODULE[client] || g_bEditing[client][1]) && !IsFakeClient(client)) {

		float posx = g_fTIMER_MODULE_POSITION[client][0] == 0.5 ? -1.0 : g_fTIMER_MODULE_POSITION[client][0];
		float posy = g_fTIMER_MODULE_POSITION[client][1] == 0.5 ? -1.0 : g_fTIMER_MODULE_POSITION[client][1];

		STOPWATCH_Format(client);
		CP_Display(client);
		FINISH_Display(client);

		//CHECK FOR NON-SELECTED SUBMODULES
		for(int i = 0; i < TIMER_SUBMODULES; i++)
			if (g_iTIMER_SUBMODULES_INDEXES[client][i] == 0)
				Format(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szTIMER_SUBMODULE_INDEXES_STRINGS[][], "%s", "");


		for(int i = 0; i < TIMER_SUBMODULES; i++) {
			if (i == 0)
				Format(g_szTIMER_MODULE[client], sizeof g_szTIMER_MODULE[], "%s", g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i]);
			else
				Format(g_szTIMER_MODULE[client], sizeof g_szTIMER_MODULE[], "%s\n%s", g_szTIMER_MODULE[client], g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i]);
		}

		if (g_bEditing[client][1]) {

			if (g_bEditingColor[client][0]) {
				SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][0][0], g_iTIMER_MODULE_COLOR[client][0][1], g_iTIMER_MODULE_COLOR[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][1]) {
				SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][1][0], g_iTIMER_MODULE_COLOR[client][1][1], g_iTIMER_MODULE_COLOR[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][2]) {
				SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][2][0], g_iTIMER_MODULE_COLOR[client][2][1], g_iTIMER_MODULE_COLOR[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
			}

			char szTemp[3][128];

			for(int i = 0; i < TIMER_SUBMODULES; i++) {
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == CHECKPOINTS_ID)
					szTemp[i] = "WR +00:00.000";
				else if (g_iTIMER_SUBMODULES_INDEXES[client][i] == FINISH_ID)
					szTemp[i] = "Map Finished in 12:34:567 | WR +12:34:567";
				else
					szTemp[i] = g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i];
			}

			ShowSyncHudText(client, Handle_TIMER_MODULE, "%s\n%s\n%s", szTemp[0], szTemp[1], szTemp[2]);
			return;
		}

		if (g_bCP[client]) {
			for(int i = 0; i < TIMER_SUBMODULES; i++) {
				if (g_iTIMER_SUBMODULES_INDEXES[client][i] == CHECKPOINTS_ID) {
					if (StrContains(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], "-", false) != -1) {
						SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][0][0], g_iTIMER_MODULE_COLOR[client][0][1], g_iTIMER_MODULE_COLOR[client][0][2], 255, 0, 0.0, 0.0, 0.0);
						break;
					}
					else if (StrContains(g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i], "+", false) != -1) {
						SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][1][0], g_iTIMER_MODULE_COLOR[client][1][1], g_iTIMER_MODULE_COLOR[client][1][2], 255, 0, 0.0, 0.0, 0.0);
						break;
					}
					else {
						SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][2][0], g_iTIMER_MODULE_COLOR[client][2][1], g_iTIMER_MODULE_COLOR[client][2][2], 255, 0, 0.0, 0.0, 0.0);
						break;
					}
				}
			}
		}
		else {
			SetHudTextParams(posx, posy, g_iRefreshRateValue[client] / g_fTickrate, g_iTIMER_MODULE_COLOR[client][2][0], g_iTIMER_MODULE_COLOR[client][2][1], g_iTIMER_MODULE_COLOR[client][2][2], 255, 0, 0.0, 0.0, 0.0);
		}

		ShowSyncHudText(client, Handle_TIMER_MODULE, g_szTIMER_MODULE[client]);
	}
}

/////
//SQL
/////
public void db_LoadTIMER(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_TIMER WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadTIMERCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadTIMERCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadTIMERCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bTIMER_MODULE[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char TIMER_Pos[32];
		char TIMER_Pos_SPLIT[2][16];
		SQL_FetchString(hndl, 2, TIMER_Pos, sizeof TIMER_Pos);
		ExplodeString(TIMER_Pos, "|", TIMER_Pos_SPLIT, sizeof TIMER_Pos_SPLIT, sizeof TIMER_Pos_SPLIT[]);
		g_fTIMER_MODULE_POSITION[client][0] = StringToFloat(TIMER_Pos_SPLIT[0]);
		g_fTIMER_MODULE_POSITION[client][1] = StringToFloat(TIMER_Pos_SPLIT[1]);

		g_iTIMER_HOLDTIME[client] = SQL_FetchInt(hndl, 3);

		char TIMERColor_SPLIT[3][12];
		//GAIN COLOR
		char TIMERColor_Gain[32];
		SQL_FetchString(hndl, 4, TIMERColor_Gain, sizeof TIMERColor_Gain);
		ExplodeString(TIMERColor_Gain, "|", TIMERColor_SPLIT, sizeof TIMERColor_SPLIT, sizeof TIMERColor_SPLIT[]);
		g_iTIMER_MODULE_COLOR[client][0][0] = StringToInt(TIMERColor_SPLIT[0]);
		g_iTIMER_MODULE_COLOR[client][0][1] = StringToInt(TIMERColor_SPLIT[1]);
		g_iTIMER_MODULE_COLOR[client][0][2] = StringToInt(TIMERColor_SPLIT[2]);

		//LOSS COLOR
		char TIMERColor_Loss[32];
		SQL_FetchString(hndl, 5, TIMERColor_Loss, sizeof TIMERColor_Loss);
		ExplodeString(TIMERColor_Loss, "|", TIMERColor_SPLIT, sizeof TIMERColor_SPLIT, sizeof TIMERColor_SPLIT[]);
		g_iTIMER_MODULE_COLOR[client][1][0] = StringToInt(TIMERColor_SPLIT[0]);
		g_iTIMER_MODULE_COLOR[client][1][1] = StringToInt(TIMERColor_SPLIT[1]);
		g_iTIMER_MODULE_COLOR[client][1][2] = StringToInt(TIMERColor_SPLIT[2]);

		//MAINTAIN COLOR
		char TIMERColor_Maintain[32];
		SQL_FetchString(hndl, 6, TIMERColor_Maintain, sizeof TIMERColor_Maintain);
		ExplodeString(TIMERColor_Maintain, "|", TIMERColor_SPLIT, sizeof TIMERColor_SPLIT, sizeof TIMERColor_SPLIT[]);
		g_iTIMER_MODULE_COLOR[client][2][0] = StringToInt(TIMERColor_SPLIT[0]);
		g_iTIMER_MODULE_COLOR[client][2][1] = StringToInt(TIMERColor_SPLIT[1]);
		g_iTIMER_MODULE_COLOR[client][2][2] = StringToInt(TIMERColor_SPLIT[2]);

		//FORMAT ORDER
		char TIMERFormatOrder[32];
		char TIMERFormatOrder_SPLIT[TIMER_SUBMODULES][12];
		SQL_FetchString(hndl, 7, TIMERFormatOrder, sizeof TIMERFormatOrder);
		ExplodeString(TIMERFormatOrder, "|", TIMERFormatOrder_SPLIT, sizeof TIMERFormatOrder_SPLIT, sizeof TIMERFormatOrder_SPLIT[]);
		for(int i = 0; i < TIMER_SUBMODULES; i++)
			g_iTIMER_SUBMODULES_INDEXES[client][i] = StringToInt(TIMERFormatOrder_SPLIT[i]);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_TIMER (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		TIMER_SetDefaults(client);
	}

	LoadSubModule(client, 2, 1);
}

public void db_SET_TIMER(int client)
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
	Format(szPosX, sizeof szPosX, "%.2f", g_fTIMER_MODULE_POSITION[client][0]);
	Format(szPosY, sizeof szPosY, "%.2f", g_fTIMER_MODULE_POSITION[client][1]);
	Format(szPosition, sizeof szPosition, "%s|%s", szPosX, szPosY);

	//COLORS
	IntToString(g_iTIMER_MODULE_COLOR[client][0][0], szGain_R, sizeof szGain_R);
	IntToString(g_iTIMER_MODULE_COLOR[client][0][1], szGain_G, sizeof szGain_G);
	IntToString(g_iTIMER_MODULE_COLOR[client][0][2], szGain_B, sizeof szGain_B);
	Format(szGain, sizeof szGain, "%s|%s|%s", szGain_R, szGain_G, szGain_B);

	IntToString(g_iTIMER_MODULE_COLOR[client][1][0], szLoss_R, sizeof szLoss_R);
	IntToString(g_iTIMER_MODULE_COLOR[client][1][1], szLoss_G, sizeof szLoss_G);
	IntToString(g_iTIMER_MODULE_COLOR[client][1][2], szLoss_B, sizeof szLoss_B);
	Format(szLoss, sizeof szLoss, "%s|%s|%s", szLoss_R, szLoss_G, szLoss_B);

	IntToString(g_iTIMER_MODULE_COLOR[client][2][0], szMaintain_R, sizeof szMaintain_R);
	IntToString(g_iTIMER_MODULE_COLOR[client][2][1], szMaintain_G, sizeof szMaintain_G);
	IntToString(g_iTIMER_MODULE_COLOR[client][2][2], szMaintain_B, sizeof szMaintain_B);
	Format(szMaintain, sizeof szMaintain, "%s|%s|%s", szMaintain_R, szMaintain_G, szMaintain_B);

	//FORMAT ORDER BY ID
	for(int i = 0; i < TIMER_SUBMODULES; i++) {
		IntToString(g_iTIMER_SUBMODULES_INDEXES[client][i], szFormatOrder_temp, sizeof szFormatOrder_temp);
		Format(szFormatOrder_temp, sizeof szFormatOrder_temp, "%s|", szFormatOrder_temp);
		StrCat(szFormatOrder, sizeof szFormatOrder, szFormatOrder_temp);
	}
	for(int i = 0; i < 32; i++) {
		if (szFormatOrder[i] == '|' && szFormatOrder[i+1] == '\0') {
			szFormatOrder[i] = '\0';
			break;
		}
	}

	Format(szQuery, sizeof szQuery, "UPDATE chud_TIMER SET enabled = '%i', pos = '%s', holdtime = '%i', gaincolor = '%s', losscolor = '%s', maintaincolor = '%s', FormatOrderbyID = '%s' WHERE steamid = '%s';", g_bTIMER_MODULE[client] ? 1 : 0, szPosition, g_iTIMER_HOLDTIME[client], szGain, szLoss, szMaintain, szFormatOrder, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_TIMERCallback, szQuery, client, DBPrio_Low);

}

public void db_SET_TIMERCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_TIMERCallback): %s", error);
		CloseHandle(client);
		return;
	}

	SaveSubModule(client, 2, 1);
}