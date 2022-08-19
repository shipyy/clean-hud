public void CreateCMDS()
{
    //COMMANDS
    RegConsoleCmd("mhud", MHUD_MainMenu, "[Minimal HUD] Opens main menu");

}

public Action MHUD_MainMenu(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    MHUD_MainMenu_Display(client);

    return Plugin_Handled;
}

public void MHUD_MainMenu_Display(int client)
{
    Menu menu = new Menu(MHUD_MainMenu_Handler);
    SetMenuTitle(menu, "Minimal HUD\n \n");

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
    
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_MainMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{   
    if (action == MenuAction_Select) {
        switch(param2){
            case 0: MHUD_CSD(param1);
            case 1: MHUD_KEYS(param1);
            case 2: MHUD_SYNC(param1);
            case 3: MHUD_CP(param1);
            case 4: MHUD_TIMER(param1);
        }
    }
    else if (action == MenuAction_End) {
		delete menu;
    }

    return 0;
}