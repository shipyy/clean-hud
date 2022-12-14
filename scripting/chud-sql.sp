/////
//DATABASE INIT
/////

public void db_setupDatabase()
{
	char szError[255];
	g_hDb = SQL_Connect("cleanhud", false, szError, 255);

	if (g_hDb == null)
		SetFailState("[Clean HUD] Unable to connect to database (%s)", szError);

	char szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);

	if (strcmp(szIdent, "mysql", false) != 0) {
		SetFailState("[Clean HUD] Invalid database type");
	}

	// If tables haven't been created yet.
	SQL_LockDatabase(g_hDb);
	if (!SQL_FastQuery(g_hDb, "SELECT enabled FROM chud_SPEED LIMIT 1"))
	{
		SQL_UnlockDatabase(g_hDb);
		db_createTables();
		return;
	}

	SQL_UnlockDatabase(g_hDb);

}

public void db_createTables()
{
	Transaction createTableTnx = SQL_CreateTransaction();

	SQL_AddQuery(createTableTnx, sql_Create_OPTIONS);
	SQL_AddQuery(createTableTnx, sql_Create_mod_SPEED);
	SQL_AddQuery(createTableTnx, sql_Create_sub_CSD);
	SQL_AddQuery(createTableTnx, sql_Create_mod_TIMER);
	SQL_AddQuery(createTableTnx, sql_Create_sub_Stopwatch);
	SQL_AddQuery(createTableTnx, sql_Create_sub_Checkpoints);
	SQL_AddQuery(createTableTnx, sql_Create_sub_Finish);
	SQL_AddQuery(createTableTnx, sql_Create_mod_INPUT);
	SQL_AddQuery(createTableTnx, sql_Create_sub_Keys);
	SQL_AddQuery(createTableTnx, sql_Create_sub_Sync);
	SQL_AddQuery(createTableTnx, sql_Create_mod_INFO);
	SQL_AddQuery(createTableTnx, sql_Create_sub_mapinfo);
	SQL_AddQuery(createTableTnx, sql_Create_sub_stageinfo);
	SQL_AddQuery(createTableTnx, sql_Create_sub_stageindicator);

	SQL_ExecuteTransaction(g_hDb, createTableTnx, SQLTxn_CreateDatabaseSuccess, SQLTxn_CreateDatabaseFailed);

}

public void SQLTxn_CreateDatabaseSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("[Clean HUD] Database tables succesfully created!");
}

public void SQLTxn_CreateDatabaseFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("[Clean HUD] Database tables could not be created! Error: %s", error);
}

public void SQL_CheckCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Clean HUD] SQL Error (SQL_CheckCallback): %s", error);
		return;
	}
}