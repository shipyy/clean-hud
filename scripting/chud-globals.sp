/////
//GLOBALS
/////

//CHAT RESPONSE
enum Response
{
  None,
  ChangeColor,
}

Response WaitingForResponse[MAXPLAYERS + 1];

int g_iColorIndex[MAXPLAYERS + 1];
int g_iColorType[MAXPLAYERS + 1];
int g_iArrayToChange[MAXPLAYERS + 1];

//HANDLES
Handle CSD_Handle;
Handle Keys_Handle;
Handle Sync_Handle;
Handle CP_Handle;
Handle Timer_Handle;
Handle MapInfo_Handle;
Handle Finish_Handle;

/////
//PLAYERS DATA
/////

//CSD
bool g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fCSD_POSX[MAXPLAYERS + 1];
float g_fCSD_POSY[MAXPLAYERS + 1];
int g_iCSD_Color[MAXPLAYERS + 1][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
float g_fLastSpeed[MAXPLAYERS +1];

//KEYS
bool g_bKeys[MAXPLAYERS + 1];
float g_fKeys_POSX[MAXPLAYERS + 1];
float g_fKeys_POSY[MAXPLAYERS + 1];
int g_iKeys_Color[MAXPLAYERS + 1][3];
int g_iLastButton[MAXPLAYERS +1];
int g_imouseDir[MAXPLAYERS + 1][2];

//SYNC
bool g_bSync[MAXPLAYERS + 1];
float g_fSync_POSX[MAXPLAYERS + 1];
float g_fSync_POSY[MAXPLAYERS + 1];
int g_iSync_Color[MAXPLAYERS + 1][3];

//CHECKPOINTS
bool g_bCP[MAXPLAYERS + 1];
float g_fCP_POSX[MAXPLAYERS + 1];
float g_fCP_POSY[MAXPLAYERS + 1];
int g_iCP_Color[MAXPLAYERS + 1][3][3]; // client | type(faster,slower,equal) | value(R,G,B)
int g_iCP_HoldTime[MAXPLAYERS + 1];
int g_iCP_CompareMode[MAXPLAYERS + 1]; // 1 WR | 2 WPB | 2 TOP10 | 4 G1 | 5 G2 | 6 G3 | 7 G4 | 8 G5
float g_fLastDifferenceTime[MAXPLAYERS + 1];
char szCustomFormatted[MAXPLAYERS + 1][32];
float CustomRuntime_Difference[MAXPLAYERS + 1];

//TIMER
bool g_bTimer[MAXPLAYERS + 1];
float g_fTimer_POSX[MAXPLAYERS + 1];
float g_fTimer_POSY[MAXPLAYERS + 1];
int g_iTimer_Color[MAXPLAYERS + 1][2][3]; // client | type(faster,slower) | value(R,G,B)

//MAP INFO
bool g_bMapInfo[MAXPLAYERS + 1];
float g_fMapInfo_POSX[MAXPLAYERS + 1];
float g_fMapInfo_POSY[MAXPLAYERS + 1];
int g_iMapInfo_Color[MAXPLAYERS + 1][3];
int g_iMapInfo_ShowMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
int g_iMapInfo_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR

//FINISH
bool g_bFinish[MAXPLAYERS + 1];
float g_fFinish_POSX[MAXPLAYERS + 1];
float g_fFinish_POSY[MAXPLAYERS + 1];
int g_iFinish_Color[MAXPLAYERS + 1][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iFinish_HoldTime[MAXPLAYERS + 1];
int g_iFinish_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
char szFinishFormatted[MAXPLAYERS + 1][64];
float g_fLastDifferenceFinishTime[MAXPLAYERS + 1];
