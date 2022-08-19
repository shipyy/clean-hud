public Init_TIMER(){
	Timer_Handle = CreateHudSynchronizer();
}

public Timer_SetDefaults(int client){
	g_bTimer[client] = 0;
	g_fTimer_POSX[client] = 0.5;
	g_fTimer_POSY[client] = 0.5;

	for (int i = 0; i < 2; i++)
		for (int j = 0; j < 3; j++)
			g_iTimer_Color[client][i][j] = 0;
	
	g_iTimer_UpdateRate[client] = 0;
}

public void MHUD_TIMER(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(MHUD_TIMER_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Timer Options Menu\n \n");

	// Toggle
	if (g_bTimer[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	// Position
	Format(szItem, sizeof szItem, "Position | %.1f %.1f", g_fTimer_POSX[client], g_fTimer_POSY[client]);
	AddMenuItem(menu, "", szItem);

	// Color
	AddMenuItem(menu, "", "Color      |");

	// Refresh
	if (g_iTimer_UpdateRate[client] == 0)
		AddMenuItem(menu, "", "Refresh  | SLOW");
	else if (g_iTimer_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "Refresh  | MEDIUM");
	else
		AddMenuItem(menu, "", "Refresh  | FAST ");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_TIMER_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Timer_Toggle(param1, true);
			case 1: Timer_Position(param1);
			case 2: Timer_Color(param1);
			case 3: Timer_UpdateRate(param1, true);
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
public void Timer_Toggle(int client, bool from_menu)
{
    if (g_bTimer[client]) {
		g_bTimer[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bTimer[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        MHUD_TIMER(client);
    }
}

/////
//POSITION
/////
public void Timer_Position(int client)
{
	Menu menu = CreateMenu(MHUD_TIMER_Position_Handler);
	SetMenuTitle(menu, "Timer | Position\n \n");

	// Timer POSITIONS
	char Display_String[256];

	Format(Display_String, 256, "Position X : %.2f", g_fTimer_POSX[client]);
	AddMenuItem(menu, "", Display_String);

	Format(Display_String, 256, "Position Y : %.2f", g_fTimer_POSY[client]);
	AddMenuItem(menu, "", Display_String);


	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_TIMER_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: Timer_PosX(param1);
			case 1: Timer_PosY(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		MHUD_TIMER(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void Timer_PosX(int client)
{
	if (g_fTimer_POSX[client] < 1.0){
		g_fTimer_POSX[client] += 0.1;
	}
	else
		g_fTimer_POSX[client] = 0.0;

	Timer_Position(client);
}

void Timer_PosY(int client)
{
	
	if (g_fTimer_POSY[client] < 1.0)
		g_fTimer_POSY[client] += 0.1;
	else
		g_fTimer_POSY[client] = 0.0;

	Timer_Position(client);
}

/////
//COLOR
/////
public void Timer_Color(int client)
{
	Menu menu = CreateMenu(MHUD_TIMER_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Timer | Color\n \n");

	Format(szItem, sizeof szItem, "Normal | %d %d %d", g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Slower | %d %d %d", g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_TIMER_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		Timer_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		MHUD_TIMER(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Timer_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(Timer_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Timer | Normal Color\n \n");
		case 1: SetMenuTitle(menu, "Timer | Slower Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iTimer_Color[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iTimer_Color[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iTimer_Color[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int Timer_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){

		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		Timer_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		Timer_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void Timer_Color_Change(int client, int color_type, int color_index)
{
	g_iArrayToChange[client] = 3;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//UPDATE RATE
/////
void Timer_UpdateRate(int client, bool from_menu)
{
	if (g_iTimer_UpdateRate[client] != 2)
		g_iTimer_UpdateRate[client]++;
	else
		g_iTimer_UpdateRate[client] = 0;

	if (from_menu) {
		MHUD_TIMER(client);
	}
}

/////
//DISPLAY
/////

public void Timer_Display(int client)
{
    if (g_bTimer[client] && !IsFakeClient(client)) {
		if(g_iClientTick[client][3] - g_iCurrentTick[client][3] >= GetUpdateRate(g_iTimer_UpdateRate[client])) {
            g_iCurrentTick[client][3] += GetUpdateRate(g_iTimer_UpdateRate[client]);
            
            int target;
            
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
                
            float PersonalBest;
            int MapRank;
            char country[64], countryCode[3], continentCode[3];
            surftimer_GetPlayerData(client, PersonalBest, MapRank, country,countryCode, continentCode);

            float CurrentTime;
            CurrentTime = surftimer_GetCurrentTime(target);

            if ( CurrentTime > PersonalBest)
                SetHudTextParams(g_fTimer_POSX[client] == 0.5 ? -1.0 : g_fTimer_POSX[client], g_fTimer_POSY[client] == 0.5 ? -1.0 : g_fTimer_POSY[client], GetUpdateRate(g_iTimer_UpdateRate[client]) / g_fTickrate + 0.1, g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
            else
                SetHudTextParams(g_fTimer_POSX[client] == 0.5 ? -1.0 : g_fTimer_POSX[client], g_fTimer_POSY[client] == 0.5 ? -1.0 : g_fTimer_POSY[client], GetUpdateRate(g_iTimer_UpdateRate[client]) / g_fTickrate + 0.1, g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);

            char szFormattedCurrentTime[32];
            if(CurrentTime >= 0.0)
                FormatTimeFloat(client, CurrentTime, szFormattedCurrentTime, sizeof szFormattedCurrentTime, true);
            else
                FormatTimeFloat(client, 0.0, szFormattedCurrentTime, sizeof szFormattedCurrentTime, true);

            ShowSyncHudText(client, Timer_Handle, szFormattedCurrentTime);
		}
	}
}

/////
//SQL
/////
public void db_LoadTimer(int client)
{	
	
	char szQuery[1024];
	Format(szQuery, sizeof szQuery, "SELECT * FROM mh_Timer WHERE steamid = '%s';", g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadTimerCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadTimerCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_LoadTimerCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		//Timer_SetDefaults(client);

		g_bTimer[client] = (SQL_FetchInt(hndl, 1) == 1 ? true : false);

		//POSITION
		char TimerPos[32];
		char TimerPos_SPLIT[2][12];
		SQL_FetchString(hndl, 2, TimerPos, sizeof TimerPos);
		ExplodeString(TimerPos, "|", TimerPos_SPLIT, sizeof TimerPos_SPLIT, sizeof TimerPos_SPLIT[]);
		g_fTimer_POSX[client] = StringToFloat(TimerPos_SPLIT[0]);
		g_fTimer_POSY[client] = StringToFloat(TimerPos_SPLIT[1]);

		char TimerColor_SPLIT[3][12];
		//NORMAL COLOR
		char TimerColor_Normal[32];
		SQL_FetchString(hndl, 3, TimerColor_Normal, sizeof TimerColor_Normal);
		ExplodeString(TimerColor_Normal, "|", TimerColor_SPLIT, sizeof TimerColor_SPLIT, sizeof TimerColor_SPLIT[]);
		g_iTimer_Color[client][0][0] = StringToInt(TimerColor_SPLIT[0]);
		g_iTimer_Color[client][0][1] = StringToInt(TimerColor_SPLIT[1]);
		g_iTimer_Color[client][0][2] = StringToInt(TimerColor_SPLIT[2]);

		//SLOWER COLOR
		char TimerColor_Slower[32];
		SQL_FetchString(hndl, 5, TimerColor_Slower, sizeof TimerColor_Slower);
		ExplodeString(TimerColor_Slower, "|", TimerColor_SPLIT, sizeof TimerColor_SPLIT, sizeof TimerColor_SPLIT[]);
		g_iTimer_Color[client][1][0] = StringToInt(TimerColor_SPLIT[0]);
		g_iTimer_Color[client][1][1] = StringToInt(TimerColor_SPLIT[1]);
		g_iTimer_Color[client][1][2] = StringToInt(TimerColor_SPLIT[2]);

		g_iTimer_UpdateRate[client] = SQL_FetchInt(hndl, 5);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO mh_Timer (steamid) VALUES('%s')", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);

		Timer_SetDefaults(client);
	}

}

public void db_updateTimer(int client)
{
	char szQuery[1024];

	char szPosition[32];
	char szPosX[4];
	char szPosY[4];
	char szNormal[32];
	char szSlower[32];
	char szNormal_R[3];
	char szNormal_G[3];
	char szNormal_B[3];
	char szSlower_R[3];
	char szSlower_G[3];
	char szSlower_B[3];

	FloatToString(g_fTimer_POSX[client], szPosX, sizeof szPosX);
	FloatToString(g_fTimer_POSY[client], szPosY, sizeof szPosY);
	Format(szPosition, sizeof szPosition, "%.1f|%.1f", szPosX, szPosY);

	IntToString(g_iTimer_Color[client][0][0], szNormal_R, sizeof szNormal_R);
	IntToString(g_iTimer_Color[client][0][1], szNormal_G, sizeof szNormal_G);
	IntToString(g_iTimer_Color[client][0][2], szNormal_B, sizeof szNormal_B);
	Format(szNormal, sizeof szNormal, "%d|%d|%d", szNormal_R, szNormal_G, szNormal_B);

	IntToString(g_iTimer_Color[client][1][0], szSlower_R, sizeof szSlower_R);
	IntToString(g_iTimer_Color[client][1][1], szSlower_G, sizeof szSlower_G);
	IntToString(g_iTimer_Color[client][1][2], szSlower_B, sizeof szSlower_B);
	Format(szSlower, sizeof szSlower, "%d|%d|%d", szSlower_R, szSlower_G, szSlower_B);

	Format(szQuery, sizeof szQuery, "UPDATE mh_Timer SET enabled = '%i', pos = '%s', normalcolor = '%s', slowercolor = '%s', updaterate = '%i' WHERE steamid = '%s';", g_bTimer ? '1' : '0', szPosition, szNormal, szSlower, g_iTimer_UpdateRate[client], g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}
