public Init_CP(){
	CP_Handle = CreateHudSynchronizer();
}

public CP_SetDefaults(int client){
	g_bCP[client] = false;
	g_fCP_POSX[client] = 0.5;
	g_fCP_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iCP_Color[client][i][j] = 255;

	g_iCP_HoldTime[client] = 3;
	g_iCP_CompareMode[client] = 1;
}

public void MHUD_CP(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_CP_Handler);
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
	Format(szItem, sizeof szItem, "Compare | %s", g_iCP_CompareMode[client] == 0 ? "PB" : "WR");
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_CP_Handler(Menu menu, MenuAction action, int param1, int param2)
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
        MHUD_CP(client);
    }
}

/////
//POSITION
/////
public void CP_Position(int client)
{

	Menu menu = CreateMenu(MHUD_CP_Position_Handler);
	SetMenuTitle(menu, "Checkpoints | Position\n \n");

	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fCP_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fCP_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_CP_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		MHUD_CP(param1);
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
	Menu menu = CreateMenu(MHUD_CP_Color_Handler);
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

public int MHUD_CP_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		CP_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		MHUD_CP(param1);
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

	MHUD_CP(client);
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

	MHUD_CP(client);
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
			FormatTimeFloat(client, runtime - pb_runtime, szPBFormatted, sizeof szPBFormatted, true);

			if (pb_runtime - runtime > 0) {
				Format(szPBFormatted, sizeof szPBFormatted, "-%s", szPBFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (pb_runtime - runtime < 0) {
				Format(szPBFormatted, sizeof szPBFormatted, "+%s", szPBFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else {
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2], 255, 0, 0.0, 0.0, 0.0);
			}

			ShowSyncHudText(client, CP_Handle, szPBFormatted);
		}
		else {
			FormatTimeFloat(client, runtime - pb_runtime, szWRFormatted, sizeof szWRFormatted, true);

			if (wr_runtime - runtime > 0) {
				Format(szWRFormatted, sizeof szWRFormatted, "-%s", szWRFormatted);
				SetHudTextParams(g_fCP_POSX[client] == 0.5 ? -1.0 : g_fCP_POSX[client], g_fCP_POSY[client] == 0.5 ? -1.0 : g_fCP_POSY[client], g_iCP_HoldTime[client] * 1.0, g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);
			}
			else if (wr_runtime - runtime < 0) {
				Format(szWRFormatted, sizeof szWRFormatted, "+%s", szWRFormatted);
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
//SQL
/////
public void db_LoadCP(int client)
{	
	
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_CP WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadCPCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadCPCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadCPCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		//CP_SetDefaults(client);

		g_bCP[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char CPPos[32];
		char CPPos_SPLIT[2][12];
		SQL_FetchString(hndl, 2, CPPos, sizeof CPPos);
		ExplodeString(CPPos, "|", CPPos_SPLIT, sizeof CPPos_SPLIT, sizeof CPPos_SPLIT[]);
		g_fCP_POSX[client] = StringToFloat(CPPos_SPLIT[0]);
		g_fCP_POSY[client] = StringToFloat(CPPos_SPLIT[1]);

		char CPColor_SPLIT[3][12];
		//GAIN COLOR
		char CPColor_Gain[32];
		SQL_FetchString(hndl, 3, CPColor_Gain, sizeof CPColor_Gain);
		ExplodeString(CPColor_Gain, "|", CPColor_SPLIT, sizeof CPColor_SPLIT, sizeof CPColor_SPLIT[]);
		g_iCP_Color[client][0][0] = StringToInt(CPColor_SPLIT[0]);
		g_iCP_Color[client][0][1] = StringToInt(CPColor_SPLIT[1]);
		g_iCP_Color[client][0][2] = StringToInt(CPColor_SPLIT[2]);

		//LOSS COLOR
		char CPColor_Loss[32];
		SQL_FetchString(hndl, 4, CPColor_Loss, sizeof CPColor_Loss);
		ExplodeString(CPColor_Loss, "|", CPColor_SPLIT, sizeof CPColor_SPLIT, sizeof CPColor_SPLIT[]);
		g_iCP_Color[client][1][0] = StringToInt(CPColor_SPLIT[0]);
		g_iCP_Color[client][1][1] = StringToInt(CPColor_SPLIT[1]);
		g_iCP_Color[client][1][2] = StringToInt(CPColor_SPLIT[2]);
		
		//MAINTAIN COLOR
		char CPColor_Maintain[32];
		SQL_FetchString(hndl, 5, CPColor_Maintain, sizeof CPColor_Maintain);
		ExplodeString(CPColor_Maintain, "|", CPColor_SPLIT, sizeof CPColor_SPLIT, sizeof CPColor_SPLIT[]);
		g_iCP_Color[client][2][0] = StringToInt(CPColor_SPLIT[0]);
		g_iCP_Color[client][2][1] = StringToInt(CPColor_SPLIT[1]);
		g_iCP_Color[client][2][2] = StringToInt(CPColor_SPLIT[2]);

		g_iCP_HoldTime[client] = SQL_FetchInt(hndl, 6);

		g_iCP_CompareMode[client] = SQL_FetchInt(hndl, 7);

	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO mh_CP (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		CP_SetDefaults(client);
	}

}

public void db_updateCP(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[4];
	char szPosY[4];
	char szGain[32];
	char szLoss[32];
	char szMaintain[32];
	char szGain_R[3];
	char szGain_G[3];
	char szGain_B[3];
	char szLoss_R[3];
	char szLoss_G[3];
	char szLoss_B[3];
	char szMaintain_R[3];
	char szMaintain_G[3];
	char szMaintain_B[3];

	FloatToString(g_fCP_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fCP_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iCP_Color[client][0][0], szGain_R, sizeof szGain_R);
	IntToString(g_iCP_Color[client][0][1], szGain_G, sizeof szGain_G);
	IntToString(g_iCP_Color[client][0][2], szGain_B, sizeof szGain_B);
	Format(szGain, sizeof szGain, "%d|%d|%d", szGain_R, szGain_G, szGain_B);

	IntToString(g_iCP_Color[client][1][0], szLoss_R, sizeof szLoss_R);
	IntToString(g_iCP_Color[client][1][1], szLoss_G, sizeof szLoss_G);
	IntToString(g_iCP_Color[client][1][2], szLoss_B, sizeof szLoss_B);
	Format(szLoss, sizeof szLoss, "%d|%d|%d", szLoss_R, szLoss_G, szLoss_B);

	IntToString(g_iCP_Color[client][2][0], szMaintain_R, sizeof szMaintain_R);
	IntToString(g_iCP_Color[client][2][1], szMaintain_G, sizeof szMaintain_G);
	IntToString(g_iCP_Color[client][2][2], szMaintain_B, sizeof szMaintain_B);
	Format(szMaintain, sizeof szMaintain, "%d|%d|%d", szMaintain_R, szMaintain_G, szMaintain_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_CP SET enabled = '%i', pos = '%s', gaincolor = '%s', losscolor = '%s', maintaincolor = '%s', holdtime = '%i', comparemode = '%i' WHERE steamid = '%s';", g_bCP ? '1' : '0', szPosition, szGain, szLoss, szMaintain, g_iCP_HoldTime[client], g_iCP_CompareMode[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}
