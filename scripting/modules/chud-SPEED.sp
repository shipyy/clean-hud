public Init_SPEED_MODULE(){
	Handle_SPEED_MODULE = CreateHudSynchronizer();
}

public SPEED_SetDefaults(int client)
{
	PrintToServer("Loading SPEED Defaults!");

	g_bSPEED_MODULE[client] = false;
	g_fSPEED_MODULE_POSITION[client][0] = 0.5;
	g_fSPEED_MODULE_POSITION[client][1] = 0.5;
	
	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iSPEED_MODULE_COLOR[client][i][j] = 255;
}

/////
//MENU
/////
public void SPEED_MENU(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SPEED_MENU_Handler);
	char szItem[128];

	SetMenuTitle(menu, "SPEED MODULE MENU\n \n");

	// Toggle
	if (g_bSPEED_MODULE[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");
    
	// Position
	Format(szItem, sizeof szItem, "Position   | %.1f %.1f", g_fSPEED_MODULE_POSITION[client][0], g_fSPEED_MODULE_POSITION[client][1]);
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

public int SPEED_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: SPEED_Toggle(param1);
			case 1: SPEED_Position(param1);
			case 2: SPEED_Color(param1);
			case 3: SPEED_FORMATORDER(param1);
			case 4: SPEED_CUSTOMIZE_SUBMODULES(param1);
			case 5: Export(param1, 1, false, true);
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
public void SPEED_Toggle(int client)
{
    if (g_bSPEED_MODULE[client])
		g_bSPEED_MODULE[client] = false;
	else
		g_bSPEED_MODULE[client] = true;

    SPEED_MENU(client);
}

/////
//POSITION
/////
public void SPEED_Position(int client)
{
	Menu menu = CreateMenu(SPEED_Position_Handler);
	SetMenuTitle(menu, "SPEED | Position\n \n");

	AddMenuItem(menu, "", "Right");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Up");
	AddMenuItem(menu, "", "Down");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: SPEED_PosX(param1, 1);
			case 1: SPEED_PosX(param1, -1);
			case 2: SPEED_PosY(param1, 1);
			case 3: SPEED_PosY(param1, -1);
		}
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void SPEED_PosX(int client, int direction)
{
    switch (direction) {
        case 1 : g_fSPEED_MODULE_POSITION[client][0] = (g_fSPEED_MODULE_POSITION[client][0] + 0.1) > 1.0 ? 1.0 : g_fSPEED_MODULE_POSITION[client][0] + 0.1;
        case -1 : g_fSPEED_MODULE_POSITION[client][0] = (g_fSPEED_MODULE_POSITION[client][0] - 0.1) < 0.0 ? 0.0 : g_fSPEED_MODULE_POSITION[client][0] - 0.1;
    }

    SPEED_Position(client);
}

void SPEED_PosY(int client, int direction)
{
    switch (direction) {
        case 1 : g_fSPEED_MODULE_POSITION[client][1] = (g_fSPEED_MODULE_POSITION[client][1] + 0.1) > 1.0 ? 1.0 : g_fSPEED_MODULE_POSITION[client][1] + 0.1;
        case -1 : g_fSPEED_MODULE_POSITION[client][1] = (g_fSPEED_MODULE_POSITION[client][1] - 0.1) < 0.0 ? 0.0 : g_fSPEED_MODULE_POSITION[client][1] - 0.1;
    }

    SPEED_Position(client);
}

/////
//COLOR
/////
public void SPEED_Color(int client)
{
	Menu menu = CreateMenu(SPEED_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "SPEED MODULE | Color\n \n");

	Format(szItem, sizeof szItem, "Gain     | %d %d %d", g_iSPEED_MODULE_COLOR[client][0][0], g_iSPEED_MODULE_COLOR[client][0][1], g_iSPEED_MODULE_COLOR[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Loss     | %d %d %d", g_iSPEED_MODULE_COLOR[client][1][0], g_iSPEED_MODULE_COLOR[client][1][1], g_iSPEED_MODULE_COLOR[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Maintain | %d %d %d", g_iSPEED_MODULE_COLOR[client][2][0], g_iSPEED_MODULE_COLOR[client][2][1], g_iSPEED_MODULE_COLOR[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		SPEED_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void SPEED_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(SPEED_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Gain Color\n \n");
		case 1: SetMenuTitle(menu, "Loss Color\n \n");
		case 2: SetMenuTitle(menu, "Maintain Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iSPEED_MODULE_COLOR[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iSPEED_MODULE_COLOR[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iSPEED_MODULE_COLOR[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	char szBuffer[32];

	if (action == MenuAction_Select){
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		SPEED_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		SPEED_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void SPEED_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 1;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/*
int[] GetSpeedColour_Float(int client, float speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) ) {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][0][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][0][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][0][2];
	}
	//losing speed
	else if (g_fLastSpeed[client] > speed ) {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][1][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][1][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][1][2];
	}
	//not moving (speed == 0)
	else {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][2][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][2][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][2][2];
	}

	return displayColor;
}
*/

int[] GetSpeedColour_Int(int client, int speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (RoundToNearest(g_fLastSpeed[client]) < speed || (RoundToNearest(g_fLastSpeed[client]) == speed && speed != 0.0) ) {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][0][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][0][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][0][2];
	}
	//losing speed
	else if (RoundToNearest(g_fLastSpeed[client]) > speed ) {
		displayColor[0] = g_iSPEED_MODULE_COLOR[client][1][0];
		displayColor[1] = g_iSPEED_MODULE_COLOR[client][1][1];
		displayColor[2] = g_iSPEED_MODULE_COLOR[client][1][2];
	}
	//not moving (speed == 0)
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
public void SPEED_FORMATORDER(int client)
{
	Menu menu = CreateMenu(SPEED_FORMATORDER_MENU_Handler);

	for(int i = 0; i < SPEED_SUBMODULES; i++)
		AddMenuItem(menu, "", g_szSPEED_SUBMODULE_NAME[getSubModuleID(client, 1, g_iSPEED_SUBMODULES_INDEXES[client][i])]);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_FORMATORDER_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		CHANGE_SPEED_FORMAT_ID(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CHANGE_SPEED_FORMAT_ID(int client, int choice)
{
	Menu menu = CreateMenu(CHANGE_SPEED_FORMAT_ID_MENU_Handler);

	char szBuffer[32];

	Format(szBuffer, sizeof szBuffer, "%d", choice);
	AddMenuItem(menu, szBuffer, "None\n \n");

	for(int i = 1; i <= SPEED_SUBMODULES; i++) {
		Format(szBuffer, sizeof szBuffer, "%d", choice);
		AddMenuItem(menu, szBuffer, g_szSPEED_SUBMODULE_NAME[i]);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHANGE_SPEED_FORMAT_ID_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		g_iSPEED_SUBMODULES_INDEXES[param1][StringToInt(szBuffer)] = param2;
		SPEED_FORMATORDER(param1);
	}
	else if (action == MenuAction_Cancel)
		SPEED_FORMATORDER(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//SUBMODULES
/////
public void SPEED_CUSTOMIZE_SUBMODULES(int client)
{
    Menu menu = CreateMenu(SPEED_SUBMODULES_Handler);

    AddMenuItem(menu, "", "Center Speed Display");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_SUBMODULES_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){
        switch (param2) {
            case 0 : SUBMODULE_CSD(param1);
        }
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//DISPLAY
/////
public void SPEED_DISPLAY(int client)
{
	if (g_bSPEED_MODULE[client] && !IsFakeClient(client)) {

		float posx = g_fSPEED_MODULE_POSITION[client][0] == 0.5 ? -1.0 : g_fSPEED_MODULE_POSITION[client][0];
		float posy = g_fSPEED_MODULE_POSITION[client][1] == 0.5 ? -1.0 : g_fSPEED_MODULE_POSITION[client][1];

		CSD_Format(client);

		//CHECK FOR NON-SELECTED SUBMODULES
		for(int i = 0; i < SPEED_SUBMODULES; i++)
			if (g_iSPEED_SUBMODULES_INDEXES[client][i] == 0)
				Format(g_szSPEED_SUBMODULE_INDEXES_STRINGS[client][i], sizeof g_szSPEED_SUBMODULE_INDEXES_STRINGS[][], "%s", "");


		for(int i = 0; i < SPEED_SUBMODULES; i++) {
			if (i == 0)
				Format(g_szSPEED_MODULE[client], sizeof g_szSPEED_MODULE[], "%s", g_szSPEED_SUBMODULE_INDEXES_STRINGS[client][i]);
			else
				Format(g_szSPEED_MODULE[client], sizeof g_szSPEED_MODULE[], "%s\n%s", g_szSPEED_MODULE[client], g_szSPEED_SUBMODULE_INDEXES_STRINGS[client][i]);
		}

		int displayColor[3];
		displayColor = GetSpeedColour_Int(client, StringToInt(g_szCSD_SUBMODULE[client]));

		SetHudTextParams(posx, posy, 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, Handle_SPEED_MODULE, g_szSPEED_MODULE[client]);
	}
}

public void db_LoadSPEED(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM chud_SPEED WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSPEEDCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadSPEEDCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_LoadSPEEDCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		g_bSPEED_MODULE[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char SPEED_Pos[32];
		char SPEED_Pos_SPLIT[2][16];
		SQL_FetchString(hndl, 2, SPEED_Pos, sizeof SPEED_Pos);
		ExplodeString(SPEED_Pos, "|", SPEED_Pos_SPLIT, sizeof SPEED_Pos_SPLIT, sizeof SPEED_Pos_SPLIT[]);
		g_fSPEED_MODULE_POSITION[client][0] = StringToFloat(SPEED_Pos_SPLIT[0]);
		g_fSPEED_MODULE_POSITION[client][1] = StringToFloat(SPEED_Pos_SPLIT[1]);

		char SPEEDColor_SPLIT[3][12];
		//GAIN COLOR
		char SPEEDColor_Gain[32];
		SQL_FetchString(hndl, 3, SPEEDColor_Gain, sizeof SPEEDColor_Gain);
		ExplodeString(SPEEDColor_Gain, "|", SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT[]);
		g_iSPEED_MODULE_COLOR[client][0][0] = StringToInt(SPEEDColor_SPLIT[0]);
		g_iSPEED_MODULE_COLOR[client][0][1] = StringToInt(SPEEDColor_SPLIT[1]);
		g_iSPEED_MODULE_COLOR[client][0][2] = StringToInt(SPEEDColor_SPLIT[2]);

		//LOSS COLOR
		char SPEEDColor_Loss[32];
		SQL_FetchString(hndl, 4, SPEEDColor_Loss, sizeof SPEEDColor_Loss);
		ExplodeString(SPEEDColor_Loss, "|", SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT[]);
		g_iSPEED_MODULE_COLOR[client][1][0] = StringToInt(SPEEDColor_SPLIT[0]);
		g_iSPEED_MODULE_COLOR[client][1][1] = StringToInt(SPEEDColor_SPLIT[1]);
		g_iSPEED_MODULE_COLOR[client][1][2] = StringToInt(SPEEDColor_SPLIT[2]);

		//MAINTAIN COLOR
		char SPEEDColor_Maintain[32];
		SQL_FetchString(hndl, 5, SPEEDColor_Maintain, sizeof SPEEDColor_Maintain);
		ExplodeString(SPEEDColor_Maintain, "|", SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT, sizeof SPEEDColor_SPLIT[]);
		g_iSPEED_MODULE_COLOR[client][2][0] = StringToInt(SPEEDColor_SPLIT[0]);
		g_iSPEED_MODULE_COLOR[client][2][1] = StringToInt(SPEEDColor_SPLIT[1]);
		g_iSPEED_MODULE_COLOR[client][2][2] = StringToInt(SPEEDColor_SPLIT[2]);

		//FORMAT ORDER
		char SPEEDFormatOrder[32];
		char SPEEDFormatOrder_SPLIT[SPEED_SUBMODULES][12];
		SQL_FetchString(hndl, 6, SPEEDFormatOrder, sizeof SPEEDFormatOrder);
		ExplodeString(SPEEDFormatOrder, "|", SPEEDFormatOrder_SPLIT, sizeof SPEEDFormatOrder_SPLIT, sizeof SPEEDFormatOrder_SPLIT[]);
		for(int i = 0; i < SPEED_SUBMODULES; i++)
			g_iSPEED_SUBMODULES_INDEXES[client][i] = StringToInt(SPEEDFormatOrder_SPLIT[0]);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO chud_SPEED (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		SPEED_SetDefaults(client);
	}

	LoadSubModule(client, 1, 1);
}

public void db_SET_SPEED(int client)
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
	Format(szPosX, sizeof szPosX, "%.1f", g_fSPEED_MODULE_POSITION[client][0]);
	Format(szPosY, sizeof szPosY, "%.1f", g_fSPEED_MODULE_POSITION[client][1]);
	Format(szPosition, sizeof szPosition, "%s|%s", szPosX, szPosY);

	//COLORS
	IntToString(g_iSPEED_MODULE_COLOR[client][0][0], szGain_R, sizeof szGain_R);
	IntToString(g_iSPEED_MODULE_COLOR[client][0][1], szGain_G, sizeof szGain_G);
	IntToString(g_iSPEED_MODULE_COLOR[client][0][2], szGain_B, sizeof szGain_B);
	Format(szGain, sizeof szGain, "%s|%s|%s", szGain_R, szGain_G, szGain_B);

	IntToString(g_iSPEED_MODULE_COLOR[client][1][0], szLoss_R, sizeof szLoss_R);
	IntToString(g_iSPEED_MODULE_COLOR[client][1][1], szLoss_G, sizeof szLoss_G);
	IntToString(g_iSPEED_MODULE_COLOR[client][1][2], szLoss_B, sizeof szLoss_B);
	Format(szLoss, sizeof szLoss, "%s|%s|%s", szLoss_R, szLoss_G, szLoss_B);

	IntToString(g_iSPEED_MODULE_COLOR[client][2][0], szMaintain_R, sizeof szMaintain_R);
	IntToString(g_iSPEED_MODULE_COLOR[client][2][1], szMaintain_G, sizeof szMaintain_G);
	IntToString(g_iSPEED_MODULE_COLOR[client][2][2], szMaintain_B, sizeof szMaintain_B);
	Format(szMaintain, sizeof szMaintain, "%s|%s|%s", szMaintain_R, szMaintain_G, szMaintain_B);

	//FORMAT ORDER BY ID
	for(int i = 0; i < SPEED_SUBMODULES; i++) {
		IntToString(g_iSPEED_MODULE_COLOR[client][client][i], szFormatOrder_temp, sizeof szFormatOrder_temp);
		Format(szFormatOrder_temp, sizeof szFormatOrder_temp, "%s|", szFormatOrder_temp);
		StrCat(szFormatOrder, sizeof szFormatOrder, szFormatOrder_temp);
	}
	for(int i = 0; i < 32; i++)
		if (szFormatOrder[i] == '|' && szFormatOrder[i+1] == '\0')
			szFormatOrder[i] = '\0';

	Format(szQuery, sizeof szQuery, "UPDATE chud_SPEED SET enabled = '%i', pos = '%s', gaincolor = '%s', losscolor = '%s', maintaincolor = '%s', FormatOrderbyID = '%s' WHERE steamid = '%s';", g_bSPEED_MODULE[client] ? 1 : 0, szPosition, szGain, szLoss, szMaintain, szFormatOrder, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_SET_SPEEDCallback, szQuery, client, DBPrio_Low);

}

public void db_SET_SPEEDCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (db_SET_SPEEDCallback): %s", error);
		CloseHandle(client);
		return;
	}

	SaveSubModule(client, 1, 1);
}