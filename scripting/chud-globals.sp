/////
//DEFINES
/////
#define CURRENT_MODULE 1

#define MODULES_COUNT 4

#define SPEED_SUBMODULES 1
int g_SPEED_SUBMODULES = 1;
#define CSD_ID 1
char g_szSPEED_SUBMODULE_NAME[][] =
{
	"None",
	"CSD"
};

#define TIMER_SUBMODULES 3
int g_TIMER_SUBMODULES = 3;
#define STOPWATCH_ID 1
#define CHECKPOINTS_ID 2
#define FINISH_ID 3
char g_szTIMER_SUBMODULE_NAME[][] =
{
	"None",
	"Stopwatch",
	"Checkpoints",
	"Finish"
};

#define INPUT_SUBMODULES 2
int g_INPUT_SUBMODULES = 2;
#define KEYS_ID 1
#define SYNC_ID 2
char g_szINPUT_SUBMODULE_NAME[][] =
{
	"None",
	"Keys",
	"Sync"
};

#define INFO_SUBMODULES 3
int g_INFO_SUBMODULES = 3;
#define MAPINFO_ID 1
#define STAGEINFO_ID 2
#define STAGEINDICATOR_ID 3
char g_szINFO_SUBMODULE_NAME[][] =
{
	"None",
	"Map Info",
	"Stage Info",
	"Stage Indicator"
};

/////
//GLOBALS
/////

//DATABASE
Handle g_hDb = null;

//CHAT RESPONSE
ResponseType g_iWaitingForResponse[MAXPLAYERS + 1];
enum ResponseType
{
  None,
  ChangeColor,
}

int g_iColorIndex[MAXPLAYERS + 1];
int g_iColorType[MAXPLAYERS + 1];
int g_iArrayToChange[MAXPLAYERS + 1];

int g_iRefreshRate[MAXPLAYERS + 1];
int g_iRefreshRateValue[MAXPLAYERS + 1];
int g_iClientTick[MAXPLAYERS + 1];
int g_iCurrentTick[MAXPLAYERS + 1];
float g_fTickrate;

char g_szSteamID[MAXPLAYERS + 1][32];

//EEDITING
/*
0 - CSD
1 - KEYS
2 - SYNC
3 - CP
4 - TIMER
5 - MAPINFO
6 - FINISH
*/
bool g_bEditing[MAXPLAYERS + 1][4];
bool g_bEditingColor[MAXPLAYERS + 1][3];

//HANDLES
Handle Handle_SPEED_MODULE = null;
Handle Handle_TIMER_MODULE = null;
Handle Handle_INPUT_MODULE = null;
Handle Handle_INFO_MODULE = null;

/////
//PLAYERS DATA
/////

//MODULES STRINGS
//THERE IS A MODULE LIMIT OF 6
//EACH STRING CONTAINS THE SUBMODULES STRINGS VALUES

//MODULES
// 1 -> SPEED MODULE - CSD
// 2 -> TIME MODULE - TIMER | CHECKPOINTS | FINISH MESSAGES
// 3 -> INPUT MODULE - KEYS | SYNC
// 4 -> INFO MODULE - MAP/BONUS WR/PB COMPARISONS | STAGE INCDICATOR | WRCP WITH WR NAME AND COMPARISONS

//SPEED MODULE
bool g_bSPEED_MODULE[MAXPLAYERS + 1];
float g_fSPEED_MODULE_POSITION[MAXPLAYERS + 1][2];
int g_iSPEED_MODULE_COLOR[MAXPLAYERS + 1][3][3];

char g_szSPEED_SUBMODULE_INDEXES_STRINGS[MAXPLAYERS + 1][SPEED_SUBMODULES][32]; // EXAMPLE -- { "1|2|1" } -- this means that this module string would be composed of its 1st sub-module follow byt the 2nd and again 1st module again
int g_iSPEED_SUBMODULES_INDEXES[MAXPLAYERS + 1][SPEED_SUBMODULES];
char g_szSPEED_MODULE[MAXPLAYERS + 1][512];

//TIMER MODULE
bool g_bTIMER_MODULE[MAXPLAYERS + 1];
float g_fTIMER_MODULE_POSITION[MAXPLAYERS + 1][2];
int g_iTIMER_MODULE_COLOR[MAXPLAYERS + 1][3][3];
int g_iTIMER_HOLDTIME[MAXPLAYERS + 1];

char g_szTIMER_SUBMODULE_INDEXES_STRINGS[MAXPLAYERS + 1][TIMER_SUBMODULES][128];
int g_iTIMER_SUBMODULES_INDEXES[MAXPLAYERS + 1][TIMER_SUBMODULES];
char g_szTIMER_MODULE[MAXPLAYERS + 1][512];

//INPUT MODULE
bool g_bINPUT_MODULE[MAXPLAYERS + 1];
float g_fINPUT_MODULE_POSITION[MAXPLAYERS + 1][2];
int g_iINPUT_MODULE_COLOR[MAXPLAYERS + 1][3][3];

char g_szINPUT_SUBMODULE_INDEXES_STRINGS[MAXPLAYERS + 1][INPUT_SUBMODULES][128];
int g_iINPUT_SUBMODULES_INDEXES[MAXPLAYERS + 1][INPUT_SUBMODULES];
char g_szINPUT_MODULE[MAXPLAYERS + 1][512];

//INFO MODULE
bool g_bINFO_MODULE[MAXPLAYERS + 1];
float g_fINFO_MODULE_POSITION[MAXPLAYERS + 1][2];
int g_iINFO_MODULE_COLOR[MAXPLAYERS + 1][3];

char g_szINFO_SUBMODULE_INDEXES_STRINGS[MAXPLAYERS + 1][INFO_SUBMODULES][128];
int g_iINFO_SUBMODULES_INDEXES[MAXPLAYERS + 1][INFO_SUBMODULES];
char g_szINFO_MODULE[MAXPLAYERS + 1][512];

/////
//SUB MODULES
/////

//===SPEED MODULE===
//CSD
char g_szCSD_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fLastSpeed[MAXPLAYERS +1];

//===TIMER MODULE===
//CHECKPOINTS
char g_szCP_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bCP[MAXPLAYERS + 1];
float g_fLastDifferenceTime[MAXPLAYERS + 1];
int g_iCP_CompareMode[MAXPLAYERS + 1];

//TIMER
char g_szSTOPWATCH_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bStopwatch[MAXPLAYERS + 1];

//FINISH
char g_szFINISH_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bFinish[MAXPLAYERS + 1];
float g_fLastDifferenceFinishTime[MAXPLAYERS + 1];
int g_iFinish_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR

//===INPUT MODULE===
//KEYS
char g_szKEYS_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bKeys[MAXPLAYERS + 1];
int g_iLastButton[MAXPLAYERS +1];
int g_imouseDir[MAXPLAYERS + 1][2];

//SYNC
char g_szSYNC_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bSync[MAXPLAYERS + 1];

//===INFO MODULE===
//MAP INFO
char g_szMAPINFO_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bMapInfo[MAXPLAYERS + 1];
int g_iMapInfo_ShowMode[MAXPLAYERS + 1]; // 2 PB | 1 WR
int g_iMapInfo_CompareMode[MAXPLAYERS + 1]; // 2 PB | 1 WR

//STAGE INFO
char g_szSTAGEINFO_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bStageInfo[MAXPLAYERS + 1];

//STAGE INDICATOR
char g_szSTAGEINDICATOR_SUBMODULE[MAXPLAYERS + 1][128];

bool g_bStageIndicator[MAXPLAYERS + 1];
