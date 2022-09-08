public Init_CSD(){
	CSD_Handle = CreateHudSynchronizer();
}

public CSD_SetDefaults(int client)
{
	PrintToServer("Loading CSD Defaults!");

	g_bCSD[client] = false;
	g_iCSD_SpeedAxis[client] = 0;
	g_fCSD_POSX[client] = 0.5;
	g_fCSD_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iCSD_Color[client][i][j] = 255;
}

public void CHUD_CSD(int client)
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

	// Axis
	if (g_iCSD_SpeedAxis[client] == 0)
		AddMenuItem(menu, "", "Axis       | XY");
	else if (g_iCSD_SpeedAxis[client] == 1)
		AddMenuItem(menu, "", "Axis       | XYZ");
	else
		AddMenuItem(menu, "", "Axis       | Z");

	// Position
	Format(szItem, sizeof szItem, "Position | %.1f %.1f", g_fCSD_POSX[client], g_fCSD_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	AddMenuItem(menu, "", "Color      |\n \n");

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

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
			case 2: CSD_Position(param1);
			case 3: CSD_Color(param1);
			case 4: Export(param1, 0, false, true);
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
public void CSD_Toggle(int client)
{
    if (g_bCSD[client])
		g_bCSD[client] = false;
	else
		g_bCSD[client] = true;

    CHUD_CSD(client);
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

	CHUD_CSD(client);
}

/////
//POSITION
/////
public void CSD_Position(int client)
{

	Menu menu = CreateMenu(CHUD_CSD_Position_Handler);
	SetMenuTitle(menu, "Center Speed | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fCSD_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fCSD_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CSD_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: CSD_PosX(param1);
			case 1: CSD_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_CSD(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void CSD_PosX(int client)
{
	if (g_fCSD_POSX[client] < 1.0)
		g_fCSD_POSX[client] += 0.05;
	else
		g_fCSD_POSX[client] = 0.0;

	CSD_Position(client);
}

void CSD_PosY(int client)
{
	if (g_fCSD_POSY[client] < 1.0)
		g_fCSD_POSY[client] += 0.05;
	else
		g_fCSD_POSY[client] = 0.0;

	CSD_Position(client);
}

/////
//COLOR
/////
public void CSD_Color(int client)
{
	Menu menu = CreateMenu(CHUD_CSD_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Center Speed | Color\n \n");

	Format(szItem, sizeof szItem, "Gain     | %d %d %d", g_iCSD_Color[client][0][0], g_iCSD_Color[client][0][1], g_iCSD_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Loss     | %d %d %d", g_iCSD_Color[client][1][0], g_iCSD_Color[client][1][1], g_iCSD_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Maintain | %d %d %d", g_iCSD_Color[client][2][0], g_iCSD_Color[client][2][1], g_iCSD_Color[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CSD_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		CSD_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		CHUD_CSD(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CSD_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(CSD_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Center Speed | Gain Color\n \n");
		case 1: SetMenuTitle(menu, "Center Speed | Loss Color\n \n");
		case 2: SetMenuTitle(menu, "Center Speed | Maintain Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iCSD_Color[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iCSD_Color[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iCSD_Color[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CSD_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){

		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		CSD_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		CSD_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void CSD_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 1;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	WaitingForResponse[client] = ChangeColor;
}

/////
//MISC
////
int[] GetSpeedColourCSD(int client, float speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) ) {
		displayColor[0] = g_iCSD_Color[client][0][0];
		displayColor[1] = g_iCSD_Color[client][0][1];
		displayColor[2] = g_iCSD_Color[client][0][2];
	}
	//losing speed
	else if (g_fLastSpeed[client] > speed ) {
		displayColor[0] = g_iCSD_Color[client][1][0];
		displayColor[1] = g_iCSD_Color[client][1][1];
		displayColor[2] = g_iCSD_Color[client][1][2];
	}
	//not moving (speed == 0)
	else {
		displayColor[0] = g_iCSD_Color[client][2][0];
		displayColor[1] = g_iCSD_Color[client][2][1];
		displayColor[2] = g_iCSD_Color[client][2][2];
	}

	g_fLastSpeed[client] = speed;

	return displayColor;
}

/////
//DISPLAY
/////
public void CSD_Display(int client)
{
	if (g_bCSD[client] && !IsFakeClient(client)) {

		char szSpeed[128];
		int displayColor[3];
		int target;
		displayColor = GetSpeedColourCSD(client, GetSpeed(client));

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

		Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(g_fLastSpeed[target]));

		SetHudTextParams(g_fCSD_POSX[client] == 0.5 ? -1.0 : g_fCSD_POSX[client], g_fCSD_POSY[client] == 0.5 ? -1.0 : g_fCSD_POSY[client], 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, CSD_Handle, szSpeed);
	}
}

/////
//COOKIES
/////
public void CSD_ConvertStringToData(int client, char szData[512])
{           
	char szModules[7][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 7; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bCSD[client] = StringToInt(szModules[0]) == 1 ? true : false;

	g_iCSD_SpeedAxis[client] = StringToInt(szModules[1]);

	char szPosition[2][8];
	ExplodeString(szModules[2], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fCSD_POSX[client] = StringToFloat(szPosition[0]);
	g_fCSD_POSY[client] = StringToFloat(szPosition[1]);

	char szColorGain[3][8];
	ExplodeString(szModules[3], ":", szColorGain, sizeof szColorGain, sizeof szColorGain[]);
	g_iCSD_Color[client][0][0] = StringToInt(szColorGain[0]);
	g_iCSD_Color[client][0][1] = StringToInt(szColorGain[1]);
	g_iCSD_Color[client][0][2] = StringToInt(szColorGain[2]);

	char szColorLoss[3][8];
	ExplodeString(szModules[4], ":", szColorLoss, sizeof szColorLoss, sizeof szColorLoss[]);
	g_iCSD_Color[client][1][0] = StringToInt(szColorLoss[0]);
	g_iCSD_Color[client][1][1] = StringToInt(szColorLoss[1]);
	g_iCSD_Color[client][1][2] = StringToInt(szColorLoss[2]);

	char szColorMaintain[3][8];
	ExplodeString(szModules[5], ":", szColorMaintain, sizeof szColorMaintain, sizeof szColorMaintain[]);
	g_iCSD_Color[client][2][0] = StringToInt(szColorMaintain[0]);
	g_iCSD_Color[client][2][1] = StringToInt(szColorMaintain[1]);
	g_iCSD_Color[client][2][2] = StringToInt(szColorMaintain[2]);
}

char[] CSD_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bCSD[client]);

	//AXIS
	Format(szData, sizeof szData, "%s%d|", szData, g_iCSD_SpeedAxis[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fCSD_POSX[client], g_fCSD_POSY[client]);

	//COLORS
	//TYPE 1
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCSD_Color[client][0][0], g_iCSD_Color[client][0][1], g_iCSD_Color[client][0][2]);
	//TYPE 2
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCSD_Color[client][1][0], g_iCSD_Color[client][1][1], g_iCSD_Color[client][1][2]);
	//TYPE 3
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iCSD_Color[client][2][0], g_iCSD_Color[client][2][1], g_iCSD_Color[client][2][2]);

	return szData;
}