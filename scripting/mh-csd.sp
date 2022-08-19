public Init_CSD(){
	CSD_Handle = CreateHudSynchronizer();
}

public CSD_SetDefaults(int client){
	g_bCSD[client] = 0;
	g_iCSD_SpeedAxis[client] = 0;
	g_fCSD_POSX[client] = 0.5;
	g_fCSD_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iCSD_SpeedColor[client][i][j] = 0;
	
	g_iCSD_UpdateRate[client] = 0;
}

public void MHUD_CSD(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_CSD_Handler);
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
	Format(szItem, sizeof szItem, "Color      | %d %d %d", g_iCSD_SpeedColor[client][g_iCSD_SpeedAxis[client]][0], g_iCSD_SpeedColor[client][g_iCSD_SpeedAxis[client]][1], g_iCSD_SpeedColor[client][g_iCSD_SpeedAxis[client]][2]);
	AddMenuItem(menu, "", szItem);

	// Refresh
	if (g_iCSD_UpdateRate[client] == 0)
		AddMenuItem(menu, "", "Refresh  | SLOW");
	else if (g_iCSD_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "Refresh  | MEDIUM");
	else
		AddMenuItem(menu, "", "Refresh  | FAST ");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_CSD_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CSD_Toggle(param1, true);
			case 1: CSD_Axis(param1, true);
			case 2: CSD_Position(param1);
			case 3: CSD_Color(param1);
			case 4: CSD_UpdateRate(param1, true);
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
public void CSD_Toggle(int client, bool from_menu)
{
    if (g_bCSD[client]) {
		g_bCSD[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bCSD[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_CSD(client);
    }
}

/////
//AXIS
/////
void CSD_Axis(int client, bool from_menu)
{
	if (g_iCSD_SpeedAxis[client] != 2)
		g_iCSD_SpeedAxis[client]++;
	else
		g_iCSD_SpeedAxis[client] = 0;

	if (from_menu) {
		MHUD_CSD(client);
	}
}

/////
//POSITION
/////
public void CSD_Position(int client)
{

	Menu menu = CreateMenu(MHUD_CSD_Position_Handler);
	SetMenuTitle(menu, "Center Speed | Position\n \n");

	// CENTER SPEED POSITIONS
	char Display_String[256];
	// POS X
	Format(Display_String, 256, "Position X : %.2f", g_fCSD_POSX[client]);
	AddMenuItem(menu, "", Display_String);
	// POX Y
	Format(Display_String, 256, "Position Y : %.2f", g_fCSD_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_CSD_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		MHUD_CSD(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void CSD_PosX(int client)
{
	if (g_fCSD_POSX[client] < 1.0){
		g_fCSD_POSX[client] += 0.1;
	}
	else
		g_fCSD_POSX[client] = 0.0;

	CSD_Position(client);
}

void CSD_PosY(int client)
{
	
	if (g_fCSD_POSY[client] < 1.0)
		g_fCSD_POSY[client] += 0.1;
	else
		g_fCSD_POSY[client] = 0.0;

	CSD_Position(client);
}

/////
//COLOR
/////
public void CSD_Color(int client)
{
	Menu menu = CreateMenu(MHUD_CSD_Color_Handler);
	SetMenuTitle(menu, "Center Speed | Color\n \n");

	// CENTER SPEED POSITIONS
	AddMenuItem(menu, "", "Gain Color");
	AddMenuItem(menu, "", "Loss Color");
	AddMenuItem(menu, "", "Maintain Color");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_CSD_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		CSD_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		MHUD_CSD(param1);
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

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iCSD_SpeedColor[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iCSD_SpeedColor[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iCSD_SpeedColor[client][type][2]);
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
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//UPDATE RATE
/////
void CSD_UpdateRate(int client, bool from_menu)
{
	if (g_iCSD_UpdateRate[client] != 2)
		g_iCSD_UpdateRate[client]++;
	else
		g_iCSD_UpdateRate[client] = 0;

	if (from_menu) {
		MHUD_CSD(client);
	}
}

/////
//MISC
////
int[] GetSpeedColourCSD(int client, float speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) ) {
		displayColor[0] = g_iCSD_SpeedColor[client][0][0];
		displayColor[1] = g_iCSD_SpeedColor[client][0][1];
		displayColor[2] = g_iCSD_SpeedColor[client][0][2];
	}
	//losing speed
	else if (g_fLastSpeed[client] > speed ) {
		displayColor[0] = g_iCSD_SpeedColor[client][1][0];
		displayColor[1] = g_iCSD_SpeedColor[client][1][1];
		displayColor[2] = g_iCSD_SpeedColor[client][1][2];
	}
	//not moving (speed == 0)
	else {
		displayColor[0] = g_iCSD_SpeedColor[client][2][0];
		displayColor[1] = g_iCSD_SpeedColor[client][2][1];
		displayColor[2] = g_iCSD_SpeedColor[client][2][2];
	}

	g_fLastSpeed[client] = speed;

	return displayColor;
}

public void CSD_Display(int client)
{
	if (g_bCSD[client] && !IsFakeClient(client)) {
		if(g_iClientTick[client][0] - g_iCurrentTick[client][0] >= GetUpdateRate(g_iCSD_UpdateRate[client]))
		{
			g_iCurrentTick[client][0] += GetUpdateRate(g_iCSD_UpdateRate[client]);

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

			SetHudTextParams(g_fCSD_POSX[client] == 0.5 ? -1.0 : g_fCSD_POSX[client], g_fCSD_POSY[client] == 0.5 ? -1.0 : g_fCSD_POSY[client], GetUpdateRate(g_iCSD_UpdateRate[client]) / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
			ShowSyncHudText(client, CSD_Handle, szSpeed);
		}
	}
}

/////
//SQL
/////
public void db_LoadCSD(int client)
{	
	
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_CSD WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadCSDCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadCSDCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadCSDCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		//CSD_SetDefaults(client);

		g_bCSD[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);
		g_iCSD_SpeedAxis[client] = SQL_FetchInt(hndl, 2);

		//POSITION
		char CSDPos[32];
		char CSDPos_SPLIT[2][12];
		SQL_FetchString(hndl, 3, CSDPos, sizeof CSDPos);
		ExplodeString(CSDPos, "|", CSDPos_SPLIT, sizeof CSDPos_SPLIT, sizeof CSDPos_SPLIT[]);
		g_fCSD_POSX[client] = StringToFloat(CSDPos_SPLIT[0]);
		g_fCSD_POSY[client] = StringToFloat(CSDPos_SPLIT[1]);

		char CSDColor_SPLIT[3][12];
		//GAIN COLOR
		char CSDColor_Gain[32];
		SQL_FetchString(hndl, 4, CSDColor_Gain, sizeof CSDColor_Gain);
		ExplodeString(CSDColor_Gain, "|", CSDColor_SPLIT, sizeof CSDColor_SPLIT, sizeof CSDColor_SPLIT[]);
		g_iCSD_SpeedColor[client][0][0] = StringToInt(CSDColor_SPLIT[0]);
		g_iCSD_SpeedColor[client][0][1] = StringToInt(CSDColor_SPLIT[1]);
		g_iCSD_SpeedColor[client][0][2] = StringToInt(CSDColor_SPLIT[2]);

		//LOSS COLOR
		char CSDColor_Loss[32];
		SQL_FetchString(hndl, 5, CSDColor_Loss, sizeof CSDColor_Loss);
		ExplodeString(CSDColor_Loss, "|", CSDColor_SPLIT, sizeof CSDColor_SPLIT, sizeof CSDColor_SPLIT[]);
		g_iCSD_SpeedColor[client][1][0] = StringToInt(CSDColor_SPLIT[0]);
		g_iCSD_SpeedColor[client][1][1] = StringToInt(CSDColor_SPLIT[1]);
		g_iCSD_SpeedColor[client][1][2] = StringToInt(CSDColor_SPLIT[2]);
		
		//MAINTAIN COLOR
		char CSDColor_Maintain[32];
		SQL_FetchString(hndl, 6, CSDColor_Maintain, sizeof CSDColor_Maintain);
		ExplodeString(CSDColor_Maintain, "|", CSDColor_SPLIT, sizeof CSDColor_SPLIT, sizeof CSDColor_SPLIT[]);
		g_iCSD_SpeedColor[client][2][0] = StringToInt(CSDColor_SPLIT[0]);
		g_iCSD_SpeedColor[client][2][1] = StringToInt(CSDColor_SPLIT[1]);
		g_iCSD_SpeedColor[client][2][2] = StringToInt(CSDColor_SPLIT[2]);

		g_iCSD_UpdateRate[client] = SQL_FetchInt(hndl, 7);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO mh_CSD (steamid) VALUES('%s')", g_szSteamID[client]);
		PrintToServer(szQuery);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		CSD_SetDefaults(client);
	}

}

public void db_updateCSD(int client)
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

	FloatToString(g_fCSD_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fCSD_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iCSD_SpeedColor[client][0][0], szGain_R, sizeof szGain_R);
	IntToString(g_iCSD_SpeedColor[client][0][1], szGain_G, sizeof szGain_G);
	IntToString(g_iCSD_SpeedColor[client][0][2], szGain_B, sizeof szGain_B);
	Format(szGain, sizeof szGain, "%d|%d|%d", szGain_R, szGain_G, szGain_B);

	IntToString(g_iCSD_SpeedColor[client][1][0], szLoss_R, sizeof szLoss_R);
	IntToString(g_iCSD_SpeedColor[client][1][1], szLoss_G, sizeof szLoss_G);
	IntToString(g_iCSD_SpeedColor[client][1][2], szLoss_B, sizeof szLoss_B);
	Format(szLoss, sizeof szLoss, "%d|%d|%d", szLoss_R, szLoss_G, szLoss_B);

	IntToString(g_iCSD_SpeedColor[client][2][0], szMaintain_R, sizeof szMaintain_R);
	IntToString(g_iCSD_SpeedColor[client][2][1], szMaintain_G, sizeof szMaintain_G);
	IntToString(g_iCSD_SpeedColor[client][2][2], szMaintain_B, sizeof szMaintain_B);
	Format(szMaintain, sizeof szMaintain, "%d|%d|%d", szMaintain_R, szMaintain_G, szMaintain_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_CSD SET enabled = '%i', speedaxis = '%i', pos = '%s', gaincolor = '%s', losscolor = '%s', maintaincolor = '%s', updaterate = '%i' WHERE steamid = '%s';", g_bCSD ? '1' : '0', g_iCSD_SpeedAxis[client], szPosition, szGain, szLoss, szMaintain, g_iCSD_UpdateRate[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}
