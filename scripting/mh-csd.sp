public CSD_SetDefaults(int client){
	g_bCSD[client] = 0;
	g_iCSD_SpeedAxis[client] = 0;
	g_fCSD_POSX[client] = 0.5;
	g_fCSD_POSY[client] = 0.5;

	for (int i = 0; i < 3; i++)
		for (int j = 0; j < 3; j++)
			g_iCSD_SpeedColor[client][i][j] = 0;
	
	g_iCSD_UpdateRate[client] = 0;

	g_iWaitingForResponse[client] = None;
}

public void MHUD_CSD(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_CSD_Handler);
	SetMenuTitle(menu, "Center Speed Options Menu\n \n");

	// Centre Speed Display
	if (g_bCSD[client])
		AddMenuItem(menu, "", "[ON] Centre Speed Display");
	else
		AddMenuItem(menu, "", "[OFF] Centre Speed Display");

	// Speed Mode
	if (g_iCSD_SpeedAxis[client] == 0)
		AddMenuItem(menu, "", "[XY] Speed Mode");
	else if (g_iCSD_SpeedAxis[client] == 1)
		AddMenuItem(menu, "", "[XYZ] Speed Mode");
	else
		AddMenuItem(menu, "", "[Z] Speed Mode");

	// CENTER SPEED POSITIONS
	AddMenuItem(menu, "", "Speed Position");

	// Speed Color
	AddMenuItem(menu, "", "Speed Color");

	// CSD Update Rate
	if (g_iCSD_UpdateRate[client] == 0)
		AddMenuItem(menu, "", "[SLOW] CSD Update Rate");
	else if (g_iCSD_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "[MEDIUM] CSD Update Rate");
	else
		AddMenuItem(menu, "", "[FAST] CSD Update Rate");

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
	//THE LOWER THE NUMBER THE FASTER THE UPDATING IS
	int update_rate;

	if(g_bCSD[client]){
		switch(g_iCSD_UpdateRate[client]){
			case 0: update_rate = 15;
			case 1:	update_rate = 10;
			case 2: update_rate = 5;
			default: update_rate = 15;
		}
	}

	if(g_iClientTick[client] - g_iCurrentTick[client] >= update_rate)
	{
		g_iCurrentTick[client] += update_rate;
		if (g_bCSD[client] && IsValidClient(client) && !IsFakeClient(client) && IsClientInGame(client))
		{
			char szSpeed[128];
			int displayColor[3];
			displayColor = GetSpeedColourCSD(client, GetSpeed(client));

			// player alive
			if (IsPlayerAlive(client))
			{
				Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(g_fLastSpeed[client]));
			}
			else { // player not alive (check wether spec'ing a bot or another player)
				int ObservedUser;
				ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
				g_SpecTarget[client] = ObservedUser;
				
				int ObservedUser_Style = surftimer_GetClientStyle(g_SpecTarget[client]);

				if (ObservedUser_Style == 5)
					g_fLastSpeed[g_SpecTarget[client]] /= 0.5;
				else if (ObservedUser_Style == 6)
					g_fLastSpeed[g_SpecTarget[client]] /= 1.5;
				
				Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(g_fLastSpeed[g_SpecTarget[client]]));
			}
			//ShowHudText(client, -1, szSpeed);
			//SetHudTextParams(g_fCSD_POSX[client] == 0.5 ? 1.0 : g_fCSD_POSX[client], g_fCSD_POSY[client] == 0.5 ? 1.0 : g_fCSD_POSY[client], update_rate / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
			SetHudTextParams(g_fCSD_POSX[client] == 0.5 ? -1.0 : g_fCSD_POSX[client], g_fCSD_POSY[client] == 0.5 ? -1.0 : g_fCSD_POSY[client], update_rate / g_fTickrate + 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
			ShowSyncHudText(client, HUD_Handle, szSpeed);
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
	SQL_TQuery(g_hDb, SQL_LoadPlayerSettingsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadPlayerSettingsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadPlayerSettingsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		CSD_SetDefaults(client);

		g_bCSD[client] = (SQL_FetchInt(hndl, 0) == 1 ? true : false);
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

	Format(szQuery, sizeof szQuery, "UPDATE mh_CSD SET enable = '%i' WHERE steamid = '%s';", g_bCSD ? '1' : '0' ,g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadPlayerSettingsCallback, szQuery, client, DBPrio_Low);
}
