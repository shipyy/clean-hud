/////
//DATABASE INIT
/////

public void db_setupDatabase()
{
	char szError[255];
	g_hDb = SQL_Connect("minimalhud", false, szError, 255);

	if (g_hDb == null)
		SetFailState("[Minimal HUD] Unable to connect to database (%s)", szError);

	char szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);

	if (strcmp(szIdent, "mysql", false) != 0) {
		SetFailState("[Minimal HUD] Invalid database type");
	}

	// If tables haven't been created yet.
	SQL_LockDatabase(g_hDb);
	if (!SQL_FastQuery(g_hDb, "SELECT enabled FROM mh_CSD LIMIT 1"))
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

	SQL_AddQuery(createTableTnx, sql_CreateCSD);
	SQL_AddQuery(createTableTnx, sql_CreateKeys);
	SQL_AddQuery(createTableTnx, sql_CreateSync);

	SQL_ExecuteTransaction(g_hDb, createTableTnx, SQLTxn_CreateDatabaseSuccess, SQLTxn_CreateDatabaseFailed);

}

public void SQLTxn_CreateDatabaseSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("[Minimal HUD] Database tables succesfully created!");
}

public void SQLTxn_CreateDatabaseFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("[Minimal HUD] Database tables could not be created! Error: %s", error);
}

public void SQL_CheckCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Minimal HUD] SQL Error (SQL_CheckCallback): %s", error);
		return;
	}
}