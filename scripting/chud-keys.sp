public Init_KEYS(){
	Keys_Handle = CreateHudSynchronizer();
}

public Keys_SetDefaults(int client)
{
	PrintToServer("Loading Keys Defaults!");

	g_bKeys[client] = false;
	g_fKeys_POSX[client] = 0.5;
	g_fKeys_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		g_iKeys_Color[client][i] = 255;
}

public void CHUD_KEYS(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_Keys_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Key Options Menu\n \n");

	// Toggle
	if (g_bKeys[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");


	// Position
	Format(szItem, sizeof szItem, "Position | %.1f %.1f", g_fKeys_POSX[client], g_fKeys_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	Format(szItem, sizeof szItem, "Color      | %d %d %d\n \n", g_iKeys_Color[client][0], g_iKeys_Color[client][1], g_iKeys_Color[client][2]);
	AddMenuItem(menu, "", szItem);

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Keys_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Keys_Toggle(param1, true);
			case 1: Keys_Position(param1);
			case 2: Keys_Color(param1);
			case 3: Export(param1, 1, false, true);
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
public void Keys_Toggle(int client, bool from_menu)
{
    if (g_bKeys[client]) {
		g_bKeys[client] = false;
		
	}
	else {
		g_bKeys[client] = true;
		
	}

    if (from_menu) {
        CHUD_KEYS(client);
    }
}

/////
//POSITION
/////
public void Keys_Position(int client)
{

	Menu menu = CreateMenu(CHUD_Keys_Position_Handler);
	SetMenuTitle(menu, "Keys | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fKeys_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fKeys_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_Keys_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: Keys_PosX(param1);
			case 1: Keys_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		CHUD_KEYS(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Keys_PosX(int client)
{
	if (g_fKeys_POSX[client] < 1.0){
		g_fKeys_POSX[client] += 0.05;
	}
	else
		g_fKeys_POSX[client] = 0.0;

	Keys_Position(client);
}

void Keys_PosY(int client)
{
	
	if (g_fKeys_POSY[client] < 1.0)
		g_fKeys_POSY[client] += 0.05;
	else
		g_fKeys_POSY[client] = 0.0;

	Keys_Position(client);
}

/////
//COLOR CHANGE
/////
public void Keys_Color(int client)
{   
    Menu menu = CreateMenu(Keys_Color_Change_Handler);
    SetMenuTitle(menu, "Keys | Color\n \n");

    //COLOR OPTIONS
    char szBuffer[128];
    Format(szBuffer, sizeof szBuffer, "%d", -1);

    char szItemDisplay[32];

    Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iKeys_Color[client][0]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iKeys_Color[client][1]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iKeys_Color[client][2]);
    AddMenuItem(menu, szBuffer, szItemDisplay);
    
    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int Keys_Color_Change_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		Keys_Color_Change(param1, -1, param2);
	else if (action == MenuAction_Cancel)
		CHUD_KEYS(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Keys_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	WaitingForResponse[client] = ChangeColor;
}

/////
//DISPLAY
/////
public void Keys_Display(int client)
{   
	if (g_bKeys[client] && !IsFakeClient(client)) {

		int target;

		if (IsPlayerAlive(client))
			target = client;
		else
			target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(target == -1)
			return;

		//COLOR
		int displayColor[3];
		displayColor[0] = g_iKeys_Color[client][0];
		displayColor[1] = g_iKeys_Color[client][1];
		displayColor[2] = g_iKeys_Color[client][2];
		
		//KEYS
		int Buttons;
		Buttons = g_iLastButton[target];
		char Keys[10][5];
		
		Keys[0] = (Buttons & IN_FORWARD == IN_FORWARD) ? "W" : "_";
		Keys[1] = (Buttons & IN_MOVELEFT == IN_MOVELEFT) ? "A" : "_";
		Keys[2] = (Buttons & IN_BACK == IN_BACK) ? "S" : "_";
		Keys[3] = (Buttons & IN_MOVERIGHT == IN_MOVERIGHT) ? "D" : "_";
		Keys[4] = (Buttons & IN_DUCK == IN_DUCK) ? "C" : "_";
		Keys[5] = (Buttons & IN_JUMP == IN_JUMP) ? "J" : "_";
		Keys[6] = (Buttons & IN_LEFT == IN_LEFT) ? "←" : "_";
		Keys[7] = (Buttons & IN_RIGHT == IN_RIGHT) ? "→" : "_";
		Keys[8] = (g_imouseDir[target][0] < 0)  ? "<" : "_";
		Keys[9] = (g_imouseDir[target][0] > 0)  ? ">" : "_";

		//FINAL STRING
		char szKeys[32];
		
		Format(szKeys, sizeof szKeys, "%s %s %s\n%s %s %s\n%s    %s\n%s    %s", Keys[8], Keys[0], Keys[9], Keys[1], Keys[2], Keys[3], Keys[4], Keys[5], Keys[6], Keys[7]);
		
		SetHudTextParams(g_fKeys_POSX[client] == 0.5 ? -1.0 : g_fKeys_POSX[client], g_fKeys_POSY[client] == 0.5 ? -1.0 : g_fKeys_POSY[client], 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, Keys_Handle, szKeys);
	}
}

/////
//COOKIES
/////
public void Keys_ConvertStringToData(int client, char szData[512])
{           
	char szModules[4][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 4; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bKeys[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fKeys_POSX[client] = StringToFloat(szPosition[0]);
	g_fKeys_POSY[client] = StringToFloat(szPosition[1]);

	char szColor[3][8];
	ExplodeString(szModules[2], ":", szColor, sizeof szColor, sizeof szColor[]);
	g_iKeys_Color[client][0] = StringToInt(szColor[0]);
	g_iKeys_Color[client][1] = StringToInt(szColor[1]);
	g_iKeys_Color[client][2] = StringToInt(szColor[2]);
}

char[] Keys_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bKeys[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fKeys_POSX[client], g_fKeys_POSY[client]);

	//COLOR
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iKeys_Color[client][0], g_iKeys_Color[client][1], g_iKeys_Color[client][2]);

	return szData;
}