/////
//HANDLES
/////
Handle g_hCSD_Cookie;
Handle g_hKeys_Cookie;
Handle g_hSync_Cookie;
Handle g_hCP_Cookie;
Handle g_hTimer_Cookie;
Handle g_hMapInfo_Cookie;
Handle g_hFinish_Cookie;
Handle g_hPrestrafe_Cookie;

char[] ConvertDataToString(int client, int module)
{   
    char szData[512];
    switch (module) {
        case 0 : szData = CSD_ConvertDataToString(client);
        case 1 : szData = Keys_ConvertDataToString(client);
        case 2 : szData = Sync_ConvertDataToString(client);
        case 3 : szData = CP_ConvertDataToString(client);
        case 4 : szData = Timer_ConvertDataToString(client);
        case 5 : szData = MapInfo_ConvertDataToString(client);
        case 6 : szData = Finish_ConvertDataToString(client);
        case 7 : szData = PRESTRAFE_ConvertDataToString(client);
    }

    return szData;
}

public void ConvertStringToData(int client, int module, char szData[512])
{
    switch (module) {
        case 0 : CSD_ConvertStringToData(client, szData);
        case 1 : Keys_ConvertStringToData(client, szData);
        case 2 : Sync_ConvertStringToData(client, szData);
        case 3 : CP_ConvertStringToData(client, szData);
        case 4 : Timer_ConvertStringToData(client, szData);
        case 5 : MapInfo_ConvertStringToData(client, szData);
        case 6 : Finish_ConvertStringToData(client, szData);
        case 7 : PRESTRAFE_ConvertStringToData(client, szData);
    }
}

public void GetCookie(int client, int module)
{
    char szData[512];
    switch (module) {
        case 0 : {
            GetClientCookie(client, g_hCSD_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                CSD_SetDefaults(client);
            else
                ConvertStringToData(client, 0, szData);
            PrintToServer("* CSD COOKIES LOADED *");
        }
        case 1 : {
            GetClientCookie(client, g_hKeys_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                Keys_SetDefaults(client);
            else
                ConvertStringToData(client, 1, szData);
            PrintToServer("* Keys COOKIES LOADED *");
        }
        case 2 : {
            GetClientCookie(client, g_hSync_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                Sync_SetDefaults(client);
            else
                ConvertStringToData(client, 2, szData);
            PrintToServer("* Sync COOKIES LOADED *");
        }
        case 3 : {
            GetClientCookie(client, g_hCP_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                CP_SetDefaults(client);
            else
                ConvertStringToData(client, 3, szData);
            PrintToServer("* CP COOKIES LOADED *");
        }
        case 4 : {
            GetClientCookie(client, g_hTimer_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                Timer_SetDefaults(client);
            else
                ConvertStringToData(client, 4, szData);
            PrintToServer("* Timer COOKIES LOADED *");
        }
        case 5 : {
            GetClientCookie(client, g_hMapInfo_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                MapInfo_SetDefaults(client);
            else
                ConvertStringToData(client, 5, szData);
            PrintToServer("* MapInfo COOKIES LOADED *");
        }
        case 6 : {
            GetClientCookie(client, g_hFinish_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                Finish_SetDefaults(client);
            else
                ConvertStringToData(client, 6, szData);
            PrintToServer("* Finish COOKIES LOADED *");
        }
        case 7 : {
            GetClientCookie(client, g_hPrestrafe_Cookie, szData, sizeof szData);
            if(strcmp(szData, "", false) == 0)
                PRESTRAFE_SetDefaults(client);
            else
                ConvertStringToData(client, 7, szData);
            PrintToServer("* Prestrafe COOKIES LOADED *");
        }
    }
}

public void SetCookie(int client, int module)
{
    char szData[512];
    switch (module) {
        case 0 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hCSD_Cookie, szData);
        }
        case 1 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hKeys_Cookie, szData);
        }
        case 2 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hSync_Cookie, szData);
        }
        case 3 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hCP_Cookie, szData);
        }
        case 4 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hTimer_Cookie, szData);
        }
        case 5 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hMapInfo_Cookie, szData);
        }
        case 6 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hFinish_Cookie, szData);
        }
        case 7 : {
            szData = ConvertDataToString(client, module);
            SetClientCookie(client, g_hPrestrafe_Cookie, szData);
        }
    }
}