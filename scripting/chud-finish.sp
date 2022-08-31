public Init_FINISH(){
	Finish_Handle = CreateHudSynchronizer();
}

public Finish_SetDefaults(int client)
{
	PrintToServer("Loading Finish Defaults!");

	g_bFinish[client] = false;
	g_fFinish_POSX[client] = 0.5;
	g_fFinish_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iFinish_Color[client][i][j] = 255;

	g_iFinish_HoldTime[client] = 3;
	g_iFinish_CompareMode[client] = 1;
}

public void CHUD_FINISH(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_Finish_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Finish Menu\n \n");

	// Toggle
	if (g_bFinish[client])
		AddMenuItem(menu, "", "Toggle      | On");
	else
		AddMenuItem(menu, "", "Toggle      | Off");

	// Position
	Format(szItem, sizeof szItem, "Position   | %.1f %.1f", g_fFinish_POSX[client], g_fFinish_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	AddMenuItem(menu, "", "Color        |");

	// Hold Time
	Format(szItem, sizeof szItem, "Hold         | %d", g_iFinish_HoldTime[client]);
	AddMenuItem(menu, "", szItem);

	// Compare Mode
	Format(szItem, sizeof szItem, "Compare  | %s", g_iFinish_CompareMode[client] == 0 ? "PB\n \n" : "WR\n \n");
	AddMenuItem(menu, "", szItem);

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	g_bEditing[client][6] = true;

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Finish_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Finish_Toggle(param1, true);
			case 1: Finish_Position(param1);
			case 2: Finish_Color(param1);
			case 3: Finish_HoldTime(param1);
			case 4: Finish_CompareMode(param1);
			case 5: Export(param1, 6, false, true);
		}
	}
	else if (action == MenuAction_Cancel) {
		g_bEditing[param1][6] = false;
		CHUD_MainMenu_Display(param1);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void Finish_Toggle(int client, bool from_menu)
{
	if (g_bFinish[client])
		g_bFinish[client] = false;
	else
		g_bFinish[client] = true;

	if (from_menu)
		CHUD_FINISH(client);
}

/////
//POSITION
/////
public void Finish_Position(int client)
{

	Menu menu = CreateMenu(CHUD_Finish_Position_Handler);
	SetMenuTitle(menu, "Finish | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fFinish_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fFinish_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Finish_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: Finish_PosX(param1);
			case 1: Finish_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_FINISH(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Finish_PosX(int client)
{
	if (g_fFinish_POSX[client] < 1.0){
		g_fFinish_POSX[client] += 0.1;
	}
	else
		g_fFinish_POSX[client] = 0.0;

	Finish_Position(client);
}

void Finish_PosY(int client)
{
	
	if (g_fFinish_POSY[client] < 1.0)
		g_fFinish_POSY[client] += 0.1;
	else
		g_fFinish_POSY[client] = 0.0;

	Finish_Position(client);
}

/////
//COLOR
/////
public void Finish_Color(int client)
{
	Menu menu = CreateMenu(CHUD_Finish_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Finish | Color\n \n");

	Format(szItem, sizeof szItem, "Faster  | %d %d %d", g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Slower | %d %d %d", g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Equal   | %d %d %d", g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2]);
	AddMenuItem(menu, "", szItem);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Finish_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select) {
		g_bEditingColor[param1][param2] = true;
		Finish_Color_Change_MENU(param1, param2);
	}
	else if (action == MenuAction_Cancel)
		CHUD_FINISH(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Finish_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(Finish_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Finish | Faster Color\n \n");
		case 1: SetMenuTitle(menu, "Finish | Slower Color\n \n");
		case 2: SetMenuTitle(menu, "Finish | Equal Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iFinish_Color[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iFinish_Color[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iFinish_Color[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int Finish_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{	
	char szBuffer[32];

	if (action == MenuAction_Select){
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		Finish_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel) {
		GetMenuItem(menu, 1, szBuffer, sizeof(szBuffer));
		g_bEditingColor[param1][StringToInt(szBuffer)] = false;
		Finish_Color(param1);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Finish_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 4;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//HOLD TIME
/////
void Finish_HoldTime(int client)
{
	if (g_iFinish_HoldTime[client] < 5)
		g_iFinish_HoldTime[client]++;
	else
		g_iFinish_HoldTime[client] = 0;

	CHUD_FINISH(client);
}

/////
//COMPARE MODE
/////
void Finish_CompareMode(int client)
{
	if (g_iFinish_CompareMode[client] != 1)
		g_iFinish_CompareMode[client]++;
	else
		g_iFinish_CompareMode[client] = 0;

	CHUD_FINISH(client);
}

/////
//FORMAT
/////
public void Finish_Format(int client, float runtime, float pb_diff, float wr_diff, int zonegroup)
{
	char szCurrentRunFormatted[64];
	char szPBDiffFormatted[64];
	char szWRDiffFormatted[64];

	if (g_iFinish_CompareMode[client] == 0) {
		Format_Time(client, runtime, szCurrentRunFormatted, sizeof szCurrentRunFormatted, true);
		Format_Time(client, pb_diff, szPBDiffFormatted, sizeof szPBDiffFormatted, true);

		if( zonegroup == 0) {
			if( pb_diff >= 0)
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Map Finished in %s | PB +%s", szCurrentRunFormatted, szPBDiffFormatted);
			else
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Map Finished in %s | PB -%s", szCurrentRunFormatted, szPBDiffFormatted);
		}
		else {
			if( pb_diff >= 0)
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Bonus %d Finished in %s | PB +%s", zonegroup, szCurrentRunFormatted, szPBDiffFormatted);
			else
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Bonus %d Finished in %s | PB -%s", zonegroup, szCurrentRunFormatted, szPBDiffFormatted);
		}
	}
	else {
		Format_Time(client, runtime, szFinishFormatted[client], sizeof szFinishFormatted, true);
		Format_Time(client, wr_diff, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
		
		if( zonegroup == 0) {
			if (wr_diff >= 0)
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Map Finished in %s | WR +%s", szCurrentRunFormatted, szWRDiffFormatted);
			else
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Map Finished in %s | WR -%s", szCurrentRunFormatted, szWRDiffFormatted);
		}
		else {
			if (wr_diff >= 0)
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Bonus %d Finished in %s | WR +%s", zonegroup, szCurrentRunFormatted, szWRDiffFormatted);
			else
				Format(szFinishFormatted[client], sizeof szFinishFormatted, "Bonus %d Finished in %s | WR -%s", zonegroup, szCurrentRunFormatted, szWRDiffFormatted);
		}
	}

	g_fLastDifferenceFinishTime[client] = GetGameTime();
}

/////
//DISPLAY
/////
public void Finish_Display(int client)
{
    if (!IsFakeClient(client) && (g_bFinish[client] || g_bEditing[client][6])) {
		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(target == -1)
			return;

		if (g_bEditing[client][6]) {

			if (g_bEditingColor[client][0]) {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 1.0, g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][1]) {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 1.0, g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (g_bEditingColor[client][2]) {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 1.0, g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 1.0, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, Finish_Handle, "%s", "Map Finished in 69:69.420 | WR +69:69.20");
			return;
		}

		if (GetGameTime() - g_fLastDifferenceFinishTime[target] < g_iFinish_HoldTime[client]) {

			if (StrContains(szFinishFormatted[target], "+", false) == 0) {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 0.1, g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (StrContains(szFinishFormatted[target], "-", false) == 0) {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 0.1, g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], 0.1, g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}
			
			ShowSyncHudText(client, Finish_Handle, szFinishFormatted[target]);
		}
	}
}

/////
//COOKIES
/////
public void Finish_ConvertStringToData(int client, char szData[512])
{           
	char szModules[7][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 7; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bFinish[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fFinish_POSX[client] = StringToFloat(szPosition[0]);
	g_fFinish_POSY[client] = StringToFloat(szPosition[1]);

	char szColorFaster[3][8];
	ExplodeString(szModules[2], ":", szColorFaster, sizeof szColorFaster, sizeof szColorFaster[]);
	g_iFinish_Color[client][0][0] = StringToInt(szColorFaster[0]);
	g_iFinish_Color[client][0][1] = StringToInt(szColorFaster[1]);
	g_iFinish_Color[client][0][2] = StringToInt(szColorFaster[2]);

	char szColorSlower[3][8];
	ExplodeString(szModules[3], ":", szColorSlower, sizeof szColorSlower, sizeof szColorSlower[]);
	g_iFinish_Color[client][1][0] = StringToInt(szColorSlower[0]);
	g_iFinish_Color[client][1][1] = StringToInt(szColorSlower[1]);
	g_iFinish_Color[client][1][2] = StringToInt(szColorSlower[2]);

	char szColorEqual[3][8];
	ExplodeString(szModules[4], ":", szColorEqual, sizeof szColorEqual, sizeof szColorEqual[]);
	g_iFinish_Color[client][2][0] = StringToInt(szColorEqual[0]);
	g_iFinish_Color[client][2][1] = StringToInt(szColorEqual[1]);
	g_iFinish_Color[client][2][2] = StringToInt(szColorEqual[2]);

	g_iFinish_CompareMode[client] = StringToInt(szModules[5]);
	g_iFinish_HoldTime[client] = StringToInt(szModules[6]);
}

char[] Finish_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bFinish[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fFinish_POSX[client], g_fFinish_POSY[client]);

	//COLORS
	//TYPE 1
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2]);
	//TYPE 2
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2]);
	//TYPE 3
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2]);

	//COMPARE MODE
	Format(szData, sizeof szData, "%s%d|", szData, g_iFinish_CompareMode[client]);

	//HOLD TIME
	Format(szData, sizeof szData, "%s%d", szData, g_iFinish_HoldTime[client]);

	return szData;
}
