public Init_SPEED_MODULE(){
	Handle_SPEED_MODULE = CreateHudSynchronizer();
}

/////
//MENU
/////
public void SPEED_MENU(int client)
{
	if (!IsValidClient(client))
		return;

	Menu menu = CreateMenu(SPEED_MENU_Handler);
	char szItem[128];

	SetMenuTitle(menu, "SPEED MODULE MENU\n \n");

	// Toggle
	if (g_bSPEED_MODULE[client])
		AddMenuItem(menu, "", "Toggle   | On");
	else
		AddMenuItem(menu, "", "Toggle   | Off");
    
    // Color
	Format(szItem, sizeof szItem, "Color\n \n");
	AddMenuItem(menu, "", szItem);

    // SUB MODULES
	Format(szItem, sizeof szItem, "Customize Submodules\n \n");
	AddMenuItem(menu, "", szItem);

    // SUB MODULES
	Format(szItem, sizeof szItem, "Export");
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: SPEED_Toggle(param1);
			case 1: SPEED_Position(param1);
			case 2: SPEED_Color(param1);
			case 3: SPEED_SUBMODULES(param1);
			case 4: SPEED_Color(param1);
		}
	}
	else if (action == MenuAction_Cancel)
		delete menu;
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

/////
//TOGGLE
/////
public void SPEED_Toggle(int client)
{
    if (g_bSPEED_MODULE[client])
		g_bSPEED_MODULE[client] = false;
	else
		g_bSPEED_MODULE[client] = true;

    SPEED_MENU(client);
}

/////
//POSITION
/////
public void SPEED_Position(int client)
{
	Menu menu = CreateMenu(SPEED_Position_Handler);
	SetMenuTitle(menu, "SPEED | Position\n \n");

	AddMenuItem(menu, "", "Right");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Up");
	AddMenuItem(menu, "", "Down");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Position_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{	
			case 0: SPEED_PosX(param1, 1);
			case 1: SPEED_PosX(param1, -1);
			case 2: SPEED_PosY(param1, 1);
			case 3: SPEED_PosY(param1, -1);
		}
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

void SPEED_PosX(int client, int direction)
{
    switch (direction) {
        case 1 : g_fSPEED_MODULE_POSITION[client][0] = (g_fSPEED_MODULE_POSITION[client][0] + 0.1) > 1.0 ? 1.0 : g_fSPEED_MODULE_POSITION[client][0] + 0.1;
        case -1 : g_fSPEED_MODULE_POSITION[client][0] = (g_fSPEED_MODULE_POSITION[client][0] - 0.1) < 0.0 ? 0.0 : g_fSPEED_MODULE_POSITION[client][0] - 0.1;
    }

    SPEED_Position(client);
}

void SPEED_PosY(int client, int direction)
{
    switch (direction) {
        case 1 : g_fSPEED_MODULE_POSITION[client][1] = (g_fSPEED_MODULE_POSITION[client][1] + 0.1) > 1.0 ? 1.0 : g_fSPEED_MODULE_POSITION[client][1] + 0.1;
        case -1 : g_fSPEED_MODULE_POSITION[client][1] = (g_fSPEED_MODULE_POSITION[client][1] - 0.1) < 0.0 ? 0.0 : g_fSPEED_MODULE_POSITION[client][1] - 0.1;
    }

    SPEED_Position(client);
}

/////
//COLOR
/////
public void SPEED_Color(int client)
{
	Menu menu = CreateMenu(SPEED_Color_Handler);
	char szItem[128];

	SetMenuTitle(menu, "SPEED MODULE | Color\n \n");

	Format(szItem, sizeof szItem, "Gain     | %d %d %d", g_iSPEED_MODULE_COLOR[client][0][0], g_iSPEED_MODULE_COLOR[client][0][1], g_iSPEED_MODULE_COLOR[client][0][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Loss     | %d %d %d", g_iSPEED_MODULE_COLOR[client][1][0], g_iSPEED_MODULE_COLOR[client][1][1], g_iSPEED_MODULE_COLOR[client][1][2]);
	AddMenuItem(menu, "", szItem);

	Format(szItem, sizeof szItem, "Maintain | %d %d %d", g_iSPEED_MODULE_COLOR[client][2][0], g_iSPEED_MODULE_COLOR[client][2][1], g_iSPEED_MODULE_COLOR[client][2][2]);
	AddMenuItem(menu, "", szItem);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Color_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		SPEED_Color_Change_MENU(param1, param2);
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void SPEED_Color_Change_MENU(int client, int type)
{
	char szBuffer[32];

	Menu menu = CreateMenu(SPEED_Color_Change_MENU_Handler);
	switch (type) {
		case 0:	SetMenuTitle(menu, "Gain Color\n \n");
		case 1: SetMenuTitle(menu, "Loss Color\n \n");
		case 2: SetMenuTitle(menu, "Maintain Color\n \n");
	}

	Format(szBuffer, sizeof szBuffer, "%d", type);

	char szItemDisplay[32];

	Format(szItemDisplay, sizeof szItemDisplay, "R | %d", g_iSPEED_MODULE_COLOR[client][type][0]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "G | %d", g_iSPEED_MODULE_COLOR[client][type][1]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	Format(szItemDisplay, sizeof szItemDisplay, "B | %d", g_iSPEED_MODULE_COLOR[client][type][2]);
	AddMenuItem(menu, szBuffer, szItemDisplay);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_Color_Change_MENU_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){

		char szBuffer[32];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		SPEED_Color_Change(param1, StringToInt(szBuffer), param2);
	}
	else if (action == MenuAction_Cancel)
		SPEED_Color(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void SPEED_Color_Change(int client, int color_type, int color_index)
{
	CPrintToChat(client, "%t", "Color_Input");
	g_iArrayToChange[client] = 1;
	g_iColorIndex[client] = color_index;
	g_iColorType[client] = color_type;
	g_iWaitingForResponse[client] = ChangeColor;
}

/////
//SUBMODULES
/////

public void SPEED_SUBMODULES(int client)
{
    Menu menu = CreateMenu(SPEED_SUBMODULES_Handler);

    AddMenuItem(menu, "", "Center Speed Display");

    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SPEED_SUBMODULES_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select){
        switch (param2) {
            case 0 : SUBMODULE_CSD(param1);
        }
	}
	else if (action == MenuAction_Cancel)
		SPEED_MENU(param1);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}


/////
//DISPLAY
/////
public void SPEED_DISPLAY(int client)
{
    if (g_bSPEED_MODULE[client] && !IsFakeClient(client)) {

        CSD_Format(client);

        /*
        this array would contain the submodules string ?
        char g_SPEED_SUBMODULE_INDEXES[2]

        submodules index
        1 speed
        2 sync

        g_szSPEED_SUBMODULE_INDEXES[0] = SPEED
        g_szSPEED_SUBMODULE_INDEXES[1] = SYNC

        SO WHEN USER WOULD SWAP POSITION IN SUBMODULE MENU WE JUST SWAP/REPLACE THE STRINGS
        //REPLACE
        THIS CASE WE SIMPLY REPLACE THE SELECTED INDEX WITH THE SUBMODULE STRING

        //SWAP
        THIS CASE WE SWAP SUBMODULE STRINGS WITH THE ONE REQUESTED TO CHANGE
        -- EXAMPLE --
        SPEED IS INDEX 1
        SYNC IS INDEX 2
        - WE FIRST GET THE SPEED STRING, STORE IT
        - WE GET THE NEW SUBMODULE SELECTED STRING AND STORE IT IN AUX VAR
        - WE REPLACE THE NEW SELECTED SUBMODULE WITH THE SPEED STRING
        - WE REPLACE THE SUBMODULE WHERE SPEED WAS AND REPLACE IT WITH THE VALUE OF THE AUX VAR


        for(int i = 0; i < g_SPEED_MODULE_INDEXES.Length; i++) {
            Format(szSPEED_MODULE, sizeof szSPEED_MODULE, "%s\n%s", szSPEED_MODULE[client], g_szSPEED_SUBMODULE_INDEXES[i])
        }
        */
        int displayColor[3];
        displayColor = GetSpeedColourCSD(client, GetSpeed(client));

        float  posx = g_fSPEED_MODULE_POSITION[client][0] == 0.5 ? -1.0 : g_fSPEED_MODULE_POSITION[client][0];
        float posy = g_fSPEED_MODULE_POSITION[client][1] == 0.5 ? -1.0 : g_fSPEED_MODULE_POSITION[client][1];

        SetHudTextParams(posx, posy, 0.1, displayColor[0], displayColor[1], displayColor[2], 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudText(client, Handle_SPEED_MODULE, g_szSPEED_MODULE[client]);
    }
}
