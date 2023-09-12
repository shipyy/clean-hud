public Init_PRESTRAFE(){
	PRESTRAFE_Handle = CreateHudSynchronizer();
}

public PRESTRAFE_SetDefaults(int client)
{
	PrintToServer("Loading PRESTRAFE Defaults!");

	g_bPRESTRAFE[client] = false;
	g_fPRESTRAFE_POSX[client] = 0.5;
	g_fPRESTRAFE_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iPRESTRAFE_Color[client][i][j] = 255;

	g_iPRESTRAFE_HoldTime[client] = 3;
	g_iPRESTRAFE_CompareMode[client] = 1; //WR DEFAULT
}

public void CHUD_PRESTRAFE(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_PRESTRAFE_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Prestrafe Options Menu\n \n");

	// Toggle
	if (g_bPRESTRAFE[client])
		AddMenuItem(menu, "", "Toggle     | On");
	else
		AddMenuItem(menu, "", "Toggle     | Off");

	// Position
	Format(szItem, sizeof szItem, "Position  | %.2f %.2f", g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	AddMenuItem(menu, "", "Color       |");

	// Hold Time
	Format(szItem, sizeof szItem, "Hold        | %d", g_iPRESTRAFE_HoldTime[client]);
	AddMenuItem(menu, "", szItem);

	// Compare Mode
	switch (g_iPRESTRAFE_CompareMode[client]){
		case 1: Format(szItem, sizeof szItem, "Compare | WR");
		case 2: Format(szItem, sizeof szItem, "Compare | PB");
	}
	Format(szItem, sizeof szItem, "%s\n \n", szItem);
	AddMenuItem(menu, "", szItem);

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	g_bEditing[client][7] = true;

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_PRESTRAFE_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: PRESTRAFE_Toggle(param1, true);
			case 1: PRESTRAFE_Position(param1);
			case 2: PRESTRAFE_Color(param1);
			case 3: PRESTRAFE_HoldTime(param1);
			case 4: PRESTRAFE_CompareMode(param1);
			case 5: Export(param1, 7, false, true);
		}
	}
	else if (action == MenuAction_Cancel) {
		g_bEditing[param1][7] = false;
		CHUD_MainMenu_Display(param1);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void PRESTRAFE_Toggle(int client, bool from_menu)
{
    if (g_bPRESTRAFE[client]) {
		g_bPRESTRAFE[client] = false;
	}
	else {
		g_bPRESTRAFE[client] = true;
	}

    if (from_menu) {
        CHUD_PRESTRAFE(client);
    }
}

/////
//POSITION
/////
public void PRESTRAFE_Position(int client)
{

	Menu menu = CreateMenu(CHUD_PRESTRAFE_Position_Handler);
	SetMenuTitle(menu, "Prestrafe | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fPRESTRAFE_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fPRESTRAFE_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_PRESTRAFE_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: PRESTRAFE_PosX(param1);
			case 1: PRESTRAFE_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_PRESTRAFE(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void PRESTRAFE_PosX(int client)
{
	if (g_fPRESTRAFE_POSX[client] < 1.0){
		g_fPRESTRAFE_POSX[client] += 0.05;
	}
	else
		g_fPRESTRAFE_POSX[client] = 0.0;

	PRESTRAFE_Position(client);
}

void PRESTRAFE_PosY(int client)
{

	if (g_fPRESTRAFE_POSY[client] < 1.0)
		g_fPRESTRAFE_POSY[client] += 0.05;
	else
		g_fPRESTRAFE_POSY[client] = 0.0;

	PRESTRAFE_Position(client);
}

/////
//COLOR
/////
public void PRESTRAFE_Color(int client)
{
	Menu menu = CreateMenu(CHUD_PRESTRAFE_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Prestrafe | Color\n \n");

	Format(szItem, sizeof szItem, "Faster  | %d %d %d", g_iPRESTRAFE_Color[client][0][0], g_iPRESTRAFE_Color[client][0][1], g_iPRESTRAFE_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Slower | %d %d %d", g_iPRESTRAFE_Color[client][1][0], g_iPRESTRAFE_Color[client][1][1], g_iPRESTRAFE_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Equal   | %d %d %d", g_iPRESTRAFE_Color[client][2][0], g_iPRESTRAFE_Color[client][2][1], g_iPRESTRAFE_Color[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_PRESTRAFE_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select) {
		g_bEditingColor[param1][param2] = true;
		PRESTRAFE_Color_Change_MENU(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		CHUD_PRESTRAFE(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void PRESTRAFE_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(PRESTRAFE_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Prestrafe | Faster Color\n \n");
		case 1: SetMenuTitle(menu, "Prestrafe | Slower Color\n \n");
		case 2: SetMenuTitle(menu, "Prestrafe | Equal Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iPRESTRAFE_Color[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iPRESTRAFE_Color[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iPRESTRAFE_Color[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int PRESTRAFE_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	char szBuffer[32];

	if (action == MenuAction_Select){
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		PRESTRAFE_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel) {
		GetMenuItem(menu, 1, szBuffer, sizeof(szBuffer));
		g_bEditingColor[param1][StringToInt(szBuffer)] = false;
		PRESTRAFE_Color(param1);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void PRESTRAFE_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 5;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	WaitingForResponse[client] = ChangeColor;
}

/////
//HOLD TIME
/////
void PRESTRAFE_HoldTime(int client)
{
	if (g_iPRESTRAFE_HoldTime[client] < 5)
		g_iPRESTRAFE_HoldTime[client]++;
	else
		g_iPRESTRAFE_HoldTime[client] = 0;

	CHUD_PRESTRAFE(client);
}

/////
//COMPARE MODE
/////
void PRESTRAFE_CompareMode(int client)
{
	if (g_iPRESTRAFE_CompareMode[client] != 2)
		g_iPRESTRAFE_CompareMode[client]++;
	else
		g_iPRESTRAFE_CompareMode[client] = 1;

	CHUD_PRESTRAFE(client);
}

/////
//FORMAT
/////
public void PRESTRAFE_Format(int client, int prestrafe, char szPBDiff[128], char szWRDiff[128])
{
	switch (g_iPRESTRAFE_CompareMode[client]){
		case 1: Format(szPrestrafeFormatted[client], sizeof szPrestrafeFormatted, "%d | WR %s", prestrafe, szWRDiff);
		case 2: Format(szPrestrafeFormatted[client], sizeof szPrestrafeFormatted, "%d | PB %s", prestrafe, szPBDiff);
	}

	g_fLastDifferencePrestrafe[client] = GetGameTime();
}

/////
//DISPLAY
/////
public void PRESTRAFE_Display(int client)
{
	if (!IsFakeClient(client) && (g_bPRESTRAFE[client] || g_bEditing[client][7])) {

		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		if (IsFakeClient(target))
			return;

		if (g_bEditing[client][7]) {
			if (g_bEditingColor[client][0]) {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 1.0, g_iPRESTRAFE_Color[client][0][0], g_iPRESTRAFE_Color[client][0][1], g_iPRESTRAFE_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][1]) {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 1.0, g_iPRESTRAFE_Color[client][1][0], g_iPRESTRAFE_Color[client][1][1], g_iPRESTRAFE_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][2]) {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 1.0, g_iPRESTRAFE_Color[client][2][0], g_iPRESTRAFE_Color[client][2][1], g_iPRESTRAFE_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 1.0, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, PRESTRAFE_Handle, "%s", "WR +000");
			return;
		}

		if (GetGameTime() - g_fLastDifferencePrestrafe[target] < g_iPRESTRAFE_HoldTime[client]) {

			if ( StrContains(szPrestrafeFormatted[target], "-", false) != -1 ) {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 0.1, g_iPRESTRAFE_Color[client][0][0], g_iPRESTRAFE_Color[client][0][1], g_iPRESTRAFE_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if ( StrContains(szPrestrafeFormatted[target], "+", false) != -1 ) {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 0.1, g_iPRESTRAFE_Color[client][1][0], g_iPRESTRAFE_Color[client][1][1], g_iPRESTRAFE_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fPRESTRAFE_POSX[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client] == 0.5 ? -1.0 : g_fPRESTRAFE_POSY[client], 0.1, g_iPRESTRAFE_Color[client][2][0], g_iPRESTRAFE_Color[client][2][1], g_iPRESTRAFE_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, PRESTRAFE_Handle, szPrestrafeFormatted[target]);
		}
	}
}

/////
//COOKIES
/////
public void PRESTRAFE_ConvertStringToData(int client, char szData[512])
{
	char szModules[7][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 7; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bPRESTRAFE[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fPRESTRAFE_POSX[client] = StringToFloat(szPosition[0]);
	g_fPRESTRAFE_POSY[client] = StringToFloat(szPosition[1]);

	char szColorGain[3][8];
	ExplodeString(szModules[2], ":", szColorGain, sizeof szColorGain, sizeof szColorGain[]);
	g_iPRESTRAFE_Color[client][0][0] = StringToInt(szColorGain[0]);
	g_iPRESTRAFE_Color[client][0][1] = StringToInt(szColorGain[1]);
	g_iPRESTRAFE_Color[client][0][2] = StringToInt(szColorGain[2]);

	char szColorLoss[3][8];
	ExplodeString(szModules[3], ":", szColorLoss, sizeof szColorLoss, sizeof szColorLoss[]);
	g_iPRESTRAFE_Color[client][1][0] = StringToInt(szColorLoss[0]);
	g_iPRESTRAFE_Color[client][1][1] = StringToInt(szColorLoss[1]);
	g_iPRESTRAFE_Color[client][1][2] = StringToInt(szColorLoss[2]);

	char szColorMaintain[3][8];
	ExplodeString(szModules[4], ":", szColorMaintain, sizeof szColorMaintain, sizeof szColorMaintain[]);
	g_iPRESTRAFE_Color[client][2][0] = StringToInt(szColorMaintain[0]);
	g_iPRESTRAFE_Color[client][2][1] = StringToInt(szColorMaintain[1]);
	g_iPRESTRAFE_Color[client][2][2] = StringToInt(szColorMaintain[2]);

	g_iPRESTRAFE_HoldTime[client] = StringToInt(szModules[5]);
	g_iPRESTRAFE_CompareMode[client] = StringToInt(szModules[6]);
}

char[] PRESTRAFE_ConvertDataToString(int client)
{
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bPRESTRAFE[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.2f:%.2f|", szData, g_fPRESTRAFE_POSX[client], g_fPRESTRAFE_POSY[client]);

	//COLORS
	//TYPE 1
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iPRESTRAFE_Color[client][0][0], g_iPRESTRAFE_Color[client][0][1], g_iPRESTRAFE_Color[client][0][2]);
	//TYPE 2
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iPRESTRAFE_Color[client][1][0], g_iPRESTRAFE_Color[client][1][1], g_iPRESTRAFE_Color[client][1][2]);
	//TYPE 3
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iPRESTRAFE_Color[client][2][0], g_iPRESTRAFE_Color[client][2][1], g_iPRESTRAFE_Color[client][2][2]);

	//HOLD TIME
	Format(szData, sizeof szData, "%s%d|", szData, g_iPRESTRAFE_HoldTime[client]);

	//COMPARE MODE
	Format(szData, sizeof szData, "%s%d", szData, g_iPRESTRAFE_CompareMode[client]);

	return szData;
}