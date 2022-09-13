public void CreateCMDS()
{
    //COMMANDS
    RegConsoleCmd("sm_chud", CHUD_MainMenu, "[Clean HUD] Opens main menu");
    //TODO
    RegConsoleCmd("sm_chud_export", Client_Export, "[Clean HUD] Export Settings");
    RegConsoleCmd("sm_chud_import", Client_Import, "[Clean HUD] Import Settings");
}

public Action CHUD_MainMenu(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    CHUD_MainMenu_Display(client);

    return Plugin_Handled;
}

public void CHUD_MainMenu_Display(int client)
{
    Menu menu = new Menu(CHUD_MainMenu_Handler);
    SetMenuTitle(menu, "Clean HUD | MODULES\n \n");

    //CSD
    AddMenuItem(menu, "", "SPEED");

    //Timer
    AddMenuItem(menu, "", "TIMER");

    //KEYS
    AddMenuItem(menu, "", "INPUT");

    //MAP INFO
    AddMenuItem(menu, "", "INFO\n \n");

    //GLOBAL OPTIONS
    AddMenuItem(menu, "", "OPTIONS");

    
    SetMenuPagination(menu, 5);
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_MainMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{   
    if (action == MenuAction_Select) {
        switch(param2){
            case 0: SPEED_MENU(param1);
            case 1: TIMER_MENU(param1);
            case 2: INPUT_MENU(param1);
            case 3: INFO_MENU(param1);
            case 4: OPTIONS_MENU(param1);
        }
    }
    else if (action == MenuAction_End) {
		delete menu;
    }

    return 0;
}

public Action Client_Import(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    char szImportSettings[1024];
    char szPlayerName[MAX_NAME_LENGTH];
    if (args == 3) {
        GetCmdArg(2, szImportSettings, sizeof szImportSettings);
        GetCmdArg(3, szPlayerName, sizeof szPlayerName);
        Import(client, GetCmdArgInt(1), szImportSettings, szPlayerName);
    }
    else {
        GetCmdArg(1, szImportSettings, sizeof szImportSettings);
        GetCmdArg(2, szPlayerName, sizeof szPlayerName);
        Import(client, -1, szImportSettings, szPlayerName);
    }
    
    return Plugin_Handled;
}

public Action Client_Export(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    /*
    if (args == 3)
        Export(client, GetCmdArgInt(1), true, false);
    else
        Export(client, -1, false, false);
    */
    
    return Plugin_Handled;
}