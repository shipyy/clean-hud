public Action surftimer_OnCheckpoint(int client, float fRunTime, char sRunTime[54], float fPbCp, char sPbDiff[16], float fSrCp, char sSrDiff[16], ArrayList CustomCheckpoints)
{
    CP_Display(client, fRunTime, fPbCp, fSrCp, CustomCheckpoints);

    return Plugin_Handled;
}

public Action surftimer_OnBonusFinished(int client, float fRunTime, char sRunTime[54], float fPBDiff, float fSRDiff, int rank, int total, int bonusid, int style)
{
    Finish_Display(client, fRunTime, fPBDiff, fSRDiff, bonusid);

    return Plugin_Handled;
}

public Action surftimer_OnMapFinished(int client, float fRunTime, char sRunTime[54], float PBDiff, float WRDiff, int rank, int total, int style)
{
    Finish_Display(client, fRunTime, PBDiff, WRDiff, 0);

    return Plugin_Handled;
}