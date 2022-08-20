public Init_MAPINFO(){
	MapInfo_Handle = CreateHudSynchronizer();
}

public MapInfo_SetDefaults(int client)
{
    g_bMapInfo[client] = false;
    g_fMapInfo_POSX[client] = 0.5;
    g_fMapInfo_POSY[client] = 0.5;
    
    for (int i = 0; i < 3; i++)
        g_iMapInfo_Color[client][i] = 0;
    
    g_iMapInfo_CompareMode[client] = 1;
}

public void MHUD_MAPINFO(int client)
{
    if (!IsValidClient(client))
        return;
    
    Menu menu = CreateMenu(MHUD_MapInfo_Handler);
    char szItem[128];

    SetMenuTitle(menu, "MapInfo Options Menu\n \n");

    // Toggle
    if (g_bMapInfo[client])
        AddMenuItem(menu, "", "Toggle    | On");
    else
        AddMenuItem(menu, "", "Toggle    | Off");
        
    // Position
    Format(szItem, sizeof szItem, "Position  | %.1f %.1f", g_fMapInfo_POSX[client], g_fMapInfo_POSY[client]);
    AddMenuItem(menu, "", szItem);

    // Color
    Format(szItem, sizeof szItem, "Color      | %d %d %d", g_iMapInfo_Color[client][0], g_iMapInfo_Color[client][1], g_iMapInfo_Color[client][2]);
    AddMenuItem(menu, "", szItem);
    
    // Show Mode
    Format(szItem, sizeof szItem, "Show      | %s", g_iMapInfo_ShowMode[client] == 0 ? "PB" : "WR");
    AddMenuItem(menu, "", szItem);

    // Compare Mode
    Format(szItem, sizeof szItem, "Compare | %s", g_iMapInfo_CompareMode[client] == 0 ? "PB" : "WR");
    AddMenuItem(menu, "", szItem);

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_MapInfo_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: MapInfo_Toggle(param1, true);
			case 1: MapInfo_Position(param1);
			case 2: MapInfo_Color(param1);
            case 3: MapInfo_ShowMode(param1);
            case 4: MapInfo_CompareMode(param1);
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
public void MapInfo_Toggle(int client, bool from_menu)
{
    if (g_bMapInfo[client]) {
		g_bMapInfo[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bMapInfo[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_MAPINFO(client);
    }
}

/////
//POSITION
/////
public void MapInfo_Position(int client)
{

	Menu menu = CreateMenu(MHUD_MapInfo_Position_Handler);
	SetMenuTitle(menu, "MapInfo | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fMapInfo_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fMapInfo_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_MapInfo_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: MapInfo_PosX(param1);
			case 1: MapInfo_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		MHUD_MAPINFO(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void MapInfo_PosX(int client)
{
	if (g_fMapInfo_POSX[client] < 1.0){
		g_fMapInfo_POSX[client] += 0.1;
	}
	else
		g_fMapInfo_POSX[client] = 0.0;

	MapInfo_Position(client);
}

void MapInfo_PosY(int client)
{
	
	if (g_fMapInfo_POSY[client] < 1.0)
		g_fMapInfo_POSY[client] += 0.1;
	else
		g_fMapInfo_POSY[client] = 0.0;

	MapInfo_Position(client);
}


/////
//COLOR CHANGE
/////

public void MapInfo_Color(int client)
{   
    Menu menu = CreateMenu(MapInfo_Color_Change_Handler);
    SetMenuTitle(menu, "MapInfo | Color\n \n");

    //COLOR OPTIONS
    char szBuffer[128];
    Format(szBuffer, sizeof szBuffer, "%d", -2);

    char szItemDisplay[32];

    Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iMapInfo_Color[client][0]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iMapInfo_Color[client][1]);
    AddMenuItem(menu, szBuffer, szItemDisplay);

    Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iMapInfo_Color[client][2]);
    AddMenuItem(menu, szBuffer, szItemDisplay);
    
    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MapInfo_Color_Change_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		MapInfo_Color_Change(param1, -3, param2);
	else if (action == MenuAction_Cancel)
		MHUD_MAPINFO(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void MapInfo_Color_Change(int client, int color_type, int color_index)
{
    g_iColorIndex[client] = color_index;
    g_iColorType[client] = color_type;
    g_iWaitingForResponse[client] = ChangeColor;
}

/////
//COMPARE MODE
/////
void MapInfo_CompareMode(int client)
{
	if (g_iMapInfo_CompareMode[client] != 1)
		g_iMapInfo_CompareMode[client]++;
	else
		g_iMapInfo_CompareMode[client] = 0;

	MHUD_MAPINFO(client);
}

/////
//SHOW MODE
/////
void MapInfo_ShowMode(int client)
{
	if (g_iMapInfo_ShowMode[client] != 1)
		g_iMapInfo_ShowMode[client]++;
	else
		g_iMapInfo_ShowMode[client] = 0;

	MHUD_MAPINFO(client);
}

/////
//DISPAY
/////

public void MapInfo_Display(int client)
{   
    if(g_bMapInfo[client] && !IsFakeClient(client)) {
        int target;

        //FINAL STRING
        char szMapInfo[128];

        if (IsPlayerAlive(client))
            target = client;
        else
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

        if(target == -1)
            return;

        char szWRName[MAX_NAME_LENGTH], szWRTime[32];
        float WRTime;
        surftimer_GetMapData(szWRName, szWRTime, WRTime);

        float client_runtime;
        int client_rank;
        char szClientCountry[100], szClientCountryCode[3], szClientContinentCode[3];
        surftimer_GetPlayerData(target, client_runtime, client_rank, szClientCountry, szClientCountryCode, szClientContinentCode);

        //FORMAT SHOW MODE
        if ( g_iMapInfo_ShowMode[client] == 0) {
            char szPBFormatted[32];
            FormatTimeFloat(client, client_runtime, szPBFormatted, sizeof szPBFormatted, true);
            Format(szMapInfo, sizeof szMapInfo, "PB %s |", szPBFormatted);

            //FORMAT COMPARE MODE
            if ( g_iMapInfo_CompareMode[client] == 0) {
                Format(szMapInfo, sizeof szMapInfo, "%s PB +00:00.000", szPBFormatted);
            }
            else if ( g_iMapInfo_CompareMode[client] == 1) {
                char szWRDiffFormatted[32];
                FormatTimeFloat(client, client_runtime - WRTime, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s WR +%s", szPBFormatted, szWRDiffFormatted);
            }

        }
        else if ( g_iMapInfo_ShowMode[client] == 1) {
            char szWRFormatted[32];
            FormatTimeFloat(client, WRTime, szWRFormatted, sizeof szWRFormatted, true);
            Format(szMapInfo, sizeof szMapInfo, "WR %s |", szWRFormatted);

            //FORMAT COMPARE MODE
            if ( g_iMapInfo_CompareMode[client] == 0) {
                char szPBDiffFormatted[32];
                FormatTimeFloat(client, client_runtime - WRTime, szPBDiffFormatted, sizeof szPBDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s PB -%s", szWRFormatted, szPBDiffFormatted);
            }
            else if ( g_iMapInfo_CompareMode[client] == 1) {
                char szWRDiffFormatted[32];
                FormatTimeFloat(client, WRTime - client_runtime, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s WR +00:00.000", szWRFormatted, szWRDiffFormatted);
            }
        }

        SetHudTextParams(g_fMapInfo_POSX[client] == 0.5 ? -1.0 : g_fMapInfo_POSX[client], g_fMapInfo_POSY[client] == 0.5 ? -1.0 : g_fMapInfo_POSY[client], 1.0, g_iMapInfo_Color[client][0], g_iMapInfo_Color[client][1], g_iMapInfo_Color[client][2], 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudText(client, MapInfo_Handle, szMapInfo);
    }
}

/////
//SQL
/////
public void db_LoadMapInfo(int client)
{
	char szQuery[1024];

	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_MAPINFO WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadMapInfoCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadMapInfoCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadMapInfoCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) 
    {
        g_bMapInfo[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

        //POSITION
        char MapInfoPos[32];
        char MapInfoPos_SPLIT[2][12];
        SQL_FetchString(hndl, 2, MapInfoPos, sizeof MapInfoPos);
        ExplodeString(MapInfoPos, "|", MapInfoPos_SPLIT, sizeof MapInfoPos_SPLIT, sizeof MapInfoPos_SPLIT[]);
        g_fMapInfo_POSX[client] = StringToFloat(MapInfoPos_SPLIT[0]);
        g_fMapInfo_POSY[client] = StringToFloat(MapInfoPos_SPLIT[1]);
        
        //GAIN COLOR
        char MapInfoColor[32];
        char MapInfoColor_SPLIT[3][12];
        SQL_FetchString(hndl, 3, MapInfoColor, sizeof MapInfoColor);
        ExplodeString(MapInfoColor, "|", MapInfoColor_SPLIT, sizeof MapInfoColor_SPLIT, sizeof MapInfoColor_SPLIT[]);
        g_iMapInfo_Color[client][0][0] = StringToInt(MapInfoColor_SPLIT[0]);
        g_iMapInfo_Color[client][0][1] = StringToInt(MapInfoColor_SPLIT[1]);
        g_iMapInfo_Color[client][0][2] = StringToInt(MapInfoColor_SPLIT[2]);
        
        g_iMapInfo_ShowMode[client] = SQL_FetchInt(hndl, 4);
        g_iMapInfo_CompareMode[client] = SQL_FetchInt(hndl, 5);
	}
	else {
        char szQuery[1024];
        Format(szQuery, sizeof szQuery, "INSERT INTO mh_MAPINFO (steamid) VALUES('%s')", g_szSteamID[client]);
        SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

        MapInfo_SetDefaults(client);
	}

}

public void db_updateMapInfo(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[4];
	char szPosY[4];
	char szColor[32];
	char szColor_R[3];
	char szColor_G[3];
	char szColor_B[3];

	FloatToString(g_fMapInfo_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fMapInfo_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iMapInfo_Color[client][0], szColor_R, sizeof szColor_R);
	IntToString(g_iMapInfo_Color[client][1], szColor_G, sizeof szColor_G);
	IntToString(g_iMapInfo_Color[client][2], szColor_B, sizeof szColor_B);
	Format(szColor, sizeof szColor, "%d|%d|%d", szColor_R, szColor_G, szColor_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_MAPINFO SET enabled = '%i', pos = '%s', color = '%s', showmode = '%i', comparemode = '%i'  WHERE steamid = '%s';", g_bKeys ? '1' : '0', szPosition, szColor, g_iMapInfo_ShowMode[client], g_iMapInfo_CompareMode[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}