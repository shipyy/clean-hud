public Init_FINISH(){
	Finish_Handle = CreateHudSynchronizer();
}

public Finish_SetDefaults(int client){
	g_bFinish[client] = false;
	g_fFinish_POSX[client] = 0.5;
	g_fFinish_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iFinish_Color[client][i][j] = 255;

	g_iFinish_HoldTime[client] = 3;
	g_iFinish_CompareMode[client] = 1;
}

public void MHUD_FINISH(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_Finish_Handler);
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
	Format(szItem, sizeof szItem, "Compare  | %s", g_iFinish_CompareMode[client] == 0 ? "PB" : "WR");
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Finish_Handler(Menu menu, MenuAction action, int param1, int param2)
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
public void Finish_Toggle(int client, bool from_menu)
{
    if (g_bFinish[client]) {
		g_bFinish[client] = false;
		//FinishrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bFinish[client] = true;
		//FinishrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_FINISH(client);
    }
}

/////
//POSITION
/////
public void Finish_Position(int client)
{

	Menu menu = CreateMenu(MHUD_Finish_Position_Handler);
	SetMenuTitle(menu, "Finish | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fFinish_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fFinish_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_Finish_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		MHUD_FINISH(param1);
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
	Menu menu = CreateMenu(MHUD_Finish_Color_Handler);
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

public int MHUD_Finish_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		Finish_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		MHUD_FINISH(param1);
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
	if (action == MenuAction_Select){

		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		Finish_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		Finish_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Finish_Color_Change(int client, int color_type, int color_index)
{
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

	MHUD_FINISH(client);
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

	MHUD_FINISH(client);
}

/////
//DISPLAY
/////

public void Finish_Display(int client, float runtime, float pb_diff, float wr_diff, int zonegroup)
{
    if (g_bFinish[client] && !IsFakeClient(client)) {
        int target;

        if (IsPlayerAlive(client))
            target = client;
        else
            target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
        
        if(target == -1)
            return;

        char szPBFormatted[32];
        char szPBDiffFormatted[32];
        char szWRDiffFormatted[32];

        if (g_iFinish_CompareMode[client] == 0) {
            FormatTimeFloat(client, runtime, szPBFormatted, sizeof szPBFormatted, true);

            if( zonegroup == 0) {
                FormatTimeFloat(client, pb_diff, szPBDiffFormatted, sizeof szPBDiffFormatted, true);
                Format(szPBFormatted, sizeof szPBFormatted, "Map Finished in %s | PB +%s", szPBFormatted, szPBDiffFormatted);
            }
            else {
                FormatTimeFloat(client, pb_diff, szPBDiffFormatted, sizeof szPBDiffFormatted, true);
                Format(szPBFormatted, sizeof szPBFormatted, "Bonus %d Finished in %s | PB +%s", zonegroup, szPBFormatted, szPBDiffFormatted);
            }

            if (pb_diff > 0) {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
            }
            else if (pb_diff < 0) {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
            }
            else {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
            }

            ShowSyncHudText(client, Finish_Handle, szPBFormatted);
        }
        else {
            FormatTimeFloat(client, runtime, szPBFormatted, sizeof szPBFormatted, true);
            
            if( zonegroup == 0) {
                FormatTimeFloat(client, wr_diff, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szPBFormatted, sizeof szPBFormatted, "Map Finished in %s | WR +%s", szPBFormatted, szWRDiffFormatted);
            }
            else {
                FormatTimeFloat(client, wr_diff, szWRDiffFormatted, sizeof szWRDiffFormatted, true);
                Format(szPBFormatted, sizeof szPBFormatted, "Bonus %d Finished in %s | WR +%s", zonegroup, szPBFormatted, szWRDiffFormatted);
            }
            
            if (wr_diff > 0) {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
            }
            else if (wr_diff < 0) {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
            }
            else {
                SetHudTextParams(g_fFinish_POSX[client] == 0.5 ? -1.0 : g_fFinish_POSX[client], g_fFinish_POSY[client] == 0.5 ? -1.0 : g_fFinish_POSY[client], g_iFinish_HoldTime[client] * 1.0, g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
            }

            ShowSyncHudText(client, Finish_Handle, szPBFormatted);
        }
	}
}

/////
//SQL
/////
public void db_LoadFinish(int client)
{
    char szQuery[1024];
    Format(szQuery, sizeof szQuery, "SELECT * FROM mh_FINISH WHERE steamid = '%s';", g_szSteamID[client]);
    PrintToServer("\n\n\n%s\n\n\n", szQuery);
    SQL_TQuery(g_hDb, SQL_LoadFinishCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadFinishCallback(Handle owner, Handle hndl, const char[] error, any client)
{
    if (hndl == null) 
    {
        LogError("[Minimal HUD] SQL Error (SQL_LoadFinishCallback): %s", error);
        return;
    }

    if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
        g_bFinish[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

        //POSITION
        char FinishPos[32];
        char FinishPos_SPLIT[2][12];
        SQL_FetchString(hndl, 2, FinishPos, sizeof FinishPos);
        ExplodeString(FinishPos, "|", FinishPos_SPLIT, sizeof FinishPos_SPLIT, sizeof FinishPos_SPLIT[]);
        g_fFinish_POSX[client] = StringToFloat(FinishPos_SPLIT[0]);
        g_fFinish_POSY[client] = StringToFloat(FinishPos_SPLIT[1]);

        char FinishColor_SPLIT[3][12];
        //GAIN COLOR
        char FinishColor_Gain[32];
        SQL_FetchString(hndl, 3, FinishColor_Gain, sizeof FinishColor_Gain);
        ExplodeString(FinishColor_Gain, "|", FinishColor_SPLIT, sizeof FinishColor_SPLIT, sizeof FinishColor_SPLIT[]);
        g_iFinish_Color[client][0][0] = StringToInt(FinishColor_SPLIT[0]);
        g_iFinish_Color[client][0][1] = StringToInt(FinishColor_SPLIT[1]);
        g_iFinish_Color[client][0][2] = StringToInt(FinishColor_SPLIT[2]);

        //LOSS COLOR
        char FinishColor_Loss[32];
        SQL_FetchString(hndl, 4, FinishColor_Loss, sizeof FinishColor_Loss);
        ExplodeString(FinishColor_Loss, "|", FinishColor_SPLIT, sizeof FinishColor_SPLIT, sizeof FinishColor_SPLIT[]);
        g_iFinish_Color[client][1][0] = StringToInt(FinishColor_SPLIT[0]);
        g_iFinish_Color[client][1][1] = StringToInt(FinishColor_SPLIT[1]);
        g_iFinish_Color[client][1][2] = StringToInt(FinishColor_SPLIT[2]);

        //MAINTAIN COLOR
        char FinishColor_Maintain[32];
        SQL_FetchString(hndl, 5, FinishColor_Maintain, sizeof FinishColor_Maintain);
        ExplodeString(FinishColor_Maintain, "|", FinishColor_SPLIT, sizeof FinishColor_SPLIT, sizeof FinishColor_SPLIT[]);
        g_iFinish_Color[client][2][0] = StringToInt(FinishColor_SPLIT[0]);
        g_iFinish_Color[client][2][1] = StringToInt(FinishColor_SPLIT[1]);
        g_iFinish_Color[client][2][2] = StringToInt(FinishColor_SPLIT[2]);

        g_iFinish_HoldTime[client] = SQL_FetchInt(hndl, 6);
        
        g_iFinish_CompareMode[client] = SQL_FetchInt(hndl, 7);

        char szClientName[MAX_NAME_LENGTH];
        GetClientName(client, szClientName, sizeof szClientName);
        PrintToServer("\n\n\n%s\n\n\n", "Finished Loading Settings for %s", szClientName);
    }
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO mh_FINISH (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		Finish_SetDefaults(client);
	}

}

public void db_updateFinish(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[4];
	char szPosY[4];
	char szFaster[32];
	char szSlower[32];
	char szSame[32];
	char szFaster_R[3];
	char szFaster_G[3];
	char szFaster_B[3];
	char szSlower_R[3];
	char szSlower_G[3];
	char szSlower_B[3];
	char szSame_R[3];
	char szSame_G[3];
	char szSame_B[3];

	FloatToString(g_fFinish_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fFinish_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iFinish_Color[client][0][0], szFaster_R, sizeof szFaster_R);
	IntToString(g_iFinish_Color[client][0][1], szFaster_G, sizeof szFaster_G);
	IntToString(g_iFinish_Color[client][0][2], szFaster_B, sizeof szFaster_B);
	Format(szFaster, sizeof szFaster, "%d|%d|%d", szFaster_R, szFaster_G, szFaster_B);

	IntToString(g_iFinish_Color[client][1][0], szSlower_R, sizeof szSlower_R);
	IntToString(g_iFinish_Color[client][1][1], szSlower_G, sizeof szSlower_G);
	IntToString(g_iFinish_Color[client][1][2], szSlower_B, sizeof szSlower_B);
	Format(szSlower, sizeof szSlower, "%d|%d|%d", szSlower_R, szSlower_G, szSlower_B);

	IntToString(g_iFinish_Color[client][2][0], szSame_R, sizeof szSame_R);
	IntToString(g_iFinish_Color[client][2][1], szSame_G, sizeof szSame_G);
	IntToString(g_iFinish_Color[client][2][2], szSame_B, sizeof szSame_B);
	Format(szSame, sizeof szSame, "%d|%d|%d", szSame_R, szSame_G, szSame_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_FINISH SET enabled = '%i', pos = '%s', fastercolor = '%s', slowercolor = '%s', samecolor = '%s', holdtime = '%i', comparemode = '%i' WHERE steamid = '%s';", g_bFinish ? '1' : '0', szPosition, szFaster, szSlower, szSame, g_iFinish_HoldTime[client], g_iFinish_CompareMode[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}
