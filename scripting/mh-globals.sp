//DATABASE
Handle g_hDb = null;

//CLIENT STEAMID
char g_szSteamID[MAXPLAYERS + 1][32];

//MAIN
Handle HUD_Handle = null;
float g_fTickrate;
int g_SpecTarget[MAXPLAYERS + 1];

//CSD
int g_bCSD[MAXPLAYERS + 1];
int g_iCSD_SpeedAxis[MAXPLAYERS + 1];
float g_fCSD_POSX[MAXPLAYERS + 1];
float g_fCSD_POSY[MAXPLAYERS + 1];
int g_iCSD_SpeedColor[MAXPLAYERS + 1];
int g_iCSD_R[MAXPLAYERS + 1];
int g_iCSD_G[MAXPLAYERS + 1];
int g_iCSD_B[MAXPLAYERS + 1];
int g_iCSD_UpdateRate[MAXPLAYERS + 1];
int g_iClientTick[MAXPLAYERS + 1];
int g_iCurrentTick[MAXPLAYERS + 1];
float g_fLastSpeed[MAXPLAYERS +1];