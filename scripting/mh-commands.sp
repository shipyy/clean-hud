public void CreateCMDS()
{
    //COMMANDS
    RegConsoleCmd("mhud", MHUD_Menu, "[Minimal HUD] Opens main menu");

}

public Action MHUD_Menu(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    Menu menu = new Menu(MHUD_Menu_Handler);

    //MENU ITEMS
    AddMenuItem(menu, "", "Center Speed Display");
    
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public int MHUD_Menu_Handler(Menu menu, MenuAction action, int param1, int param2)
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