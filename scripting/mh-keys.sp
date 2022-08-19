public Keys_SetDefaults(int client){
	g_bKeys[client] = 0;
	g_fKeys_POSX[client] = 0.5;
	g_fKeys_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		g_iKeys_Color[client][i] = 0;
	
	g_iKeys_UpdateRate[client] = 0;
}

public void MHUD_Keys(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_Keys_Handler);
	SetMenuTitle(menu, "Key Options Menu\n \n");

	// Centre Speed Display
	if (g_bKeys[client])
		AddMenuItem(menu, "", "On  | Toggle");
	else
		AddMenuItem(menu, "", "Off | Toggle");

	// CENTER SPEED POSITIONS
	AddMenuItem(menu, "", "Keys Position");

	// Speed Color
	AddMenuItem(menu, "", "Keys Color");

	// CSD Update Rate
	if (g_iKeys_UpdateRate[client] == 0)
		AddMenuItem(menu, "", "Slow   | Update Rate");
	else if (g_iKeys_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "Medium | Update Rate");
	else
		AddMenuItem(menu, "", "Fast   | Update Rate");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Keys_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Keys_Toggle(param1, true);
			case 1: Keys_Position(param1);
			case 2: Keys_Color(param1);
			case 3: Keys_UpdateRate(param1, true);
		}
	}
	else if (action == MenuAction_Cancel)
		MHUD_MainMenu_Display(param1);
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
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bKeys[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_Keys(client);
    }
}

/////
//POSITION
/////
public void Keys_Position(int client)
{

	Menu menu = CreateMenu(MHUD_Keys_Position_Handler);
	SetMenuTitle(menu, "Keys | Position\n \n");

	// CENTER SPEED POSITIONS
	char Display_String[256];
	// POS X
	Format(Display_String, 256, "Position X : %.2f", g_fKeys_POSX[client]);
	AddMenuItem(menu, "", Display_String);
	// POX Y
	Format(Display_String, 256, "Position Y : %.2f", g_fKeys_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Keys_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		MHUD_Keys(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Keys_PosX(int client)
{
	if (g_fKeys_POSX[client] < 1.0){
		g_fKeys_POSX[client] += 0.1;
	}
	else
		g_fKeys_POSX[client] = 0.0;

	Keys_Position(client);
}

void Keys_PosY(int client)
{
	
	if (g_fKeys_POSY[client] < 1.0)
		g_fKeys_POSY[client] += 0.1;
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
    SetMenuTitle(menu, "Center Speed | Color\n \n");

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
		MHUD_Keys(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Keys_Color_Change(int client, int color_type, int color_index)
{
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

public void Keys_Display(int client)
{   
    int update_rate;
	
    if(g_bKeys[client]){
		switch(g_iKeys_UpdateRate[client]){
			case 0: update_rate = 15;
			case 1:	update_rate = 10;
			case 2: update_rate = 5;
			default: update_rate = 15;
		}
	}
    
    if(g_iClientTick[client] - g_iCurrentTick[client] >= update_rate)
	{
		g_iCurrentTick[client] += update_rate;
		if (g_bKeys[client] && IsValidClient(client) && !IsFakeClient(client) && IsClientInGame(client))
		{
            //BUTTONS
            int Buttons;

            if (IsPlayerAlive(client))
                Buttons = g_iLastButton[client];
			else {
                int ObservedUser;
                ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

                Buttons = g_iLastButton[ObservedUser];
            }
            
            //COLOR
            int displayColor[3];
            displayColor[0] = g_iKeys_Color[client][0];
            displayColor[1] = g_iKeys_Color[client][1];
            displayColor[2] = g_iKeys_Color[client][2];
            
            //BUTTONS
            bool holdingS = (Buttons & IN_BACK == IN_BACK);
            bool holdingC = (Buttons & IN_DUCK == IN_DUCK);
            bool holdingW = (Buttons & IN_FORWARD == IN_FORWARD);
            bool holdingA = (Buttons & IN_MOVELEFT == IN_MOVELEFT);
            bool holdingD = (Buttons & IN_MOVERIGHT == IN_MOVERIGHT);
            bool holdingJ = (Buttons & IN_JUMP == IN_JUMP);
            bool turnbindLeft = (Buttons & IN_LEFT == IN_LEFT);
            bool turnbindRight = (Buttons & IN_RIGHT == IN_RIGHT);

            char Keys[8][3] = { "W", "A", "S", "D", "C", "J", "◄", "►"};

            if (!holdingW) 
                Keys[0] = "_";
            if (!holdingA) 
                Keys[1] = "_";
            if (!holdingS) 
                Keys[2] = "_";
            if (!holdingD) 
                Keys[3] = "_";
            if (!holdingC) 
                Keys[4] = "_";
            if (!holdingJ) 
                Keys[5] = "_";
            if (!turnbindLeft) 
                Keys[6] = "_";
            if (!turnbindRight) 
                Keys[7] = "_";
            
            //FINAL STRING
            char szKeys[32];

            Format(szKeys, sizeof szKeys, "   %s  \n%s %s %s\n%s    %s\n%s    %s", Keys[0], Keys[1], Keys[2], Keys[3], Keys[4], Keys[5], Keys[6], Keys[7]);

            SetHudTextParams(g_fKeys_POSX[client] == 0.5 ? -1.0 : g_fKeys_POSX[client], g_fKeys_POSY[client] == 0.5 ? -1.0 : g_fKeys_POSY[client], update_rate / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
            ShowSyncHudText(client, Keys_Handle, szKeys);
		}
	}
}

/////
//UPDATE RATE
/////
void Keys_UpdateRate(int client, bool from_menu)
{
	if (g_iKeys_UpdateRate[client] != 2)
		g_iKeys_UpdateRate[client]++;
	else
		g_iKeys_UpdateRate[client] = 0;

	if (from_menu) {
		MHUD_Keys(client);
	}
}

/////
//SQL
/////
public void db_LoadKeys(int client)
{
	char szQuery[1024];

	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_Keys WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadKeysCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadKeysCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadKeysCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) 
    {
        g_bKeys[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

        //POSITION
        char KeysPos[32];
        char KeysPos_SPLIT[2][12];
        SQL_FetchString(hndl, 2, KeysPos, sizeof KeysPos);
        ExplodeString(KeysPos, "|", KeysPos_SPLIT, sizeof KeysPos_SPLIT, sizeof KeysPos_SPLIT[]);
        g_fKeys_POSX[client] = StringToFloat(KeysPos_SPLIT[0]);
        g_fKeys_POSY[client] = StringToFloat(KeysPos_SPLIT[1]);
        
        //GAIN COLOR
        char KeysColor[32];
        char KeysColor_SPLIT[3][12];
        SQL_FetchString(hndl, 3, KeysColor, sizeof KeysColor);
        ExplodeString(KeysColor, "|", KeysColor_SPLIT, sizeof KeysColor_SPLIT, sizeof KeysColor_SPLIT[]);
        g_iKeys_Color[client][0][0] = StringToInt(KeysColor_SPLIT[0]);
        g_iKeys_Color[client][0][1] = StringToInt(KeysColor_SPLIT[1]);
        g_iKeys_Color[client][0][2] = StringToInt(KeysColor_SPLIT[2]);
        
        g_iKeys_UpdateRate[client] = SQL_FetchInt(hndl, 4);
	}
	else {
        char szQuery[1024];
        Format(szQuery, sizeof szQuery, "INSERT INTO mh_Keys (steamid) VALUES('%s')", g_szSteamID[client]);
        PrintToServer(szQuery);
        SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

        Keys_SetDefaults(client);
	}

}

public void db_updateKeys(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[4];
	char szPosY[4];
	char szColor[32];
	char szColor_R[3];
	char szColor_G[3];
	char szColor_B[3];

	FloatToString(g_fKeys_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fKeys_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%f|%f", szPosX, szPosY);

	IntToString(g_iKeys_Color[client][0], szColor_R, sizeof szColor_R);
	IntToString(g_iKeys_Color[client][1], szColor_G, sizeof szColor_G);
	IntToString(g_iKeys_Color[client][2], szColor_B, sizeof szColor_B);
	Format(szColor, sizeof szColor, "%d|%d|%d", szColor_R, szColor_G, szColor_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_KEYS SET enable = '%i', pos = '%s', color = '%s', updaterate = '%i' WHERE steamid = '%s';", g_bCSD ? '1' : '0', szPosition, szColor, g_iKeys_UpdateRate[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}