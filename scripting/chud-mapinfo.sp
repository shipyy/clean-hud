public Init_MAPINFO(){
	MapInfo_Handle = CreateHudSynchronizer();
}

public MapInfo_SetDefaults(int client)
{
    PrintToServer("Loading MapInfo Defaults!");

    g_bMapInfo[client] = false;
    g_fMapInfo_POSX[client] = 0.5;
    g_fMapInfo_POSY[client] = 0.5;
    
    for (int i = 0; i < 3; i++)
        g_iMapInfo_Color[client][i] = 255;
    
    g_iMapInfo_CompareMode[client] = 1;
}

public void CHUD_MAPINFO(int client)
{
    if (!IsValidClient(client))
        return;

    Menu menu = CreateMenu(CHUD_MapInfo_Handler);
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
    Format(szItem, sizeof szItem, "Compare | %s", g_iMapInfo_CompareMode[client] == 0 ? "PB\n \n" : "WR\n \n");
    AddMenuItem(menu, "", szItem);

    // EXPORT
    AddMenuItem(menu, "", "Export Settings");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_MapInfo_Handler(Menu menu, MenuAction action, int param1, int param2)
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
            case 5: Export(param1, 5, false, true);
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
        CHUD_MAPINFO(client);
    }
}

/////
//POSITION
/////
public void MapInfo_Position(int client)
{

	Menu menu = CreateMenu(CHUD_MapInfo_Position_Handler);
	SetMenuTitle(menu, "MapInfo | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fMapInfo_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fMapInfo_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_MapInfo_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		CHUD_MAPINFO(param1);
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
		CHUD_MAPINFO(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void MapInfo_Color_Change(int client, int color_type, int color_index)
{
    CPrintToChat(client, "%t", "Color_Input");
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

	CHUD_MAPINFO(client);
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

	CHUD_MAPINFO(client);
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
        char szClientCountry[16], szClientCountryCode[3], szClientContinentCode[3];
        surftimer_GetPlayerData(target, client_runtime, client_rank, szClientCountry, szClientCountryCode, szClientContinentCode);

        //FORMAT SHOW MODE
        if ( g_iMapInfo_ShowMode[client] == 0) {
            char szPBFormatted[32];
            Format_Time(client, client_runtime, szPBFormatted, sizeof szPBFormatted, true);
            Format(szMapInfo, sizeof szMapInfo, "PB %s |", szPBFormatted);

            //FORMAT COMPARE MODE
            if ( g_iMapInfo_CompareMode[client] == 0) {
                Format(szMapInfo, sizeof szMapInfo, "%s PB +00:00.000", szPBFormatted);
            }
            else if ( g_iMapInfo_CompareMode[client] == 1) {
                char szWRDiffFormatted[32];
                Format_Time(client, client_runtime - WRTime, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s WR +%s", szPBFormatted, szWRDiffFormatted);
            }

        }
        else if ( g_iMapInfo_ShowMode[client] == 1) {
            char szWRFormatted[32];
            Format_Time(client, WRTime, szWRFormatted, sizeof szWRFormatted, true);
            Format(szMapInfo, sizeof szMapInfo, "WR %s |", szWRFormatted);

            //FORMAT COMPARE MODE
            if ( g_iMapInfo_CompareMode[client] == 0) {
                char szPBDiffFormatted[32];
                Format_Time(client, client_runtime - WRTime, szPBDiffFormatted, sizeof szPBDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s PB -%s", szWRFormatted, szPBDiffFormatted);
            }
            else if ( g_iMapInfo_CompareMode[client] == 1) {
                char szWRDiffFormatted[32];
                Format_Time(client, WRTime - client_runtime, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szMapInfo, sizeof szMapInfo, "%s WR +00:00.000", szWRFormatted, szWRDiffFormatted);
            }
        }

        SetHudTextParams(g_fMapInfo_POSX[client] == 0.5 ? -1.0 : g_fMapInfo_POSX[client], g_fMapInfo_POSY[client] == 0.5 ? -1.0 : g_fMapInfo_POSY[client], 1.0, g_iMapInfo_Color[client][0], g_iMapInfo_Color[client][1], g_iMapInfo_Color[client][2], 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudText(client, MapInfo_Handle, szMapInfo);
    }
}

/////
//COOKIES
/////
public void MapInfo_ConvertStringToData(int client, char szData[512])
{           
    char szModules[5][16];
    ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
    for(int i = 0; i < 5; i++)
        ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

    g_bMapInfo[client] = StringToInt(szModules[0]) == 1 ? true : false;

    char szPosition[2][8];
    ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
    g_fMapInfo_POSX[client] = StringToFloat(szPosition[0]);
    g_fMapInfo_POSY[client] = StringToFloat(szPosition[1]);

    char szColor[3][8];
    ExplodeString(szModules[2], ":", szColor, sizeof szColor, sizeof szColor[]);
    g_iMapInfo_Color[client][0] = StringToInt(szColor[0]);
    g_iMapInfo_Color[client][1] = StringToInt(szColor[1]);
    g_iMapInfo_Color[client][2] = StringToInt(szColor[2]);

    g_iMapInfo_ShowMode[client] = StringToInt(szModules[3]);
    g_iMapInfo_CompareMode[client] = StringToInt(szModules[4]);
}

char[] MapInfo_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bMapInfo[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fMapInfo_POSX[client], g_fMapInfo_POSY[client]);

	//COLOR
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iMapInfo_Color[client][0], g_iMapInfo_Color[client][1], g_iMapInfo_Color[client][2]);

	//SHOW MODE
	Format(szData, sizeof szData, "%s%d|", szData, g_iMapInfo_ShowMode[client]);

    //COMPARE MODE
	Format(szData, sizeof szData, "%s%d", szData, g_iMapInfo_CompareMode[client]);

	return szData;
}