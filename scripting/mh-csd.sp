public CSD_SetDefaults(int client){
	g_bCSD[client] = 0;
	g_iCSD_SpeedAxis[client] = 0;
	g_fCSD_POSX[client] = 0.5;
	g_fCSD_POSY[client] = 0.5;
	g_iCSD_SpeedColor[client] = 0;
	g_iCSD_R[client] = 0;
	g_iCSD_G[client] = 0;
	g_iCSD_B[client] = 0;
	g_iCSD_UpdateRate[client] = 0;
}

public Action MHUD_CSD(int client)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

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
	char Display_String[256];
	// POS X
	Format(Display_String, 256, "Position X : %f", g_fCSD_POSX[client]);
	AddMenuItem(menu, "", Display_String);
	// POX Y
	Format(Display_String, 256, "Position Y : %f", g_fCSD_POSY[client]);
	AddMenuItem(menu, "", Display_String);

	// Speed Gradient
	if (g_iCSD_SpeedColor[client] == 0)
		AddMenuItem(menu, "", "[WHITE] Speed Gradient");
	else if (g_iCSD_SpeedColor[client] == 1)
		AddMenuItem(menu, "", "[RED] Speed Gradient");
	else if (g_iCSD_SpeedColor[client] == 2)
		AddMenuItem(menu, "", "[GREEN] Speed Gradient");
	else if (g_iCSD_SpeedColor[client] == 3)
		AddMenuItem(menu, "", "[BLUE] Speed Gradient");
	else if (g_iCSD_SpeedColor[client] == 4)
		AddMenuItem(menu, "", "[YELLOW] Speed Gradient");
	else if (g_iCSD_SpeedColor[client] == 5)
		AddMenuItem(menu, "", "[MOMENTUM] Speed Gradient");
	else
		AddMenuItem(menu, "", "[Custom] Speed Gradient");

	// CENTER SPEED CUSTOM VALUES
	char Display_String_Custom[256];
	// RED
	Format(Display_String_Custom, 256, "[R] : %i", g_iCSD_R[client]);
	AddMenuItem(menu, "", Display_String_Custom);
	// GREEN
	Format(Display_String_Custom, 256, "[G] : %i", g_iCSD_G[client]);
	AddMenuItem(menu, "", Display_String_Custom);
	// BLUE
	Format(Display_String_Custom, 256, "[B] : %i", g_iCSD_B[client]);
	AddMenuItem(menu, "", Display_String_Custom);

	// CSD Update Rate
	if (g_iCSD_UpdateRate[client] == 0)
		AddMenuItem(menu, "", "[SLOW] CSD Update Rate");
	else if (g_iCSD_UpdateRate[client] == 1)
		AddMenuItem(menu, "", "[MEDIUM] CSD Update Rate");
	else
		AddMenuItem(menu, "", "[FAST] CSD Update Rate");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int MHUD_CSD_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CSD_Toggle(param1, 1);
			case 8: CSD_UpdateRate(param1, 1);
		}
	}
	else if (action == MenuAction_End) {
		delete menu;
	}

	return 0;
}

public void CSD_Toggle(int client, int args)
{
    if (g_bCSD[client]) {
		g_bCSD[client] = false;
		//CPrintToChat(client, "%t", "CenterSpeedOff", g_szChatPrefix);
	}
	else {
		g_bCSD[client] = true;
		//CPrintToChat(client, "%t", "CenterSpeedOn", g_szChatPrefix);
	}

    if (args != 0) {
        MHUD_CSD(client);
    }
}

void CSD_UpdateRate(int client, int args)
{
	if (g_iCSD_UpdateRate[client] != 2)
		g_iCSD_UpdateRate[client]++;
	else
		g_iCSD_UpdateRate[client] = 0;

	if (args != 0) {
		MHUD_CSD(client);
	}
}

int[] GetSpeedColourCSD(int client, float speed, int type)
{	
	int displayColor[3] = {255, 255, 255};
	// RED
	if (type == 1) // green
	{
		displayColor = {255,0,0};
		return displayColor;
	}
	// GREEN
	else if (type == 2)
	{
		displayColor = {0,255,0};
		return displayColor;
	}
	// BLUE
	else if (type == 3)
	{
		displayColor = {0,0,255};
		return displayColor;
	}
	// YELLOW
	else if (type == 4)
	{
		displayColor = {255,255,0};
		return displayColor;
	}
	//MOMENTUM
	else if (type == 5)
	{
		if (speed >= GetConVarFloat(FindConVar("sv_maxvelocity")))
			displayColor = {0,255,0}; //GREEN
		//gaining speed or mainting
		else if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) )
			displayColor = {0,255,0}; //GREEN
		//losing speed
		else if (g_fLastSpeed[client] > speed )
			displayColor = {255,0,0}; //RED
		//not moving (speed == 0)
		else
			displayColor = {255,255,255}; //WHITE

		g_fLastSpeed[client] = speed;
		return displayColor;
	}
	else
		return displayColor; //WHITE
}

public void CenterSpeedDisplay(int client)
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
		if (IsValidClient(client) && !IsFakeClient(client) && g_bCSD[client] && IsClientInGame(client))
		{

			float fCSD_PosX;
			float fCSD_PosY;
			switch(g_fCSD_POSX[client]){
				case 0.5: fCSD_PosX = -1.0;
				default: fCSD_PosX = g_fCSD_POSX[client];
			}
			switch(g_fCSD_POSY[client]){
				case 0.5: fCSD_PosY = -1.0;
				default: fCSD_PosY = g_fCSD_POSY[client];
			}

			char szSpeed[128];
			int displayColor[3];

			// player alive
			if (IsPlayerAlive(client))
			{	
				PrintToChatAll("NOT SPECCING");
				if(g_iCSD_SpeedColor[client] != 6)
					displayColor = GetSpeedColourCSD(client, GetSpeed(client), g_iCSD_SpeedColor[client]);
				else{
					displayColor[0] = g_iCSD_R[client];
					displayColor[1] = g_iCSD_G[client];
					displayColor[2] = g_iCSD_B[client];
				}

				SetHudTextParams(fCSD_PosX, fCSD_PosY, update_rate / g_fTickrate, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);

				Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(g_fLastSpeed[client]));
			}
			else { // player not alive (check wether spec'ing a bot or another player)
				int SpecMode;
				int ObservedUser;

				SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");

				ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

				// spec'ing
				if (SpecMode == 4 || SpecMode == 5)
				{
					g_SpecTarget[client] = ObservedUser;
					char ObservedUser_Name[MAX_NAME_LENGTH];
					GetClientName(ObservedUser, ObservedUser_Name, sizeof ObservedUser_Name);
					if (IsValidClient(ObservedUser))
					{	
						//spec'ing a bot
						if (IsFakeClient(ObservedUser))
						{
							float fSpeed[3];
							GetEntPropVector(ObservedUser, Prop_Data, "m_vecVelocity", fSpeed);

							float fSpeedHUD;
							if(g_iCSD_SpeedAxis[client] == 0) //XY
								fSpeedHUD = SquareRoot(Pow(fSpeed[0], 2.0) + Pow(fSpeed[1], 2.0));
							else if(g_iCSD_SpeedAxis[client] == 1) //XYZ
								fSpeedHUD = SquareRoot(Pow(fSpeed[0], 2.0) + Pow(fSpeed[1], 2.0) + Pow(fSpeed[2], 2.0));
							else if(g_iCSD_SpeedAxis[client] == 2) //Z
								fSpeedHUD = SquareRoot(Pow(fSpeed[2], 2.0));
							
							PrintToChatAll("bot speed %f", fSpeedHUD);

							if (strcmp(ObservedUser_Name, "map", false) == 0)
							{
								if (surftimer_GetClientStyle(client) == 5)
								{
									fSpeedHUD /= 0.5;
								}
								else if (surftimer_GetClientStyle(client) == 6)
								{
									fSpeedHUD /= 1.5;
								}
							}
							else if (strcmp(ObservedUser_Name, "bonus", false) == 0)
							{
								if (surftimer_GetClientStyle(client)  == 5)
								{
									fSpeedHUD /= 0.5;
								}
								else if (surftimer_GetClientStyle(client) == 6)
								{
									fSpeedHUD /= 1.5;
								}
							}

							if(g_iCSD_SpeedColor[client] != 6)
								displayColor = GetSpeedColourCSD(client, fSpeedHUD, g_iCSD_SpeedColor[client]);
							else{
								displayColor[0] = g_iCSD_R[client];
								displayColor[1] = g_iCSD_G[client];
								displayColor[2] = g_iCSD_B[client];
							}

							SetHudTextParams(fCSD_PosX, fCSD_PosY, update_rate / g_fTickrate, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);

							Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(fSpeedHUD));
						}
						// spec'ing player
						else {
							if(g_iCSD_SpeedColor[client] != 6)
								displayColor = GetSpeedColourCSD(client, g_fLastSpeed[ObservedUser], g_iCSD_SpeedColor[client]);
							else{
								displayColor[0] = g_iCSD_R[client];
								displayColor[1] = g_iCSD_G[client];
								displayColor[2] = g_iCSD_B[client];
							}

							SetHudTextParams(fCSD_PosX, fCSD_PosY, update_rate / g_fTickrate, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);

							Format(szSpeed, sizeof(szSpeed), "%d", RoundToNearest(g_fLastSpeed[ObservedUser]));
						}
					}
				}
			}
			ShowHudText(client, -1, szSpeed);
			//ShowSyncHudText(client, HUD_Handle, szSpeed);
		}
	}
}

//LOAD SETTINGS	
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
		g_bCSD[client] = (SQL_FetchInt(hndl, 0) == 1 ? true : false);
	}
	else {
		char szQuery[1024];
		Format(szQuery, sizeof szQuery, "INSERT INTO mh_CSD (steamid) VALUES('%s')", g_szSteamID[client]);
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
