public CSD_SetDefaults(int client)
{
	PrintToServer("Loading CSD Defaults!");

	g_bCSD[client] = false;
	g_iCSD_SpeedAxis[client] = 0;
}

public void SUBMODULE_CSD(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(CHUD_CSD_Handler);
	char szItem[128];

	SetMenuTitle(menu, "Center Speed Options Menu\n \n");

	// Toggle
	if (g_bCSD[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");

	// Position
	Format(szItem, sizeof szItem, "Position | %d", g_CSD_SUBMODULE_INDEX[client]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_CSD_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: CSD_Toggle(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void CSD_Toggle(int client)
{
    if (g_bCSD[client])
		g_bCSD[client] = false;
	else
		g_bCSD[client] = true;

    SUBMODULE_CSD(client);
}

/////
//AXIS
/////
void CSD_Axis(int client)
{
	if (g_iCSD_SpeedAxis[client] != 2)
		g_iCSD_SpeedAxis[client]++;
	else
		g_iCSD_SpeedAxis[client] = 0;

	SUBMODULE_CSD(client);
}

/////
//MISC
////
int[] GetSpeedColourCSD(int client, float speed)
{	
	int displayColor[3] = {255, 255, 255};
	
	//gaining speed or mainting
	if (g_fLastSpeed[client] < speed || (g_fLastSpeed[client] == speed && speed != 0.0) ) {
		displayColor[0] = g_szSPEED_MODULE[client][0][0];
		displayColor[1] = g_szSPEED_MODULE[client][0][1];
		displayColor[2] = g_szSPEED_MODULE[client][0][2];
	}
	//losing speed
	else if (g_fLastSpeed[client] > speed ) {
		displayColor[0] = g_szSPEED_MODULE[client][1][0];
		displayColor[1] = g_szSPEED_MODULE[client][1][1];
		displayColor[2] = g_szSPEED_MODULE[client][1][2];
	}
	//not moving (speed == 0)
	else {
		displayColor[0] = g_szSPEED_MODULE[client][2][0];
		displayColor[1] = g_szSPEED_MODULE[client][2][1];
		displayColor[2] = g_szSPEED_MODULE[client][2][2];
	}

	g_fLastSpeed[client] = speed;

	return displayColor;
}

/////
//DISPLAY
/////
public void CSD_Format(int client)
{
	if (g_bCSD[client] && !IsFakeClient(client)) {

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

		Format(g_szCSD_SUBMODULE[client], sizeof g_szCSD_SUBMODULE, "%d", RoundToNearest(g_fLastSpeed[target]));
	}
	else {
		Format(g_szCSD_SUBMODULE[client], sizeof g_szCSD_SUBMODULE, "");
	}
}