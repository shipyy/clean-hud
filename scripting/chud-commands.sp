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
    SetMenuTitle(menu, "Clean HUD\n \n");

    //CSD
    AddMenuItem(menu, "", "Center Speed Display");

    //KEYS
    AddMenuItem(menu, "", "Keys");
    
    //SYNC
    AddMenuItem(menu, "", "Sync");

    //CHECKPOINTS
    AddMenuItem(menu, "", "Checkpoints");

    //Timer
    AddMenuItem(menu, "", "Timer");

    //MAP INFO
    AddMenuItem(menu, "", "Map Info");

    //MAP FINISH
    AddMenuItem(menu, "", "Map Finish\n \n");


    //EXPORT
    AddMenuItem(menu, "", "Export Settings");
    
    SetMenuPagination(menu, 5);
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CHUD_MainMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{   
    if (action == MenuAction_Select) {
        switch(param2){
            case 0: CHUD_CSD(param1);
            case 1: CHUD_KEYS(param1);
            case 2: CHUD_SYNC(param1);
            case 3: CHUD_CP(param1);
            case 4: CHUD_TIMER(param1);
            case 5: CHUD_MAPINFO(param1);
            case 6: CHUD_FINISH(param1);
            case 7: Export(param1, -1, true, true);
        }
    }
    else if (action == MenuAction_End) {
		delete menu;
    }

    return 0;
}

public Action Client_Import(int client, int args)
{
    //if(!IsValidClient(client))
    //    return Plugin_Handled;

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

    if (args == 3)
        Export(client, GetCmdArgInt(1), true, false);
    else
        Export(client, -1, false, false);
    
    return Plugin_Handled;
}