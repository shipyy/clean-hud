void CreateHooks(){
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    CenterSpeedDisplay(client);

    g_fLastSpeed[client] = GetSpeed(client);

    return Plugin_Continue;
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
    int clientid = GetEventInt(event, "userid");
    int client = GetClientOfUserId(clientid);

    if (IsValidClient(client) && !IsFakeClient(client)) {
		db_updateCSD(client);
	}
    return Plugin_Handled;
}

public void Hook_PostThinkPost(int entity)
{
	++g_iClientTick[entity];
}