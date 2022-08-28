void CreateHooks()
{
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (IsValidClient(client) && !IsFakeClient(client)) {
		CSD_Display(client);
		Keys_Display(client);
		Sync_Display(client);
		Timer_Display(client);
		MapInfo_Display(client);
	}

	g_fLastSpeed[client] = GetSpeed(client);
	g_iLastButton[client] = buttons;
	g_imouseDir[client] = mouse;
	
	return Plugin_Continue;
}

public void Hook_PostThinkPost(int entity)
{
	for(int i = 0; i < 6; i++)
		++g_iClientTick[entity][i];
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	int clientid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(clientid);

	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Handled;

	SaveCookies(client);

	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (g_iWaitingForResponse[client] == None)
		return Plugin_Continue;

	char Input[MAX_MESSAGE_LENGTH];
	strcopy(Input, sizeof(Input), sArgs);

	TrimString(Input);

	PrintToConsole(0, "===Input %s===", Input);

	if (StrEqual(Input, "cancel", false))
	{
		if( g_iColorType[client] >= 0) {
			switch (g_iArrayToChange[client]) {
				case 1: CSD_Color_Change_MENU(client, g_iColorType[client]);
				case 2: CP_Color_Change_MENU(client, g_iColorType[client]);
				case 3: Timer_Color_Change_MENU(client, g_iColorType[client]);
				case 4: Finish_Color_Change_MENU(client, g_iColorType[client]);
			}
		}
		else {
			switch (g_iColorType[client]) {
				case -1: CHUD_KEYS(client);
				case -2: CHUD_SYNC(client);
				case -3: CHUD_MAPINFO(client);
			}
		}
		CPrintToChat(client, "%t", "Cancel_Input");
		g_iWaitingForResponse[client] = None;
	}
	else
	{
		switch (g_iWaitingForResponse[client])
		{
			case ChangeColor:
			{
				int color_value = StringToInt(Input);

				// KEEP VALUES BETWEEN 0-255
				if (color_value > 255)
					color_value = 255;
				else if (color_value < 0)
					color_value = 0;

				if( g_iColorType[client] >= 0) {
					switch (g_iArrayToChange[client]) {
						case 1: {
							g_iCSD_Color[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //CSD
							CSD_Color_Change_MENU(client, g_iColorType[client]);
						}
						case 2: {
							g_iCP_Color[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //CP
							CP_Color_Change_MENU(client, g_iColorType[client]);
						}
						case 3: {
							g_iTimer_Color[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //TIMER
							Timer_Color_Change_MENU(client, g_iColorType[client]);
						}
						case 4: {
							g_iFinish_Color[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //FINISH
							Finish_Color_Change_MENU(client, g_iColorType[client]);
						}
					}
				}
				else {
					switch (g_iColorType[client]) {
						case -1: {
							g_iKeys_Color[client][g_iColorIndex[client]] = color_value; //KEYS
							CHUD_KEYS(client);
						}
						case -2: {
							g_iSync_Color[client][g_iColorIndex[client]] = color_value; //SYNC
							CHUD_SYNC(client);
						}
						case -3: {
							g_iMapInfo_Color[client][g_iColorIndex[client]] = color_value; //MAPINFO
							CHUD_MAPINFO(client);
						}
					}
				}
			}
		}
		g_iWaitingForResponse[client] = None;
	}

	return Plugin_Handled;
}