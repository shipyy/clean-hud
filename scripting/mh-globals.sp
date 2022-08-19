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

float g_fTickrate;

int g_iClientTick[MAXPLAYERS + 1];
int g_iCurrentTick[MAXPLAYERS + 1];

//HANDLES
Handle HUD_Handle = null;
Handle Keys_Handle = null;

//CSD
int g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fCSD_POSX[MAXPLAYERS + 1];
float g_fCSD_POSY[MAXPLAYERS + 1];
int g_iCSD_SpeedColor[MAXPLAYERS + 1][3][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iCSD_UpdateRate[MAXPLAYERS + 1];
float g_fLastSpeed[MAXPLAYERS +1];

//KEYS
int g_bKeys[MAXPLAYERS + 1];
float g_fKeys_POSX[MAXPLAYERS + 1];
float g_fKeys_POSY[MAXPLAYERS + 1];
int g_iKeys_Color[MAXPLAYERS + 1][3]; // client | type(gain,loss,maintain) | value(R,G,B)
int g_iKeys_UpdateRate[MAXPLAYERS + 1];
int g_iLastButton[MAXPLAYERS +1];