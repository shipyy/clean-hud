public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (IsValidClient(client) && !IsFakeClient(client)) {
		if (g_iClientTick[client] - g_iCurrentTick[client] >= g_iRefreshRateValue[client]) {
			g_iCurrentTick[client] += g_iRefreshRateValue[client];

			SPEED_DISPLAY(client);
			TIMER_DISPLAY(client);
			INPUT_DISPLAY(client);
			INFO_DISPLAY(client);
		}
	}

	g_fLastSync[client] = surftimer_GetClientSync(client);
	g_fLastSpeed[client] = GetSpeed(client);
	g_iLastButton[client] = buttons;
	g_imouseDir[client] = mouse;

	return Plugin_Continue;
}

public void OnClientDisconnect(int client) 
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);
	PrintToConsole(0, "+++ Saving %s CHUD options +++", szName);
	db_SET_OPTIONS(client);

	return;
}

public void Hook_PostThinkPost(int entity)
{
	++g_iClientTick[entity];
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (g_iWaitingForResponse[client] == None)
		return Plugin_Handled;

	char Input[MAX_MESSAGE_LENGTH];
	strcopy(Input, sizeof(Input), sArgs);

	TrimString(Input);

	if (StrEqual(Input, "cancel", false))
	{
		switch (g_iArrayToChange[client]) {
			case 1: SPEED_Color_Change_MENU(client, g_iColorType[client]);
			case 2: TIMER_Color_Change_MENU(client, g_iColorType[client]);
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

				switch (g_iArrayToChange[client]) {
					case 1: {
						g_iSPEED_MODULE_COLOR[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //SPEED MODULE
						SPEED_Color_Change_MENU(client, g_iColorType[client]);
					}
					case 2: {
						g_iTIMER_MODULE_COLOR[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //TIMER MODULE
						TIMER_Color_Change_MENU(client, g_iColorType[client]);
					}
					case 3: {
						g_iINPUT_MODULE_COLOR[client][g_iColorType[client]][g_iColorIndex[client]] = color_value; //INPUT MODULE
						INPUT_Color_Change_MENU(client, g_iColorType[client]);
					}
					case 4: {
						g_iINFO_MODULE_COLOR[client][g_iColorIndex[client]] = color_value; //INFO MODULE
						INFO_Color(client);
					}
				}
			}
		}
		g_iWaitingForResponse[client] = None;
	}

	return Plugin_Handled;
}