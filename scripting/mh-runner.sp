void CreateHooks()
{
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsValidClient(client)) {
		CSD_Display(client);
		Keys_Display(client);

		g_fLastSpeed[client] = GetSpeed(client);
		g_iLastButton[client] = buttons;
	}

	return Plugin_Continue;
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	int clientid = GetEventInt(event, "userid");
	int client   = GetClientOfUserId(clientid);

	if (IsValidClient(client) && !IsFakeClient(client))
	{
		db_updateCSD(client);
	}

	return Plugin_Handled;
}

public void Hook_PostThinkPost(int entity)
{
	++g_iClientTick[entity];
}

/////
// CHAT
/////
public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	int client = view_as<int>(author);

	if (IsValidClient(client))
	{
		// Functions that require the client to input something via the chat box
		if (g_iWaitingForResponse[client] > None)
		{
			// Check if client is cancelling
			if (StrEqual(message, "cancel"))
			{
				LogError("Cancelled!");
				recipients.Clear();
				recipients.Push(GetClientUserId(client));
				return Plugin_Changed;
			}

			// Check which function we're waiting for
			switch (g_iWaitingForResponse[client])
			{
				case ChangeColor:
				{
					// COLOR VALUE FOR CENTER SPEED
					int color_value = StringToInt(message);

					// KEEP VALUES BETWEEN 0-255
					if (color_value > 255)
						color_value = 255;
					else if (color_value < 0)
						color_value = 0;

					if( g_iColorType[client] != -1)
						g_iCSD_SpeedColor[client][g_iColorType[client]][g_iColorIndex[client]] = color_value;
					else {
						//-1 Keys
						//-2 Sync
						//-3 Map Info
						//-4 Timer
						//-5 CPs
						switch (g_iColorType[client]) {
							case -1: g_iKeys_Color[client][g_iColorIndex[client]] = color_value;
						}
					}
				}
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Changed;
}

public void CP_OnChatMessagePost(int author, ArrayList recipients, const char[] flagstring, const char[] formatstring, const char[] name, const char[] message, bool processcolors, bool removecolors)
{
	int client = view_as<int>(author);

	if (IsValidClient(client))
	{
		// Functions that require the client to input something via the chat box
		if (g_iWaitingForResponse[client] > None)
		{
			// Check if client is cancelling
			if (StrEqual(message, "cancel"))
			{
				CSD_Color_Change_MENU(client, g_iColorType[client]);
			}

			// Check which function we're waiting for
			switch (g_iWaitingForResponse[client])
			{
				case ChangeColor:
				{
					CSD_Color_Change_MENU(client, g_iColorType[client]);
				}
			}

			g_iWaitingForResponse[client] = None;
		}
	}
}