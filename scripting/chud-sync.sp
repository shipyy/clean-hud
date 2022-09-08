public Init_SYNC(){
	Sync_Handle = CreateHudSynchronizer();
}

public Sync_SetDefaults(int client)
{
    PrintToServer("Loading Sync Defaults!");

    g_bSync[client] = false;
    g_fSync_POSX[client] = 0.5;
    g_fSync_POSY[client] = 0.5;

    for (int i = 0; i < 3; i++)
        g_iSync_Color[client][i] = 255;
}

public void CHUD_SYNC(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_Sync_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Sync Options Menu\n \n");

	// Toggle
	if (g_bSync[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");
		
	// Position
	Format(szItem, sizeof szItem, "Position | %.1f %.1f", g_fSync_POSX[client], g_fSync_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	Format(szItem, sizeof szItem, "Color      | %d %d %d\n \n", g_iSync_Color[client][0], g_iSync_Color[client][1], g_iSync_Color[client][2]);
	AddMenuItem(menu, "", szItem);

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Sync_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Sync_Toggle(param1, true);
			case 1: Sync_Position(param1);
			case 2: Sync_Color(param1);
			case 3: Export(param1, 2, false, true);
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
public void Sync_Toggle(int client, bool from_menu)
{
    if (g_bSync[client]) {
		g_bSync[client] = false;
	}
	else {
		g_bSync[client] = true;
	}

    if (from_menu) {
        CHUD_SYNC(client);
    }
}

/////
//POSITION
/////
public void Sync_Position(int client)
{

	Menu menu = CreateMenu(CHUD_Sync_Position_Handler);
	SetMenuTitle(menu, "Sync | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fSync_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fSync_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Sync_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: Sync_PosX(param1);
			case 1: Sync_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_SYNC(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Sync_PosX(int client)
{
	if (g_fSync_POSX[client] < 1.0){
		g_fSync_POSX[client] += 0.05;
	}
	else
		g_fSync_POSX[client] = 0.0;

	Sync_Position(client);
}

void Sync_PosY(int client)
{
	
	if (g_fSync_POSY[client] < 1.0)
		g_fSync_POSY[client] += 0.05;
	else
		g_fSync_POSY[client] = 0.0;

	Sync_Position(client);
}


/////
//COLOR CHANGE
/////
public void Sync_Color(int client)
{   
    Menu menu = CreateMenu(Sync_Color_Change_Handler);
    SetMenuTitle(menu, "Sync | Color\n \n");

    //COLOR OPTIONS
    char szBuffer[128];
    Format(szBuffer, sizeof szBuffer, "%d", -2);

    char szItemDisplay[32];

    Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iSync_Color[client][0]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iSync_Color[client][1]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iSync_Color[client][2]);
    AddMenuItem(menu, szBuffer, szItemDisplay);
    
    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int Sync_Color_Change_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		Sync_Color_Change(param1, -2, param2);
	else if (action == MenuAction_Cancel)
		CHUD_SYNC(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Sync_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	WaitingForResponse[client] = ChangeColor;
}

/////
//DISPAY
/////
public void Sync_Display(int client)
{   
    if (g_bSync[client] && !IsFakeClient(client)) {

		int target;

		//FINAL STRING
		char szSync[32];
		
		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		if(target == -1)
			return;

		Format(szSync, sizeof szSync, "%.2f%", surftimer_GetClientSync(target));
		
		//COLOR
		int displayColor[3];
		displayColor[0] = g_iSync_Color[client][0];
		displayColor[1] = g_iSync_Color[client][1];
		displayColor[2] = g_iSync_Color[client][2];
		
		SetHudTextParams(g_fSync_POSX[client] == 0.5 ? -1.0 : g_fSync_POSX[client], g_fSync_POSY[client] == 0.5 ? -1.0 : g_fSync_POSY[client], 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, Sync_Handle, szSync);
    }
}

/////
//COOKIES
/////
public void Sync_ConvertStringToData(int client, char szData[512])
{           
	char szModules[4][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 4; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bSync[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fSync_POSX[client] = StringToFloat(szPosition[0]);
	g_fSync_POSY[client] = StringToFloat(szPosition[1]);

	char szColor[3][8];
	ExplodeString(szModules[2], ":", szColor, sizeof szColor, sizeof szColor[]);
	g_iSync_Color[client][0] = StringToInt(szColor[0]);
	g_iSync_Color[client][1] = StringToInt(szColor[1]);
	g_iSync_Color[client][2] = StringToInt(szColor[2]);
}

char[] Sync_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bSync[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fSync_POSX[client], g_fSync_POSY[client]);

	//COLOR
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iSync_Color[client][0], g_iSync_Color[client][1], g_iSync_Color[client][2]);

	return szData;
}