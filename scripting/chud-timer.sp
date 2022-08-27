public Init_TIMER(){
	Timer_Handle = CreateHudSynchronizer();
}

public Timer_SetDefaults(int client)
{
	PrintToServer("Loading Timer Defaults!");

	g_bTimer[client] = false;
	g_fTimer_POSX[client] = 0.5;
	g_fTimer_POSY[client] = 0.5;

	for (int i = 0; i < 2; i++)
		for (int j = 0; j < 3; j++)
			g_iTimer_Color[client][i][j] = 255;
	
	g_iTimer_UpdateRate[client] = 0;
}

public void CHUD_TIMER(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_TIMER_Handler);
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
		AddMenuItem(menu, "", "Refresh  | SLOW\n \n");
	else if (g_iTimer_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "Refresh  | MEDIUM\n \n");
	else
		AddMenuItem(menu, "", "Refresh  | FAST\n \n");

	// EXPORT
	AddMenuItem(menu, "", "Export Settings");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_TIMER_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: Timer_Toggle(param1, true);
			case 1: Timer_Position(param1);
			case 2: Timer_Color(param1);
			case 3: Timer_UpdateRate(param1, true);
			case 4: Export(param1, 4, false, true);
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
public void Timer_Toggle(int client, bool from_menu)
{
    if (g_bTimer[client]) {
		g_bTimer[client] = false;
		//TimerrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bTimer[client] = true;
		//TimerrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (from_menu) {
        CHUD_TIMER(client);
    }
}

/////
//POSITION
/////
public void Timer_Position(int client)
{
	Menu menu = CreateMenu(CHUD_TIMER_Position_Handler);
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

public int CHUD_TIMER_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
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
		CHUD_TIMER(param1);
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
	Menu menu = CreateMenu(CHUD_TIMER_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Timer | Color\n \n");

	Format(szItem, sizeof szItem, "Normal | %d %d %d", g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Slower | %d %d %d", g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_TIMER_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		Timer_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		CHUD_TIMER(param1);
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
	CPrintToChat(client, "%t", "Color_Input");
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
		CHUD_TIMER(client);
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
            char country[64];
            surftimer_GetPlayerData(target, PersonalBest, MapRank, country);

            float CurrentTime;
            CurrentTime = surftimer_GetCurrentTime(target);

            if ( CurrentTime > PersonalBest)
                SetHudTextParams(g_fTimer_POSX[client] == 0.5 ? -1.0 : g_fTimer_POSX[client], g_fTimer_POSY[client] == 0.5 ? -1.0 : g_fTimer_POSY[client], GetUpdateRate(g_iTimer_UpdateRate[client]) / g_fTickrate + 0.1, g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2], 255, 0, 0.0, 0.0, 0.0);
            else
                SetHudTextParams(g_fTimer_POSX[client] == 0.5 ? -1.0 : g_fTimer_POSX[client], g_fTimer_POSY[client] == 0.5 ? -1.0 : g_fTimer_POSY[client], GetUpdateRate(g_iTimer_UpdateRate[client]) / g_fTickrate + 0.1, g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2], 255, 0, 0.0, 0.0, 0.0);

            char szFormattedCurrentTime[32];
            if(CurrentTime >= 0.0)
                Format_Time(client, CurrentTime, szFormattedCurrentTime, sizeof szFormattedCurrentTime, true);
            else
                Format_Time(client, 0.0, szFormattedCurrentTime, sizeof szFormattedCurrentTime, true);

            ShowSyncHudText(client, Timer_Handle, szFormattedCurrentTime);
		}
	}
}

/////
//COOKIES
/////
public void Timer_ConvertStringToData(int client, char szData[512])
{           
	char szModules[5][16];
	ExplodeString(szData, "|", szModules, sizeof szModules, sizeof szModules[]);
	for(int i = 0; i < 5; i++)
		ReplaceString(szModules[i], sizeof szModules[],  "|", "", false);

	g_bTimer[client] = StringToInt(szModules[0]) == 1 ? true : false;

	char szPosition[2][8];
	ExplodeString(szModules[1], ":", szPosition, sizeof szPosition, sizeof szPosition[]);
	g_fTimer_POSX[client] = StringToFloat(szPosition[0]);
	g_fTimer_POSY[client] = StringToFloat(szPosition[1]);

	char szFaster[3][8];
	ExplodeString(szModules[2], ":", szFaster, sizeof szFaster, sizeof szFaster[]);
	g_iTimer_Color[client][0][0] = StringToInt(szFaster[0]);
	g_iTimer_Color[client][0][1] = StringToInt(szFaster[1]);
	g_iTimer_Color[client][0][2] = StringToInt(szFaster[2]);

	char szSlower[3][8];
	ExplodeString(szModules[3], ":", szSlower, sizeof szSlower, sizeof szSlower[]);
	g_iTimer_Color[client][1][0] = StringToInt(szSlower[0]);
	g_iTimer_Color[client][1][1] = StringToInt(szSlower[1]);
	g_iTimer_Color[client][1][2] = StringToInt(szSlower[2]);

	g_iTimer_UpdateRate[client] = StringToInt(szModules[4]);
}

char[] Timer_ConvertDataToString(int client)
{           
	char szData[512];

	//ENABLED
	Format(szData, sizeof szData, "%d|", g_bTimer[client]);

	//POSITION
	Format(szData, sizeof szData, "%s%.1f:%.1f|", szData, g_fTimer_POSX[client], g_fTimer_POSY[client]);

	//COLORS
	//TYPE 1
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2]);
	//TYPE 2
	Format(szData, sizeof szData, "%s%d:%d:%d|", szData, g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2]);

	//UPDATE RATE
	Format(szData, sizeof szData, "%s%d", szData, g_iTimer_UpdateRate[client]);

	return szData;
}