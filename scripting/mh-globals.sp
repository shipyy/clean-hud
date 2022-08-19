//DATABASE
Handle g_hDb = null;

//CLIENT STEAMID
char g_szSteamID[MAXPLAYERS + 1][32];

//MAIN
ResponseType g_iWaitingForResponse[MAXPLAYERS + 1];
enum ResponseType
{
  None,
  ChangeColor,
}
int g_iColorIndex[MAXPLAYERS + 1];
int g_iColorType[MAXPLAYERS + 1];
int g_iArrayToChange[MAXPLAYERS + 1];

float g_fTickrate;

int g_iClientTick[MAXPLAYERS + 1][6];
int g_iCurrentTick[MAXPLAYERS + 1][6];

//HANDLES
Handle CSD_Handle = null;
Handle Keys_Handle = null;
Handle Sync_Handle = null;
Handle CP_Handle = null;

/*
MAYBE DO THIS INSTEAD
int g_bCSD[MAXPLAYERS + 1][6];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1][6];
float g_fCSD_POSX[MAXPLAYERS + 1][6];
float g_fCSD_POSY[MAXPLAYERS + 1][6];
int g_iCSD_Color[MAXPLAYERS + 1][6][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iCSD_UpdateRate[MAXPLAYERS + 1][6];
float g_fLastSpeed[MAXPLAYERS +1][6];
*/

//CSD
int g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fCSD_POSX[MAXPLAYERS + 1];
float g_fCSD_POSY[MAXPLAYERS + 1];
int g_iCSD_Color[MAXPLAYERS + 1][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iCSD_UpdateRate[MAXPLAYERS + 1];
float g_fLastSpeed[MAXPLAYERS +1];

//KEYS
int g_bKeys[MAXPLAYERS + 1];
float g_fKeys_POSX[MAXPLAYERS + 1];
float g_fKeys_POSY[MAXPLAYERS + 1];
int g_iKeys_Color[MAXPLAYERS + 1][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iKeys_UpdateRate[MAXPLAYERS + 1];
int g_iLastButton[MAXPLAYERS +1];
int g_imouseDir[MAXPLAYERS + 1][2];

//SYNC
int g_bSync[MAXPLAYERS + 1];
float g_fSync_POSX[MAXPLAYERS + 1];
float g_fSync_POSY[MAXPLAYERS + 1];
int g_iSync_Color[MAXPLAYERS + 1][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iSync_UpdateRate[MAXPLAYERS + 1];

//CHECKPOINTS
int g_bCP[MAXPLAYERS + 1];
float g_fCP_POSX[MAXPLAYERS + 1];
float g_fCP_POSY[MAXPLAYERS + 1];
int g_iCP_Color[MAXPLAYERS + 1][3][3]; // client | type(faster,slower,equal) | value(R,G,B)
int g_iCP_HoldTime[MAXPLAYERS + 1];
int g_iCompareMode[MAXPLAYERS + 1]; // 0 PB | 1 WR
