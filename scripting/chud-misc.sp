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

char[] Export(int client, int module, bool just_string, bool from_menu)
{
	char szSettings[256];

	if (module != -1){
		switch (module) {
			case 1 : {
				Format(szSettings, sizeof szSettings, 
					"%d|%.2f|%.2f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //15
					g_bSPEED_MODULE[client] ? 1 : 0, 
					g_fSPEED_MODULE_POSITION[client][0], g_fSPEED_MODULE_POSITION[client][1],
					g_iSPEED_MODULE_COLOR[client][0][0], g_iSPEED_MODULE_COLOR[client][0][1], g_iSPEED_MODULE_COLOR[client][0][2],
					g_iSPEED_MODULE_COLOR[client][1][0], g_iSPEED_MODULE_COLOR[client][1][1], g_iSPEED_MODULE_COLOR[client][1][2],
					g_iSPEED_MODULE_COLOR[client][2][0], g_iSPEED_MODULE_COLOR[client][2][1], g_iSPEED_MODULE_COLOR[client][2][2],
					g_iSPEED_SUBMODULES_INDEXES[client][0],
					g_bCSD[client],
					g_iCSD_SpeedAxis[client]
				);
			}
			case 2: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.2f|%.2f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //21
					g_bTIMER_MODULE[client] ? 1 : 0, 
					g_fTIMER_MODULE_POSITION[client][0], g_fTIMER_MODULE_POSITION[client][1],
					g_iTIMER_MODULE_COLOR[client][0][0], g_iTIMER_MODULE_COLOR[client][0][1], g_iTIMER_MODULE_COLOR[client][0][2],
					g_iTIMER_MODULE_COLOR[client][1][0], g_iTIMER_MODULE_COLOR[client][1][1], g_iTIMER_MODULE_COLOR[client][1][2],
					g_iTIMER_MODULE_COLOR[client][2][0], g_iTIMER_MODULE_COLOR[client][2][1], g_iTIMER_MODULE_COLOR[client][2][2],
					g_iTIMER_SUBMODULES_INDEXES[client][0], g_iTIMER_SUBMODULES_INDEXES[client][1], g_iTIMER_SUBMODULES_INDEXES[client][2],
					g_iTIMER_HOLDTIME[client],
					g_bStopwatch[client],
					g_bCP[client], g_iCP_CompareMode[client],
					g_bFinish[client], g_iFinish_CompareMode[client]
				);
			}
			case 3: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.2f|%.2f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //16
					g_bINPUT_MODULE[client] ? 1 : 0, 
					g_fINPUT_MODULE_POSITION[client][0], g_fINPUT_MODULE_POSITION[client][1],
					g_iINPUT_MODULE_COLOR[client][0][0], g_iINPUT_MODULE_COLOR[client][0][1], g_iINPUT_MODULE_COLOR[client][0][2],
					g_iINPUT_MODULE_COLOR[client][1][0], g_iINPUT_MODULE_COLOR[client][1][1], g_iINPUT_MODULE_COLOR[client][1][2],
					g_iINPUT_MODULE_COLOR[client][2][0], g_iINPUT_MODULE_COLOR[client][2][1], g_iINPUT_MODULE_COLOR[client][2][2],
					g_iINPUT_SUBMODULES_INDEXES[client][0], g_iINPUT_SUBMODULES_INDEXES[client][1],
					g_bKeys[client],
					g_bSync[client]
				);
			}
			case 4: {
				Format(szSettings, sizeof szSettings, 
					"%d|%.2f|%.2f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d", //20
					g_bINFO_MODULE[client] ? 1 : 0, 
					g_fINFO_MODULE_POSITION[client][0], g_fINFO_MODULE_POSITION[client][1],
					g_iINFO_MODULE_COLOR[client][0][0], g_iINFO_MODULE_COLOR[client][0][1], g_iINFO_MODULE_COLOR[client][0][2],
					g_iINFO_MODULE_COLOR[client][1][0], g_iINFO_MODULE_COLOR[client][1][1], g_iINFO_MODULE_COLOR[client][1][2],
					g_iINFO_MODULE_COLOR[client][2][0], g_iINFO_MODULE_COLOR[client][2][1], g_iINFO_MODULE_COLOR[client][2][2],
					g_iINFO_SUBMODULES_INDEXES[client][0], g_iINFO_SUBMODULES_INDEXES[client][1], g_iINFO_SUBMODULES_INDEXES[client][2],
					g_bMapInfo[client], g_iMapInfo_CompareMode[client], g_iMapInfo_ShowMode[client],
					g_bStageInfo[client],
					g_bStageIndicator[client]
				);
			}
			case 7: {
				GetClientName(client, szSettings, sizeof szSettings);
			}
		}

		if (!just_string) {

			if (from_menu) {
				switch (module) {
					case 1 : SPEED_MENU(client);
					case 2 : TIMER_MENU(client);
					case 3 : INPUT_MENU(client);
					case 4 : INFO_MENU(client);
				}
			}

			char szModule[32];
			switch (module) {
				case 1 : Format(szModule, sizeof szModule, "%s", "Speed Module");
				case 2 : Format(szModule, sizeof szModule, "%s", "Timer Module");
				case 3 : Format(szModule, sizeof szModule, "%s", "Input Module");
				case 4 : Format(szModule, sizeof szModule, "%s", "Info Module");
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
	for(int i = 0; i < MODULES_COUNT; i++)
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
			case 1 : {
				if (fields == 15) {
					g_bSPEED_MODULE[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fSPEED_MODULE_POSITION[client][0] = StringToFloat(Modules[1]);
					g_fSPEED_MODULE_POSITION[client][1] = StringToFloat(Modules[2]);

					g_iSPEED_MODULE_COLOR[client][0][0] = StringToInt(Modules[3]);
					g_iSPEED_MODULE_COLOR[client][0][1] = StringToInt(Modules[4]);
					g_iSPEED_MODULE_COLOR[client][0][2] = StringToInt(Modules[5]);

					g_iSPEED_MODULE_COLOR[client][1][0] = StringToInt(Modules[6]);
					g_iSPEED_MODULE_COLOR[client][1][1] = StringToInt(Modules[7]);
					g_iSPEED_MODULE_COLOR[client][1][2] = StringToInt(Modules[8]);

					g_iSPEED_MODULE_COLOR[client][2][0] = StringToInt(Modules[9]);
					g_iSPEED_MODULE_COLOR[client][2][1] = StringToInt(Modules[10]);
					g_iSPEED_MODULE_COLOR[client][2][2] = StringToInt(Modules[11]);

					//1 SUBMODULE
					for(int i = 0; i < SPEED_SUBMODULES; i++)
						g_iSPEED_SUBMODULES_INDEXES[client][i] = StringToInt(Modules[i + 12]);

					g_bCSD[client] = StringToInt(Modules[13]) == 1 ? true : false;
					g_iCSD_SpeedAxis[client] = StringToInt(Modules[14]);


					CPrintToChat(client, "%t" , "Settings_Imported", "SPEED module", szPlayerName);

				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 2 : {
				if (fields == 21) {
					g_bTIMER_MODULE[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fTIMER_MODULE_POSITION[client][0] = StringToFloat(Modules[1]);
					g_fTIMER_MODULE_POSITION[client][1] = StringToFloat(Modules[2]);

					g_iTIMER_MODULE_COLOR[client][0][0] = StringToInt(Modules[3]);
					g_iTIMER_MODULE_COLOR[client][0][1] = StringToInt(Modules[4]);
					g_iTIMER_MODULE_COLOR[client][0][2] = StringToInt(Modules[5]);

					g_iTIMER_MODULE_COLOR[client][1][0] = StringToInt(Modules[6]);
					g_iTIMER_MODULE_COLOR[client][1][1] = StringToInt(Modules[7]);
					g_iTIMER_MODULE_COLOR[client][1][2] = StringToInt(Modules[8]);

					g_iTIMER_MODULE_COLOR[client][2][0] = StringToInt(Modules[9]);
					g_iTIMER_MODULE_COLOR[client][2][1] = StringToInt(Modules[10]);
					g_iTIMER_MODULE_COLOR[client][2][2] = StringToInt(Modules[11]);

					//3 SUBMODULES
					for(int i = 0; i < TIMER_SUBMODULES; i++)
						g_iTIMER_SUBMODULES_INDEXES[client][i] = StringToInt(Modules[i + 12]);

					g_iTIMER_HOLDTIME[client] = StringToInt(Modules[15]);

					g_bStopwatch[client] = StringToInt(Modules[16]) == 1 ? true : false;

					g_bCP[client] = StringToInt(Modules[17]) == 1 ? true : false;
					g_iCP_CompareMode[client] = StringToInt(Modules[18]);

					g_bFinish[client] = StringToInt(Modules[19]) == 1 ? true : false;
					g_iFinish_CompareMode[client] = StringToInt(Modules[20]);

					CPrintToChat(client, "%t" , "Settings_Imported", "TIMER module", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 3 : {
				if (fields == 16) {
					g_bINPUT_MODULE[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fINPUT_MODULE_POSITION[client][0] = StringToFloat(Modules[1]);
					g_fINPUT_MODULE_POSITION[client][1] = StringToFloat(Modules[2]);

					g_iINPUT_MODULE_COLOR[client][0][0] = StringToInt(Modules[3]);
					g_iINPUT_MODULE_COLOR[client][0][1] = StringToInt(Modules[4]);
					g_iINPUT_MODULE_COLOR[client][0][2] = StringToInt(Modules[5]);

					g_iINPUT_MODULE_COLOR[client][1][0] = StringToInt(Modules[6]);
					g_iINPUT_MODULE_COLOR[client][1][1] = StringToInt(Modules[7]);
					g_iINPUT_MODULE_COLOR[client][1][2] = StringToInt(Modules[8]);

					g_iINPUT_MODULE_COLOR[client][2][0] = StringToInt(Modules[9]);
					g_iINPUT_MODULE_COLOR[client][2][1] = StringToInt(Modules[10]);
					g_iINPUT_MODULE_COLOR[client][2][2] = StringToInt(Modules[11]);

					//3 SUBMODULES
					for(int i = 0; i < INPUT_SUBMODULES; i++)
						g_iINPUT_SUBMODULES_INDEXES[client][i] = StringToInt(Modules[i + 12]);

					g_bStopwatch[client] = StringToInt(Modules[14]) == 1 ? true : false;

					g_bFinish[client] = StringToInt(Modules[15]) == 1 ? true : false;

					CPrintToChat(client, "%t" , "Settings_Imported", "INPUT module", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
			case 4 : {
				if (fields == 20) {
					g_bINFO_MODULE[client] = StringToInt(Modules[0]) == 1 ? true : false;
					g_fINFO_MODULE_POSITION[client][0] = StringToFloat(Modules[1]);
					g_fINFO_MODULE_POSITION[client][1] = StringToFloat(Modules[2]);

					g_iINFO_MODULE_COLOR[client][0][0] = StringToInt(Modules[3]);
					g_iINFO_MODULE_COLOR[client][0][1] = StringToInt(Modules[4]);
					g_iINFO_MODULE_COLOR[client][0][2] = StringToInt(Modules[5]);

					g_iINFO_MODULE_COLOR[client][1][0] = StringToInt(Modules[6]);
					g_iINFO_MODULE_COLOR[client][1][1] = StringToInt(Modules[7]);
					g_iINFO_MODULE_COLOR[client][1][2] = StringToInt(Modules[8]);

					g_iINFO_MODULE_COLOR[client][2][0] = StringToInt(Modules[9]);
					g_iINFO_MODULE_COLOR[client][2][1] = StringToInt(Modules[10]);
					g_iINFO_MODULE_COLOR[client][2][2] = StringToInt(Modules[11]);

					//3 SUBMODULES
					for(int i = 0; i < INFO_SUBMODULES; i++)
						g_iINFO_SUBMODULES_INDEXES[client][i] = StringToInt(Modules[i + 12]);

					g_bMapInfo[client] = StringToInt(Modules[15]) == 1 ? true : false;
					g_iMapInfo_CompareMode[client] = StringToInt(Modules[16]);
					g_iMapInfo_ShowMode[client] = StringToInt(Modules[17]);

					g_bStageInfo[client] = StringToInt(Modules[18]) == 1 ? true : false;

					g_bStageIndicator[client] = StringToInt(Modules[19]) == 1 ? true : false;

					CPrintToChat(client, "%t" , "Settings_Imported", "INFO module", szPlayerName);
				}
				else {
					CPrintToChat(client, "%t" , "Import_Error");
				}
			}
		}
	}
}

public void SaveModule(int client, int module_index)
{
	switch (module_index) {
		case 1: db_SET_SPEED(client);
		case 2: db_SET_TIMER(client);
		case 3: db_SET_INPUT(client);
		case 4: db_SET_INFO(client);
	}
}

public void SaveSubModule(int client, int module, int submodule)
{
	switch (module) {
		case 1 : {
			switch (submodule) {
				case 1 : db_SET_CSD(client, module, submodule);
			}
		}
		case 2 : {
			switch (submodule) {
				case 1 : db_SET_STOPWATCH(client, module, submodule);
				case 2 : db_SET_CP(client, module, submodule);
				case 3 : db_SET_FINISH(client, module, submodule);
			}
		}
		case 3 : {
			switch (submodule) {
				case 1 : db_SET_KEYS(client, module, submodule);
				case 2 : db_SET_SYNC(client, module, submodule);
			}
		}
		case 4 : {
			switch (submodule) {
				case 1 : db_SET_MAPINFO(client, module, submodule);
				case 2 : db_SET_STAGEINFO(client, module, submodule);
				case 3 : db_SET_STAGEINDICATOR(client, module, submodule);
			}
		}
	}
}

public void LoadModule(int client, int module_index)
{
	switch (module_index) {
		case 1: db_LoadSPEED(client);
		case 2: db_LoadTIMER(client);
		case 3: db_LoadINPUT(client);
		case 4: db_LoadINFO(client);
	}
}

public void LoadSubModule(int client, int module, int submodule)
{
	switch (module) {
		case 1 : {
			switch (submodule) {
				case 1 : db_GET_CSD(client, module, submodule);
			}
		}
		case 2 : {
			switch (submodule) {
				case 1 : db_GET_STOPWATCH(client, module, submodule);
				case 2 : db_GET_CP(client, module, submodule);
				case 3 : db_GET_FINISH(client, module, submodule);
			}
		}
		case 3 : {
			switch (submodule) {
				case 1 : db_GET_KEYS(client, module, submodule);
				case 2 : db_GET_SYNC(client, module, submodule);
			}
		}
		case 4 : {
			switch (submodule) {
				case 1 : db_GET_MAPINFO(client, module, submodule);
				case 2 : db_GET_STAGEINFO(client, module, submodule);
				case 3 : db_GET_STAGEINDICATOR(client, module, submodule);
			}
		}
	}
}

public int getSubModuleID(int client, int module, int submodule)
{
	switch (module) {
		case 1 : {
			switch (submodule) {
				case 0 : return 0;
				case 1 : return CSD_ID;
			}
		}
		case 2 : {
			switch (submodule) {
				case 0 : return 0;
				case 1 : return STOPWATCH_ID;
				case 2 : return CHECKPOINTS_ID;
				case 3 : return FINISH_ID;
			}
		}
		case 3 : {
			switch (submodule) {
				case 0 : return 0;
				case 1 : return KEYS_ID;
				case 2 : return SYNC_ID;
			}
		}
		case 4 : {
			switch (submodule) {
				case 0 : return 0;
				case 1 : return MAPINFO_ID;
				case 2 : return STAGEINFO_ID;
				case 3 : return STAGEINDICATOR_ID;
			}
		}
		default: return 0;
	}

	return -1;
}

public void SetClientDefults(int client)
{
	g_iColorIndex[client] = 0;
	g_iColorType[client] = 0;
	g_iArrayToChange[client] = 0;

	g_iClientTick[client] = 0;
	g_iCurrentTick[client] = g_iClientTick[client];
	g_iRefreshRate[client] = 1;

	for(int i = 0; i < 4; i++)
		g_bEditing[client][i] = false;
	
	for(int i = 0; i < 3; i++)
		g_bEditingColor[client][i] = false;

	//SPEED MODULE
	for(int i = 0; i < SPEED_SUBMODULES; i++)
	{
		g_szSPEED_SUBMODULE_INDEXES_STRINGS[client][i] = "";
		g_iSPEED_SUBMODULES_INDEXES[client][i] = 0;
	}
	g_szSPEED_MODULE[client] = "";

	//TIMER MODULE
	for(int i = 0; i < TIMER_SUBMODULES; i++)
	{
		g_szTIMER_SUBMODULE_INDEXES_STRINGS[client][i] = "";
		g_iTIMER_SUBMODULES_INDEXES[client][i] = 0;
	}
	g_szTIMER_MODULE[client] = "";

	//INPUT MODULE
	for(int i = 0; i < INPUT_SUBMODULES; i++)
	{
		g_szINPUT_SUBMODULE_INDEXES_STRINGS[client][i] = "";
		g_iINPUT_SUBMODULES_INDEXES[client][i] = 0;
	}
	g_szINPUT_MODULE[client] = "";

	//INFO MODULE
	for(int i = 0; i < INFO_SUBMODULES; i++)
	{
		g_szINFO_SUBMODULE_INDEXES_STRINGS[client][i] = "";
		g_iINFO_SUBMODULES_INDEXES[client][i] = 0;
	}
	g_szINFO_MODULE[client] = "";

	/////
	//SUB MODULES
	/////

			//===SPEED MODULE===
	
	//CSD
	g_szCSD_SUBMODULE[client] = "";
	g_fLastSpeed[client] = 0.0;

			//===TIMER MODULE===
	
	//CHECKPOINTS
	g_szCP_SUBMODULE[client] = "";
	g_fLastDifferenceTime[client] = 0.0;

	//TIMER
	g_szSTOPWATCH_SUBMODULE[client] = "";

	//FINISH
	g_szFINISH_SUBMODULE[client] = "";
	g_fLastDifferenceFinishTime[client] = 0.0;

			//===INPUT MODULE===
	
	//KEYS
	g_szKEYS_SUBMODULE[client] = "";
	g_iLastButton[client] = 0;
	for(int i = 0; i < 2; i++)
		g_imouseDir[client][i] = 0;

	//SYNC
	g_szSYNC_SUBMODULE[client] = "";
	g_fLastSync[client] = 0.0;

			//===INFO MODULE===
	
	//MAP INFO
	g_szMAPINFO_SUBMODULE[client] = "";

	//STAGE INFO
	g_szSTAGEINFO_SUBMODULE[client] = "";

	//STAGE INDICATOR
	g_szSTAGEINDICATOR_SUBMODULE[client] = "";
}