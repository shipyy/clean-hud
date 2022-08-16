stock bool IsValidClient(int client)
{   
    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        return true;
    return false;
}

public float GetSpeed(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	float speed;

	if (g_iCSD_SpeedAxis[client] == 0) // XY
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	else if (g_iCSD_SpeedAxis[client] == 1) // XYZ
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	else if (g_iCSD_SpeedAxis[client] == 2) // Z
		speed = fVelocity[2];
	else // XY default
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));

	return speed;
}