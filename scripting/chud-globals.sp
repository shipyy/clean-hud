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
	"CSD"
};

/*
#define TIMER_SUBMODULES 3
#define Stopwatch_ID 1
#define Checkpoints_ID 2
#define Finish_ID 3
char g_szTIMER_SUBMODULE_NAME[][] =
{
	"Stopwatch",
	"Checkpoints",
	"Finish"
};

#define INPUT_SUBMODULES 2
#define Keys_ID 1
#define Sync_ID 2
char g_szINPUT_SUBMODULE_NAME[][] =
{
	"Keys",
	"Sync"
};

#define INFO_SUBMODULES 1
#define MapInfo_ID 1
char g_szINFO_SUBMODULE_NAME[][] =
{
	"MapInfo"
};
*/

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
bool g_bEditing[MAXPLAYERS + 1][7];
bool g_bEditingColor[MAXPLAYERS + 1][3];

//HANDLES
Handle Handle_SPEED_MODULE = null;
//Handle Handle_TIMER_MODULE = null;
//Handle Handle_INPUT_MODULE = null;
//Handle Handle_INFO_MODULE = null;

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

bool g_bSPEED_MODULE[MAXPLAYERS + 1];
float g_fSPEED_MODULE_POSITION[MAXPLAYERS + 1][2];
int g_iSPEED_MODULE_COLOR[MAXPLAYERS + 1][3][3];
char g_szSPEED_SUBMODULE_INDEXES_STRINGS[MAXPLAYERS + 1][SPEED_SUBMODULES][32]; // EXAMPLE -- { "1|2|1" } -- this means that this module string would be composed of its 1st sub-module follow byt the 2nd and again 1st module again
int g_iSPEED_SUBMODULES_INDEXES[MAXPLAYERS + 1][SPEED_SUBMODULES];

char g_szSPEED_MODULE[MAXPLAYERS + 1][512];

/*
char g_szTIME_MODULE[MAXPLAYERS + 1][512];
bool g_bTIME_MODULE[MAXPLAYERS + 1];
char g_szTIME_SUBMODULE_INDEXES[MAXPLAYERS + 1][3];

char g_szINPUT_MODULE[MAXPLAYERS + 1][512];
bool g_bINPUT_MODULE[MAXPLAYERS + 1];
char g_szINPUT_SUBMODULE_INDEXES[MAXPLAYERS + 1][2];

char g_szINFO_MODULE[MAXPLAYERS + 1][512];
bool g_bINFO_MODULE[MAXPLAYERS + 1];
char g_szINFO_SUBMODULE_INDEXES[MAXPLAYERS + 1][3];
*/

/////
//SUB MODULES
/////

//CSD
char g_szCSD_SUBMODULE[MAXPLAYERS + 1];
int g_CSD_SUBMODULE_INDEX[MAXPLAYERS + 1];

bool g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fLastSpeed[MAXPLAYERS +1];

//KEYS
char g_szKEYS_SUBMODULE[MAXPLAYERS + 1];
bool g_bKeys[MAXPLAYERS + 1];
float g_fKeys_POSX[MAXPLAYERS + 1];
float g_fKeys_POSY[MAXPLAYERS + 1];
int g_iKeys_Color[MAXPLAYERS + 1][3];
int g_iLastButton[MAXPLAYERS +1];
int g_imouseDir[MAXPLAYERS + 1][2];

//SYNC
char g_szSYNC_SUBMODULE[MAXPLAYERS + 1];
bool g_bSync[MAXPLAYERS + 1];
float g_fSync_POSX[MAXPLAYERS + 1];
float g_fSync_POSY[MAXPLAYERS + 1];
int g_iSync_Color[MAXPLAYERS + 1][3];

//CHECKPOINTS
char g_szCP_SUBMODULE[MAXPLAYERS + 1];
bool g_bCP[MAXPLAYERS + 1];
float g_fCP_POSX[MAXPLAYERS + 1];
float g_fCP_POSY[MAXPLAYERS + 1];
int g_iCP_Color[MAXPLAYERS + 1][3][3]; // client | type(faster,slower,equal) | value(R,G,B)
int g_iCP_HoldTime[MAXPLAYERS + 1];
int g_iCP_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
float g_fLastDifferenceTime[MAXPLAYERS + 1];
char szCPFormatted[MAXPLAYERS + 1][32];

//TIMER
char g_szTIMER_SUBMODULE[MAXPLAYERS + 1];
bool g_bTimer[MAXPLAYERS + 1];
float g_fTimer_POSX[MAXPLAYERS + 1];
float g_fTimer_POSY[MAXPLAYERS + 1];
int g_iTimer_Color[MAXPLAYERS + 1][2][3]; // client | type(faster,slower) | value(R,G,B)

//MAP INFO
char g_szMAPINFO_SUBMODULE[MAXPLAYERS + 1];
bool g_bMapInfo[MAXPLAYERS + 1];
float g_fMapInfo_POSX[MAXPLAYERS + 1];
float g_fMapInfo_POSY[MAXPLAYERS + 1];
int g_iMapInfo_Color[MAXPLAYERS + 1][3];
int g_iMapInfo_ShowMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
int g_iMapInfo_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR

//FINISH
char g_szFINISH_SUBMODULE[MAXPLAYERS + 1];
bool g_bFinish[MAXPLAYERS + 1];
float g_fFinish_POSX[MAXPLAYERS + 1];
float g_fFinish_POSY[MAXPLAYERS + 1];
int g_iFinish_Color[MAXPLAYERS + 1][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iFinish_HoldTime[MAXPLAYERS + 1];
int g_iFinish_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
char szFinishFormatted[MAXPLAYERS + 1][64];
float g_fLastDifferenceFinishTime[MAXPLAYERS + 1];