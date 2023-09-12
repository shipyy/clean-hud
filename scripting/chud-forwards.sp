public Action surftimer_OnCheckpoint(int client, float fRunTime, char sRunTime[54], float fPbCp, char sPbDiff[16], float fSrCp, char sSrDiff[16], ArrayList CustomCheckpoints)
{
    CP_Format(client, fRunTime, fPbCp, fSrCp, CustomCheckpoints);

    return Plugin_Handled;
}

public Action surftimer_OnBonusFinished(int client, float fRunTime, char sRunTime[54], float fPBDiff, float fSRDiff, int rank, int total, int bonusid, int style)
{
    Finish_Format(client, fRunTime, fPBDiff, fSRDiff, bonusid, false);

    return Plugin_Handled;
}

public Action surftimer_OnMapFinished(int client, float fRunTime, char sRunTime[54], float PBDiff, float WRDiff, int rank, int total, int style)
{
    Finish_Format(client, fRunTime, PBDiff, WRDiff, 0, false);

    return Plugin_Handled;
}

public Action surftimer_OnPracticeFinished(int client, float fRunTime, float fPBDifference, float fWRDifference, int bonusid)
{
    Finish_Format(client, fRunTime, fPBDifference, fWRDifference, bonusid, true);

    return Plugin_Handled;
}

public Action surftimer_OnMapStart(int client, int prestrafe, char pre_PBDiff[128], char pre_SRDiff[128])
{
    PRESTRAFE_Format(client, prestrafe, pre_PBDiff, pre_SRDiff);

    return Plugin_Handled;
}

public Action surftimer_OnStageStart(int client, int prestrafe, char pre_PBDiff[128], char pre_SRDiff[128])
{
    if ( !surftimer_GetTimerStatus(client) )
        PRESTRAFE_Format(client, prestrafe, pre_PBDiff, pre_SRDiff);

    return Plugin_Handled;
}