/////
//GLOBALS
/////

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
Handle CSD_Handle = null;
Handle Keys_Handle = null;
Handle Sync_Handle = null;
Handle CP_Handle = null;
Handle Timer_Handle = null;
Handle MapInfo_Handle = null;
Handle Finish_Handle = null;

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
int g_iCP_CompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
float g_fLastDifferenceTime[MAXPLAYERS + 1];
char szCPFormatted[MAXPLAYERS + 1][32];

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
