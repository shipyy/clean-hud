public Init_SYNC(){
	Sync_Handle = CreateHudSynchronizer();
}

public Sync_SetDefaults(int client){
	g_bSync[client] = 0;
	g_fSync_POSX[client] = 0.5;
	g_fSync_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		g_iSync_Color[client][i] = 0;
	
	g_iSync_UpdateRate[client] = 0;
}

public void MHUD_SYNC(int client)
{
    if (!IsValidClient(client))
        return;
    
    Menu menu = CreateMenu(MHUD_Sync_Handler);
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
    Format(szItem, sizeof szItem, "Color      | %d %d %d", g_iSync_Color[client][0], g_iSync_Color[client][1], g_iSync_Color[client][2]);
    AddMenuItem(menu, "", szItem);
    
    // Refresh
    if (g_iSync_UpdateRate[client] == 0)
        AddMenuItem(menu, "", "Refresh  | SLOW");
    else if (g_iSync_UpdateRate[client] == 1)
        AddMenuItem(menu, "", "Refresh  | MEDIUM");
    else
        AddMenuItem(menu, "", "Refresh  | FAST ");
    
    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Sync_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Sync_Toggle(param1, true);
			case 1: Sync_Position(param1);
			case 2: Sync_Color(param1);
			case 3: Sync_UpdateRate(param1, true);
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
public void Sync_Toggle(int client, bool from_menu)
{
    if (g_bSync[client]) {
		g_bSync[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bSync[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_SYNC(client);
    }
}

/////
//POSITION
/////
public void Sync_Position(int client)
{

	Menu menu = CreateMenu(MHUD_Sync_Position_Handler);
	SetMenuTitle(menu, "Sync | Position\n \n");

	// POSITIONS
	char Display_String[256];
	// POS X
	Format(Display_String, 256, "Position X : %.2f", g_fSync_POSX[client]);
	AddMenuItem(menu, "", Display_String);
	// POX Y
	Format(Display_String, 256, "Position Y : %.2f", g_fSync_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Sync_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		MHUD_SYNC(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Sync_PosX(int client)
{
	if (g_fSync_POSX[client] < 1.0){
		g_fSync_POSX[client] += 0.1;
	}
	else
		g_fSync_POSX[client] = 0.0;

	Sync_Position(client);
}

void Sync_PosY(int client)
{
	
	if (g_fSync_POSY[client] < 1.0)
		g_fSync_POSY[client] += 0.1;
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
    SetMenuTitle(menu, "Center Speed | Color\n \n");

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
		MHUD_SYNC(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Sync_Color_Change(int client, int color_type, int color_index)
{
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

public void Sync_Display(int client)
{   
    if (g_bSync[client] && !IsFakeClient(client)) {
        if(g_iClientTick[client][2] - g_iCurrentTick[client][2] >= GetUpdateRate(g_iSync_UpdateRate[client])) 
        {
            g_iCurrentTick[client][2] += GetUpdateRate(g_iSync_UpdateRate[client]);
            
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
            
            SetHudTextParams(g_fSync_POSX[client] == 0.5 ? -1.0 : g_fSync_POSX[client], g_fSync_POSY[client] == 0.5 ? -1.0 : g_fSync_POSY[client], GetUpdateRate(g_iSync_UpdateRate[client]) / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
            ShowSyncHudText(client, Sync_Handle, szSync);
        }
    }
}

/////
//UPDATE RATE
/////
void Sync_UpdateRate(int client, bool from_menu)
{
	if (g_iSync_UpdateRate[client] != 2)
		g_iSync_UpdateRate[client]++;
	else
		g_iSync_UpdateRate[client] = 0;

	if (from_menu) {
		MHUD_SYNC(client);
	}
}

/////
//SQL
/////
public void db_LoadSync(int client)
{
	char szQuery[1024];

	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_SYNC WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadSyncCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadSyncCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadSyncCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) 
    {
        g_bSync[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

        //POSITION
        char SyncPos[32];
        char SyncPos_SPLIT[2][12];
        SQL_FetchString(hndl, 2, SyncPos, sizeof SyncPos);
        ExplodeString(SyncPos, "|", SyncPos_SPLIT, sizeof SyncPos_SPLIT, sizeof SyncPos_SPLIT[]);
        g_fSync_POSX[client] = StringToFloat(SyncPos_SPLIT[0]);
        g_fSync_POSY[client] = StringToFloat(SyncPos_SPLIT[1]);
        
        //GAIN COLOR
        char SyncColor[32];
        char SyncColor_SPLIT[3][12];
        SQL_FetchString(hndl, 3, SyncColor, sizeof SyncColor);
        ExplodeString(SyncColor, "|", SyncColor_SPLIT, sizeof SyncColor_SPLIT, sizeof SyncColor_SPLIT[]);
        g_iSync_Color[client][0][0] = StringToInt(SyncColor_SPLIT[0]);
        g_iSync_Color[client][0][1] = StringToInt(SyncColor_SPLIT[1]);
        g_iSync_Color[client][0][2] = StringToInt(SyncColor_SPLIT[2]);
        
        g_iSync_UpdateRate[client] = SQL_FetchInt(hndl, 4);
	}
	else {
        char szQuery[1024];
        Format(szQuery, sizeof szQuery, "INSERT INTO mh_SYNC (steamid) VALUES('%s')", g_szSteamID[client]);
        PrintToServer(szQuery);
        SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

        Sync_SetDefaults(client);
	}

}

public void db_updateSync(int client)
{
	char szQuery[1024];

	char szPosition[12];
	char szPosX[4];
	char szPosY[4];
	char szColor[32];
	char szColor_R[3];
	char szColor_G[3];
	char szColor_B[3];

	FloatToString(g_fSync_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fSync_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iSync_Color[client][0], szColor_R, sizeof szColor_R);
	IntToString(g_iSync_Color[client][1], szColor_G, sizeof szColor_G);
	IntToString(g_iSync_Color[client][2], szColor_B, sizeof szColor_B);
	Format(szColor, sizeof szColor, "%d|%d|%d", szColor_R, szColor_G, szColor_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_SYNC SET enabled = '%i', pos = '%s', color = '%s', updaterate = '%i' WHERE steamid = '%s';", g_bKeys ? '1' : '0', szPosition, szColor, g_iSync_UpdateRate[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}