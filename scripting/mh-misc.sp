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

public int GetUpdateRate(int value)
{
	switch(value){
		case 0: return 15;
		case 1:	return 10;
		case 2: return 5;
		default: return 10;
	}
}

public void LoadCookies(int client)
{
	for(int i = 0; i < 7; i++)
		GetCookie(client, i);
}

public void SaveCookies(int client)
{
	for(int i = 0; i < 7; i++)
		SetCookie(client, i);
}

public void Export(int client)
{
	char szSettingsFinal[1024];

	char szSettingsCSD[128];
	Format(szSettingsCSD, sizeof szSettingsCSD, 
		"%d|%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
		g_bCSD[client] ? 1 : 0, 
		g_iCSD_SpeedAxis[client], 
		g_fCSD_POSX[client], g_fCSD_POSX[client],
		g_iCSD_Color[client][0][0], g_iCSD_Color[client][0][1], g_iCSD_Color[client][0][2],
		g_iCSD_Color[client][1][0], g_iCSD_Color[client][1][1], g_iCSD_Color[client][1][2],
		g_iCSD_Color[client][2][0], g_iCSD_Color[client][2][1], g_iCSD_Color[client][2][2],
		g_iCSD_UpdateRate[client]
	);

	char szSettingsKeys[128];
	Format(szSettingsKeys, sizeof szSettingsKeys, 
		"%d|%.1f|%.1f|%d|%d|%d|%d", //7
		g_bKeys[client] ? 1 : 0, 
		g_fKeys_POSX[client], g_fKeys_POSY[client],
		g_iKeys_Color[client][0][0], g_iKeys_Color[client][0][1], g_iKeys_Color[client][0][2],
		g_iKeys_UpdateRate[client]
	);

	char szSettingsSync[128];
	Format(szSettingsSync, sizeof szSettingsSync, 
		"%d|%.1f|%.1f|%d|%d|%d|%d", //7
		g_bSync[client] ? 1 : 0, 
		g_fSync_POSX[client], g_fSync_POSY[client],
		g_iSync_Color[client][0][0], g_iSync_Color[client][0][1], g_iSync_Color[client][0][2],
		g_iSync_UpdateRate[client]
	);

	char szSettingsCP[128];
	Format(szSettingsCP, sizeof szSettingsCP, 
		"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
		g_bCP[client] ? 1 : 0, 
		g_fCP_POSX[client], g_fCP_POSX[client],
		g_iCP_Color[client][0][0], g_iCP_Color[client][0][1], g_iCP_Color[client][0][2],
		g_iCP_Color[client][1][0], g_iCP_Color[client][1][1], g_iCP_Color[client][1][2],
		g_iCP_Color[client][2][0], g_iCP_Color[client][2][1], g_iCP_Color[client][2][2],
		g_iCP_HoldTime[client],
		g_iCP_CompareMode[client]
	);

	char szSettingsTimer[128];
	Format(szSettingsTimer, sizeof szSettingsTimer, 
		"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d", //10
		g_bTimer[client] ? 1 : 0, 
		g_fTimer_POSX[client], g_fTimer_POSY[client],
		g_iTimer_Color[client][0][0], g_iTimer_Color[client][0][1], g_iTimer_Color[client][0][2],
		g_iTimer_Color[client][1][0], g_iTimer_Color[client][1][1], g_iTimer_Color[client][1][2],
		g_iTimer_UpdateRate[client]
	);

	char szSettingsMapInfo[128];
	Format(szSettingsMapInfo, sizeof szSettingsMapInfo, 
		"%d|%.1f|%.1f|%d|%d|%d|%d|%d", //8
		g_bMapInfo[client] ? 1 : 0, 
		g_fMapInfo_POSX[client], g_fMapInfo_POSY[client],
		g_iMapInfo_Color[client][0][0], g_iMapInfo_Color[client][0][1], g_iMapInfo_Color[client][0][2],
		g_iMapInfo_ShowMode[client],
		g_iMapInfo_CompareMode[client]
	);

	char szSettingsFinish[128];
	Format(szSettingsFinish, sizeof szSettingsFinish, 
		"%d|%.1f|%.1f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //14
		g_bFinish[client] ? 1 : 0, 
		g_fFinish_POSX[client], g_fFinish_POSX[client],
		g_iFinish_Color[client][0][0], g_iFinish_Color[client][0][1], g_iFinish_Color[client][0][2],
		g_iFinish_Color[client][1][0], g_iFinish_Color[client][1][1], g_iFinish_Color[client][1][2],
		g_iFinish_Color[client][2][0], g_iFinish_Color[client][2][1], g_iFinish_Color[client][2][2],
		g_iFinish_HoldTime[client],
		g_iFinish_CompareMode[client]
	);

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, sizeof szName);

	Format(szSettingsFinal, sizeof szSettingsFinal, "%s|%s|%s|%s|%s|%s|%s|%s", szSettingsCSD, szSettingsKeys,szSettingsSync, szSettingsCP, szSettingsTimer, szSettingsMapInfo, szSettingsFinish, szName);

	CPrintToChat(client, "%t", "Settings_Exported");
	PrintToConsole(client, "To import settings use\nsm_mh_import %s", szSettingsFinal);
}

public void Import(int client, char szImportSettings[1024])
{	
	//72 fields
	char Modules[75][8];
	int fields = ExplodeString(szImportSettings, "|", Modules, sizeof Modules, sizeof Modules[]);

	if(fields == 75){
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

		g_iCSD_UpdateRate[client] = StringToInt(Modules[13]);

		//KEYS
		g_bKeys[client] = StringToInt(Modules[14]) == 1 ? true : false;
		g_fKeys_POSX[client] = StringToFloat(Modules[15]);
		g_fKeys_POSY[client] = StringToFloat(Modules[6]);

		g_iKeys_Color[client][0][0] = StringToInt(Modules[17]);
		g_iKeys_Color[client][0][1] = StringToInt(Modules[18]);
		g_iKeys_Color[client][0][2] = StringToInt(Modules[19]);

		g_iKeys_UpdateRate[client] = StringToInt(Modules[20]);

		//SYNC
		g_bSync[client] = StringToInt(Modules[21]) == 1 ? true : false;
		g_fSync_POSX[client] = StringToFloat(Modules[22]);
		g_fSync_POSY[client] = StringToFloat(Modules[23]);

		g_iSync_Color[client][0][0] = StringToInt(Modules[24]);
		g_iSync_Color[client][0][1] = StringToInt(Modules[25]);
		g_iSync_Color[client][0][2] = StringToInt(Modules[26]);

		g_iSync_UpdateRate[client] = StringToInt(Modules[27]);

		//CP
		g_bCP[client] = StringToInt(Modules[28]) == 1 ? true : false;
		g_fCP_POSX[client] = StringToFloat(Modules[29]);
		g_fCP_POSY[client] = StringToFloat(Modules[30]);

		g_iCP_Color[client][0][0] = StringToInt(Modules[31]);
		g_iCP_Color[client][0][1] = StringToInt(Modules[32]);
		g_iCP_Color[client][0][2] = StringToInt(Modules[33]);

		g_iCP_Color[client][1][0] = StringToInt(Modules[34]);
		g_iCP_Color[client][1][1] = StringToInt(Modules[35]);
		g_iCP_Color[client][1][2] = StringToInt(Modules[36]);

		g_iCP_Color[client][2][0] = StringToInt(Modules[37]);
		g_iCP_Color[client][2][1] = StringToInt(Modules[38]);
		g_iCP_Color[client][2][2] = StringToInt(Modules[39]);

		g_iCP_HoldTime[client] = StringToInt(Modules[40]);
		g_iCP_CompareMode[client] = StringToInt(Modules[41]);

		//TIMER
		g_bTimer[client] = StringToInt(Modules[42]) == 1 ? true : false;
		g_fTimer_POSX[client] = StringToFloat(Modules[43]);
		g_fTimer_POSY[client] = StringToFloat(Modules[44]);

		g_iTimer_Color[client][0][0] = StringToInt(Modules[45]);
		g_iTimer_Color[client][0][1] = StringToInt(Modules[46]);
		g_iTimer_Color[client][0][2] = StringToInt(Modules[47]);

		g_iTimer_Color[client][1][0] = StringToInt(Modules[48]);
		g_iTimer_Color[client][1][1] = StringToInt(Modules[49]);
		g_iTimer_Color[client][1][2] = StringToInt(Modules[50]);

		g_iTimer_UpdateRate[client] = StringToInt(Modules[51]);

		//MAPINFO
		g_bMapInfo[client] = StringToInt(Modules[51]) == 1 ? true : false;
		g_fMapInfo_POSX[client] = StringToFloat(Modules[52]);
		g_fMapInfo_POSY[client] = StringToFloat(Modules[53]);

		g_iMapInfo_Color[client][0][0] = StringToInt(Modules[54]);
		g_iMapInfo_Color[client][0][1] = StringToInt(Modules[55]);
		g_iMapInfo_Color[client][0][2] = StringToInt(Modules[56]);

		g_iMapInfo_ShowMode[client] = StringToInt(Modules[57]);
		g_iMapInfo_CompareMode[client] = StringToInt(Modules[58]);

		//FINISH
		g_bFinish[client] = StringToInt(Modules[60]) == 1 ? true : false;
		g_fFinish_POSX[client] = StringToFloat(Modules[61]);
		g_fFinish_POSY[client] = StringToFloat(Modules[62]);

		g_iFinish_Color[client][0][0] = StringToInt(Modules[63]);
		g_iFinish_Color[client][0][1] = StringToInt(Modules[64]);
		g_iFinish_Color[client][0][2] = StringToInt(Modules[65]);

		g_iFinish_Color[client][1][0] = StringToInt(Modules[66]);
		g_iFinish_Color[client][1][1] = StringToInt(Modules[67]);
		g_iFinish_Color[client][1][2] = StringToInt(Modules[68]);

		g_iFinish_Color[client][2][0] = StringToInt(Modules[69]);
		g_iFinish_Color[client][2][1] = StringToInt(Modules[70]);
		g_iFinish_Color[client][2][2] = StringToInt(Modules[71]);

		g_iFinish_HoldTime[client] = StringToInt(Modules[72]);
		g_iFinish_CompareMode[client] = StringToInt(Modules[73]);

		CPrintToChat(client, "%t" , "Settings_Imported", Modules[74]);

	}
	else {
		CPrintToChat(client, "%t" , "Import_Error");
	}
}