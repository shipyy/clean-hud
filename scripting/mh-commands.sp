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

    //MENU ITEMS
    AddMenuItem(menu, "", "Center Speed Display");
    
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MHUD_MainMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{   
    if (action == MenuAction_Select) {
        switch(param2){
            case 0: MHUD_CSD(param1);
        }
    }
    else if (action == MenuAction_End) {
		delete menu;
    }

    return 0;
}