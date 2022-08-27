public Init_CP(){
	CP_Handle = CreateHudSynchronizer();
}

public CP_SetDefaults(int client)
{
	PrintToServer("Loading CP Defaults!");

	g_bCP[client] = false;
	g_fCP_POSX[client] = 0.5;
	g_fCP_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iCP_Color[client][i][j] = 255;

	g_iCP_HoldTime[client] = 3;
	g_iCP_CompareMode[client] = 1;
}

public void CHUD_CP(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_CP_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Checkpoints Options Menu\n \n");

	// Toggle
	if (g_bCP[client])
		AddMenuItem(menu, "", "Toggle     | On");
	else
		AddMenuItem(menu, "", "Toggle     | Off");

	// Position
	Format(szItem, sizeof szItem, "Position  | %.1f %.1f", g_fCP_POSX[client], g_fCP_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	AddMenuItem(menu, "", "Color       |");

	// Hold Time
	Format(szItem, sizeof szItem, "Hold        | %d", g_iCP_HoldTime[client]);
	AddMenuItem(menu, "", szItem);

	// Compare Mode
	Format(szItem, sizeof szItem, "Compare | %s", g_iCP_CompareMode[client] == 0 ? "PB\n \n" : "WR\n \n");
	AddMenuItem(menu, "", szItem);

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CP_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CP_Toggle(param1, true);
			case 1: CP_Position(param1);
			case 2: CP_Color(param1);
			case 3: CP_HoldTime(param1);
			case 4: CP_CompareMode(param1);
			case 5: Export(param1, 3, false, true);
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
public void CP_Toggle(int client, bool from_menu)
{
    if (g_bCP[client]) {
		g_bCP[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bCP[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        CHUD_CP(client);
    }
}

/////
//POSITION
/////
public void CP_Position(int client)
{

	Menu menu = CreateMenu(CHUD_CP_Position_Handler);
	SetMenuTitle(menu, "Checkpoints | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fCP_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fCP_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CP_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: CP_PosX(param1);
			case 1: CP_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_CP(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void CP_PosX(int client)
{
	if (g_fCP_POSX[client] < 1.0){
		g_fCP_POSX[client] += 0.1;
	}
	else
		g_fCP_POSX[client] = 0.0;

	CP_Position(client);
}

void CP_PosY(int client)
{
	
	if (g_fCP_POSY[client] < 1.0)
		g_fCP_POSY[client] += 0.1;
	else
		g_fCP_POSY[client] = 0.0;

	CP_Position(client);
}

/////
//COLOR
/////
public void CP_Color(int client)
{
	Menu menu = CreateMenu(CHUD_CP_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Checkpoints | Color\n \n");

	Format(szItem, sizeof szItem, "Faster  | %d %d %d", g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Slower | %d %d %d", g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Equal   | %d %d %d", g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2]);
	AddMenuItem(menu, "", szItem);
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CP_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		CP_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		CHUD_CP(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CP_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(CP_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Checkpoint | Faster Color\n \n");
		case 1: SetMenuTitle(menu, "Checkpoint | Slower Color\n \n");
		case 2: SetMenuTitle(menu, "Checkpoint | Equal Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iCP_Color[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iCP_Color[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iCP_Color[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CP_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){

		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		CP_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		CP_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CP_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 2;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//HOLD TIME
/////
void CP_HoldTime(int client)
{
	if (g_iCP_HoldTime[client] < 5)
		g_iCP_HoldTime[client]++;
	else
		g_iCP_HoldTime[client] = 0;

	CHUD_CP(client);
}

/////
//COMPARE MODE
/////
void CP_CompareMode(int client)
{
	if (g_iCP_CompareMode[client] != 1)
		g_iCP_CompareMode[client]++;
	else
		g_iCP_CompareMode[client] = 0;

	CHUD_CP(client);
}

/////
//DISPLAY
/////
public void CP_Display(int client, float runtime, float pb_runtime, float wr_runtime)
{
	if (g_bCP[client] && !IsFakeClient(client)) {

		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		char szPBFormatted[32];
		char szWRFormatted[32];

		if (g_iCP_CompareMode[client] == 0) {
			Format_Time(client, runtime - pb_runtime, szPBFormatted, sizeof szPBFormatted, true);

			if (pb_runtime - runtime > 0) {
				Format(szPBFormatted, sizeof szPBFormatted, "PB -%s", szPBFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (pb_runtime - runtime < 0) {
				Format(szPBFormatted, sizeof szPBFormatted, "PB +%s", szPBFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, CP_Handle, szPBFormatted);
		}
		else {
			Format_Time(client, runtime - pb_runtime, szWRFormatted, sizeof szWRFormatted, true);

			if (wr_runtime - runtime > 0) {
				Format(szWRFormatted, sizeof szWRFormatted, "WR -%s", szWRFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (wr_runtime - runtime < 0) {
				Format(szWRFormatted, sizeof szWRFormatted, "WR +%s", szWRFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, CP_Handle, szWRFormatted);
		}
	}
}

/////
//COOKIES
/////
public void CP_ConvertStringToData(int client, char szData[512])
{           
	char szModules[7][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 7; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bCP[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fCP_POSX[client] = StringToFloat(szPosition[0]);
	g_fCP_POSY[client] = StringToFloat(szPosition[1]);

	char szColorGain[3][8];
	ExplodeString(szModules[2], ":", szColorGain, sizeof szColorGain, sizeof szColorGain[]);
	g_iCP_Color[client][0][0] = StringToInt(szColorGain[0]);
	g_iCP_Color[client][0][1] = StringToInt(szColorGain[1]);
	g_iCP_Color[client][0][2] = StringToInt(szColorGain[2]);

	char szColorLoss[3][8];
	ExplodeString(szModules[3], ":", szColorLoss, sizeof szColorLoss, sizeof szColorLoss[]);
	g_iCP_Color[client][1][0] = StringToInt(szColorLoss[0]);
	g_iCP_Color[client][1][1] = StringToInt(szColorLoss[1]);
	g_iCP_Color[client][1][2] = StringToInt(szColorLoss[2]);

	char szColorMaintain[3][8];
	ExplodeString(szModules[4], ":", szColorMaintain, sizeof szColorMaintain, sizeof szColorMaintain[]);
	g_iCP_Color[client][2][0] = StringToInt(szColorMaintain[0]);
	g_iCP_Color[client][2][1] = StringToInt(szColorMaintain[1]);
	g_iCP_Color[client][2][2] = StringToInt(szColorMaintain[2]);

	g_iCP_HoldTime[client] = StringToInt(szModules[5]);
	g_iCP_CompareMode[client] = StringToInt(szModules[6]);
}

char[] CP_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bCP[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fCP_POSX[client], g_fCP_POSY[client]);

	//COLORS
	//TYPE 1
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2]);
	//TYPE 2
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2]);
	//TYPE 3
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2]);

	//HOLD TIME
	Format(szData, sizeof szData, "%s%d|", szData, g_iCP_HoldTime[client]);

	//COMPARE MODE
	Format(szData, sizeof szData, "%s%d", szData, g_iCP_CompareMode[client]);

	return szData;
}