stock bool IsValidClient(int client)
{   
    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        return true;
    return false;
}

public float GetSpeed(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	float speed;

	if (g_iCSD_SpeedAxis[client] == 0) // XY
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	else if (g_iCSD_SpeedAxis[client] == 1) // XYZ
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	else if (g_iCSD_SpeedAxis[client] == 2) // Z
		speed = fVelocity[2];
	else // XY default
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));

	return speed;
}

public void Format_Time(int client, float time, char[] string, int length, bool runtime)
{
	char szDays[16];
	char szHours[16];
	char szMinutes[16];
	char szSeconds[16];
	char szMS[16];

	if (time < 0.0)
		time *= -1.0;

	int time_rounded = RoundToZero(time);

	int days = time_rounded / 86400;
	int hours = (time_rounded - (days * 86400)) / 3600;
	int minutes = (time_rounded - (days * 86400) - (hours * 3600)) / 60;
	int seconds = (time_rounded - (days * 86400) - (hours * 3600) - (minutes * 60));
	int ms = RoundToZero(FloatFraction(time) * 1000);

	// 00:00:00:00:000
	// 00:00:00:000
	// 00:00:000

	//MILISECONDS
	if (ms < 10)
		Format(szMS, 16, "00%d", ms);
	else
		if (ms < 100)
			Format(szMS, 16, "0%d", ms);
		else
			Format(szMS, 16, "%d", ms);

	//SECONDS
	if (seconds < 10)
		Format(szSeconds, 16, "0%d", seconds);
	else
		Format(szSeconds, 16, "%d", seconds);

	//MINUTES
	if (minutes < 10)
		Format(szMinutes, 16, "0%d", minutes);
	else
		Format(szMinutes, 16, "%d", minutes);

	//HOURS
	if (hours < 10)
		Format(szHours, 16, "0%d", hours);
	else
		Format(szHours, 16, "%d", hours);

	//DAYS
	if (days < 10)
		Format(szDays, 16, "0%d", days);
	else
		Format(szDays, 16, "%d", days);

	if (!runtime) {
		if (days > 0) {
			Format(string, length, "%sd %sh %sm %ss %sms", szDays, szHours, szMinutes, szSeconds, szMS);
		}
		else {
			if (hours > 0) {
				Format(string, length, "%sh %sm %ss %sms", szHours, szMinutes, szSeconds, szMS);
			}
			else {
				Format(string, length, "%sm %ss %sms", szMinutes, szSeconds, szMS);
			}
		}
	}
	else {
		if (hours > 0) {
			Format(string, length, "%s:%s:%s.%s", szHours, szMinutes, szSeconds, szMS);
		}
		else {
			Format(string, length, "%s:%s.%s", szMinutes, szSeconds, szMS);
		}
	}

}

/*
char[] Export(int client, int module, bool just_string, bool from_menu)
{
	char szSettings[128];

	if (module != -1){
		switch (module) {
			case 0 : {
				Format(szSettings, sizeof szSettings, 
					"%d|%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
					g_bCSD[client] ? 1 : 0, 
					g_iCSD_SpeedAxis[client], 
					g_fCSD_POSX[client], g_fCSD_POSY[client],
					g_iCSD_Color[client][0][0], g_iCSD_Color[client][0][1], g_iCSD_Color[client][0][2],
					g_iCSD_Color[client][1][0], g_iCSD_Color[client][1][1], g_iCSD_Color[client][1][2],
					g_iCSD_Color[client][2][0], g_iCSD_Color[client][2][1], g_iCSD_Color[client][2][2]
				);
			}
			case 1: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d", //7
					g_bKeys[client] ? 1 : 0, 
					g_fKeys_POSX[client], g_fKeys_POSY[client],
					g_iKeys_Color[client][0][0], g_iKeys_Color[client][0][1], g_iKeys_Color[client][0][2]
				);
			}
			case 2: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d", //7
					g_bSync[client] ? 1 : 0, 
					g_fSync_POSX[client], g_fSync_POSY[client],
					g_iSync_Color[client][0][0], g_iSync_Color[client][0][1], g_iSync_Color[client][0][2]
				);

			}
			case 3: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
					g_bCP[client] ? 1 : 0, 
					g_fCP_POSX[client], g_fCP_POSY[client],
					g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2],
					g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2],
					g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2],
					g_iCP_HoldTime[client],
					g_iCP_CompareMode[client]
				);
			}
			case 4: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d", //10
					g_bTimer[client] ? 1 : 0, 
					g_fTimer_POSX[client], g_fTimer_POSY[client],
					g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2],
					g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2]
				);
			}
			case 5: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d|%d|%d", //8
					g_bMapInfo[client] ? 1 : 0, 
					g_fMapInfo_POSX[client], g_fMapInfo_POSY[client],
					g_iMapInfo_Color[client][0][0], g_iMapInfo_Color[client][0][1], g_iMapInfo_Color[client][0][2],
					g_iMapInfo_ShowMode[client],
					g_iMapInfo_CompareMode[client]
				);
			}
			case 6: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
					g_bFinish[client] ? 1 : 0, 
					g_fFinish_POSX[client], g_fFinish_POSY[client],
					g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2],
					g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2],
					g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2],
					g_iFinish_HoldTime[client],
					g_iFinish_CompareMode[client]
				);

			}
			case 7: {
				GetClientName(client, szSettings, sizeof szSettings);
			}
		}

		if (!just_string) {

			if (from_menu) {
				switch (module) {
					case 0 : CHUD_CSD(client);
					case 1 : CHUD_KEYS(client);
					case 2 : CHUD_SYNC(client);
					case 3 : CHUD_CP(client);
					case 4 : CHUD_TIMER(client);
					case 5 : CHUD_MAPINFO(client);
					case 6 : CHUD_FINISH(client);
				}
			}

			char szModule[32];
			switch (module) {
				case 0 : Format(szModule, sizeof szModule, "%s", "Center Speed Display");
				case 1 : Format(szModule, sizeof szModule, "%s", "Keys");
				case 2 : Format(szModule, sizeof szModule, "%s", "Sync");
				case 3 : Format(szModule, sizeof szModule, "%s", "Checkpoints");
				case 4 : Format(szModule, sizeof szModule, "%s", "Timer");
				case 5 : Format(szModule, sizeof szModule, "%s", "Map Infoap");
				case 6 : Format(szModule, sizeof szModule, "%s", "Finish");
			}

			char szClientName[MAX_NAME_LENGTH];
			GetClientName(client, szClientName, sizeof szClientName);

			CPrintToChat(client, "%t", "Settings_Exported", szModule);
			PrintToConsole(client, "To import settings for idividual modules use\nsm_chud_import <module> <code>");
			PrintToConsole(client, "Export Code - %d %s %s", module, szSettings, szClientName);
		}

	}
	else {
		Export_All(client, from_menu);
		CHUD_MainMenu_Display(client);
	}

	return szSettings;
}

public void Export_All(int client, bool from_menu)
{
	char szSettings[1024];
	for(int i = 0; i < 7; i++)
		Format(szSettings, sizeof szSettings, "%s|%s", szSettings, Export(client, i, true, from_menu));
	
	//ADD PLAYERNAME
	Format(szSettings, sizeof szSettings, "%s %s", szSettings, Export(client, 7, true, from_menu));
	
	CPrintToChat(client, "%t", "Settings_Exported_All");
	PrintToConsole(client, "To import settings use\nsm_chud_import <code>");
	PrintToConsole(client, "Export Code - %s", szSettings);
}

public void Import(int client, int module, char szImportSettings[1024], char szPlayerName[MAX_NAME_LENGTH])
{	
	//72 fields
	char Modules[74][8];
	int fields = ExplodeString(szImportSettings, "|", Modules, sizeof Modules, sizeof Modules[]);

	if (module != -1) {
		switch (module) {
			case 0 : {
				if (fields == 13) {
					g_bCSD[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_iCSD_SpeedAxis[client] = StringToInt(Modules[1]);
					g_fCSD_POSX[client] = StringToFloat(Modules[2]);
					g_fCSD_POSY[client] = StringToFloat(Modules[3]);

					g_iCSD_Color[client][0][0] = StringToInt(Modules[4]);
					g_iCSD_Color[client][0][1] = StringToInt(Modules[5]);
					g_iCSD_Color[client][0][2] = StringToInt(Modules[6]);

					g_iCSD_Color[client][1][0] = StringToInt(Modules[7]);
					g_iCSD_Color[client][1][1] = StringToInt(Modules[8]);
					g_iCSD_Color[client][1][2] = StringToInt(Modules[9]);

					g_iCSD_Color[client][2][0] = StringToInt(Modules[10]);
					g_iCSD_Color[client][2][1] = StringToInt(Modules[11]);
					g_iCSD_Color[client][2][2] = StringToInt(Modules[12]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Center Speed Display", szPlayerName);

				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 1 : {
				if (fields == 6) {
					g_bKeys[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fKeys_POSX[client] = StringToFloat(Modules[1]);
					g_fKeys_POSY[client] = StringToFloat(Modules[2]);

					g_iKeys_Color[client][0][0] = StringToInt(Modules[3]);
					g_iKeys_Color[client][0][1] = StringToInt(Modules[4]);
					g_iKeys_Color[client][0][2] = StringToInt(Modules[5]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Sync", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 2 : {
				if (fields == 6) {
					g_bSync[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fSync_POSX[client] = StringToFloat(Modules[1]);
					g_fSync_POSY[client] = StringToFloat(Modules[2]);

					g_iSync_Color[client][0][0] = StringToInt(Modules[3]);
					g_iSync_Color[client][0][1] = StringToInt(Modules[4]);
					g_iSync_Color[client][0][2] = StringToInt(Modules[5]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Keys", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 3 : {
				if (fields == 14) {
					g_bCP[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fCP_POSX[client] = StringToFloat(Modules[1]);
					g_fCP_POSY[client] = StringToFloat(Modules[2]);

					g_iCP_Color[client][0][0] = StringToInt(Modules[3]);
					g_iCP_Color[client][0][1] = StringToInt(Modules[4]);
					g_iCP_Color[client][0][2] = StringToInt(Modules[5]);

					g_iCP_Color[client][1][0] = StringToInt(Modules[6]);
					g_iCP_Color[client][1][1] = StringToInt(Modules[7]);
					g_iCP_Color[client][1][2] = StringToInt(Modules[9]);

					g_iCP_Color[client][2][0] = StringToInt(Modules[9]);
					g_iCP_Color[client][2][1] = StringToInt(Modules[10]);
					g_iCP_Color[client][2][2] = StringToInt(Modules[11]);

					g_iCP_HoldTime[client] = StringToInt(Modules[12]);
					g_iCP_CompareMode[client] = StringToInt(Modules[13]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Checkpoints", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 4 : {
				if (fields == 9) {
					g_bTimer[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fTimer_POSX[client] = StringToFloat(Modules[1]);
					g_fTimer_POSY[client] = StringToFloat(Modules[2]);

					g_iTimer_Color[client][0][0] = StringToInt(Modules[3]);
					g_iTimer_Color[client][0][1] = StringToInt(Modules[4]);
					g_iTimer_Color[client][0][2] = StringToInt(Modules[5]);

					g_iTimer_Color[client][1][0] = StringToInt(Modules[6]);
					g_iTimer_Color[client][1][1] = StringToInt(Modules[7]);
					g_iTimer_Color[client][1][2] = StringToInt(Modules[8]);
					CPrintToChat(client, "%t" , "Settings_Imported", "Timer", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 5 : {
				if (fields == 8) {
					g_bMapInfo[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fMapInfo_POSX[client] = StringToFloat(Modules[1]);
					g_fMapInfo_POSY[client] = StringToFloat(Modules[2]);

					g_iMapInfo_Color[client][0][0] = StringToInt(Modules[3]);
					g_iMapInfo_Color[client][0][1] = StringToInt(Modules[4]);
					g_iMapInfo_Color[client][0][2] = StringToInt(Modules[5]);

					g_iMapInfo_ShowMode[client] = StringToInt(Modules[6]);
					g_iMapInfo_CompareMode[client] = StringToInt(Modules[7]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Map Info", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 6 : {
				if (fields == 14) {
					g_bFinish[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fFinish_POSX[client] = StringToFloat(Modules[1]);
					g_fFinish_POSY[client] = StringToFloat(Modules[2]);

					g_iFinish_Color[client][0][0] = StringToInt(Modules[3]);
					g_iFinish_Color[client][0][1] = StringToInt(Modules[4]);
					g_iFinish_Color[client][0][2] = StringToInt(Modules[5]);

					g_iFinish_Color[client][1][0] = StringToInt(Modules[6]);
					g_iFinish_Color[client][1][1] = StringToInt(Modules[7]);
					g_iFinish_Color[client][1][2] = StringToInt(Modules[8]);

					g_iFinish_Color[client][2][0] = StringToInt(Modules[9]);
					g_iFinish_Color[client][2][1] = StringToInt(Modules[10]);
					g_iFinish_Color[client][2][2] = StringToInt(Modules[11]);

					g_iFinish_HoldTime[client] = StringToInt(Modules[12]);
					g_iFinish_CompareMode[client] = StringToInt(Modules[13]);

					CPrintToChat(client, "%t" , "Settings_Imported", "Finish", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
		}
	}
	else {
		if (fields == 70) {
			//CSD
			g_bCSD[client] = StringToInt(Modules[0]) == 1 ? true : false;
			g_iCSD_SpeedAxis[client] = StringToInt(Modules[1]);
			g_fCSD_POSX[client] = StringToFloat(Modules[2]);
			g_fCSD_POSY[client] = StringToFloat(Modules[3]);

			g_iCSD_Color[client][0][0] = StringToInt(Modules[4]);
			g_iCSD_Color[client][0][1] = StringToInt(Modules[5]);
			g_iCSD_Color[client][0][2] = StringToInt(Modules[6]);

			g_iCSD_Color[client][1][0] = StringToInt(Modules[7]);
			g_iCSD_Color[client][1][1] = StringToInt(Modules[8]);
			g_iCSD_Color[client][1][2] = StringToInt(Modules[9]);

			g_iCSD_Color[client][2][0] = StringToInt(Modules[10]);
			g_iCSD_Color[client][2][1] = StringToInt(Modules[11]);
			g_iCSD_Color[client][2][2] = StringToInt(Modules[12]);

			//KEYS
			g_bKeys[client] = StringToInt(Modules[13]) == 1 ? true : false;
			g_fKeys_POSX[client] = StringToFloat(Modules[14]);
			g_fKeys_POSY[client] = StringToFloat(Modules[5]);

			g_iKeys_Color[client][0][0] = StringToInt(Modules[16]);
			g_iKeys_Color[client][0][1] = StringToInt(Modules[17]);
			g_iKeys_Color[client][0][2] = StringToInt(Modules[18]);

			//SYNC
			g_bSync[client] = StringToInt(Modules[19]) == 1 ? true : false;
			g_fSync_POSX[client] = StringToFloat(Modules[20]);
			g_fSync_POSY[client] = StringToFloat(Modules[21]);

			g_iSync_Color[client][0][0] = StringToInt(Modules[22]);
			g_iSync_Color[client][0][1] = StringToInt(Modules[23]);
			g_iSync_Color[client][0][2] = StringToInt(Modules[24]);

			//CP
			g_bCP[client] = StringToInt(Modules[25]) == 1 ? true : false;
			g_fCP_POSX[client] = StringToFloat(Modules[26]);
			g_fCP_POSY[client] = StringToFloat(Modules[27]);

			g_iCP_Color[client][0][0] = StringToInt(Modules[28]);
			g_iCP_Color[client][0][1] = StringToInt(Modules[29]);
			g_iCP_Color[client][0][2] = StringToInt(Modules[30]);

			g_iCP_Color[client][1][0] = StringToInt(Modules[31]);
			g_iCP_Color[client][1][1] = StringToInt(Modules[32]);
			g_iCP_Color[client][1][2] = StringToInt(Modules[33]);

			g_iCP_Color[client][2][0] = StringToInt(Modules[34]);
			g_iCP_Color[client][2][1] = StringToInt(Modules[35]);
			g_iCP_Color[client][2][2] = StringToInt(Modules[36]);

			g_iCP_HoldTime[client] = StringToInt(Modules[37]);
			g_iCP_CompareMode[client] = StringToInt(Modules[38]);

			//TIMER
			g_bTimer[client] = StringToInt(Modules[39]) == 1 ? true : false;
			g_fTimer_POSX[client] = StringToFloat(Modules[40]);
			g_fTimer_POSY[client] = StringToFloat(Modules[41]);

			g_iTimer_Color[client][0][0] = StringToInt(Modules[42]);
			g_iTimer_Color[client][0][1] = StringToInt(Modules[43]);
			g_iTimer_Color[client][0][2] = StringToInt(Modules[44]);

			g_iTimer_Color[client][1][0] = StringToInt(Modules[45]);
			g_iTimer_Color[client][1][1] = StringToInt(Modules[46]);
			g_iTimer_Color[client][1][2] = StringToInt(Modules[47]);

			//MAPINFO
			g_bMapInfo[client] = StringToInt(Modules[48]) == 1 ? true : false;
			g_fMapInfo_POSX[client] = StringToFloat(Modules[49]);
			g_fMapInfo_POSY[client] = StringToFloat(Modules[50]);

			g_iMapInfo_Color[client][0][0] = StringToInt(Modules[51]);
			g_iMapInfo_Color[client][0][1] = StringToInt(Modules[52]);
			g_iMapInfo_Color[client][0][2] = StringToInt(Modules[53]);

			g_iMapInfo_ShowMode[client] = StringToInt(Modules[54]);
			g_iMapInfo_CompareMode[client] = StringToInt(Modules[55]);

			//FINISH
			g_bFinish[client] = StringToInt(Modules[56]) == 1 ? true : false;
			g_fFinish_POSX[client] = StringToFloat(Modules[57]);
			g_fFinish_POSY[client] = StringToFloat(Modules[58]);

			g_iFinish_Color[client][0][0] = StringToInt(Modules[59]);
			g_iFinish_Color[client][0][1] = StringToInt(Modules[60]);
			g_iFinish_Color[client][0][2] = StringToInt(Modules[61]);

			g_iFinish_Color[client][1][0] = StringToInt(Modules[62]);
			g_iFinish_Color[client][1][1] = StringToInt(Modules[63]);
			g_iFinish_Color[client][1][2] = StringToInt(Modules[64]);

			g_iFinish_Color[client][2][0] = StringToInt(Modules[65]);
			g_iFinish_Color[client][2][1] = StringToInt(Modules[66]);
			g_iFinish_Color[client][2][2] = StringToInt(Modules[67]);

			g_iFinish_HoldTime[client] = StringToInt(Modules[68]);
			g_iFinish_CompareMode[client] = StringToInt(Modules[69]);
			
			CPrintToChat(client, "%t" , "Settings_Imported_All", szPlayerName);

		}
		else {
			CPrintToChat(client, "%t" , "Import_Error");
		}
	}
}
*/