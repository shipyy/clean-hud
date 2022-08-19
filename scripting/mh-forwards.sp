public  Action surftimer_OnCheckpoint(int client, float fRunTime, char sRunTime[54], float fPbCp, char sPbDiff[16], float fSrCp, char sSrDiff[16])
{
    CP_Display(client, fRunTime, fPbCp, fSrCp);

    return Plugin_Handled;
}