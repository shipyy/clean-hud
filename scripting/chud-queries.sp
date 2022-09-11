//SPEED
char sql_Create_mod_SPEED[] = "CREATE TABLE IF NOT EXISTS chud_SPEED (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', pos VARCHAR(32) NOT NULL DEFAULT '0.5|0.5', gaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', losscolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', maintaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', FormatOrderbyID VARCHAR(64) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_CSD[] = "CREATE TABLE IF NOT EXISTS chud_sub_CSD (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', speedaxis INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";

//TIMER
char sql_Create_mod_TIMER[] = "CREATE TABLE IF NOT EXISTS chud_TIMER (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', pos VARCHAR(32) NOT NULL DEFAULT '0.5|0.5', gaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', losscolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', maintaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', FormatOrderbyID VARCHAR(64) NOT NULL DEFAULT '0|0|0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_Stopwatch[] = "CREATE TABLE IF NOT EXISTS chud_sub_stopwatch (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_Checkpoints[] = "CREATE TABLE IF NOT EXISTS chud_sub_checkpoints (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', comparetype INT(12) NOT NULL DEFAULT '1', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_Finish[] = "CREATE TABLE IF NOT EXISTS chud_sub_finish (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', comparetype INT(12) NOT NULL DEFAULT '1', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";

//INPUT
char sql_Create_mod_INPUT[] = "CREATE TABLE IF NOT EXISTS chud_INPUT (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', pos VARCHAR(32) NOT NULL DEFAULT '0.5|0.5', gaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', losscolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', maintaincolor VARCHAR(32) NOT NULL DEFAULT '255|255|255', FormatOrderbyID VARCHAR(64) NOT NULL DEFAULT '0|0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_Keys[] = "CREATE TABLE IF NOT EXISTS chud_sub_keys (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_Sync[] = "CREATE TABLE IF NOT EXISTS chud_sub_sync (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";

//INFO
char sql_Create_mod_INFO[] = "CREATE TABLE IF NOT EXISTS chud_INFO (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', pos VARCHAR(32) NOT NULL DEFAULT '0.5|0.5', color VARCHAR(32) NOT NULL DEFAULT '255|255|255', FormatOrderbyID VARCHAR(64) NOT NULL DEFAULT '0|0|0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_mapinfo[] = "CREATE TABLE IF NOT EXISTS chud_sub_mapinfo (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', showmode INT(12) NOT NULL DEFAULT '2', comparemode INT(12) NOT NULL DEFAULT '1', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_stageinfo[] = "CREATE TABLE IF NOT EXISTS chud_sub_stageinfo (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";
char sql_Create_sub_stageindicator[] = "CREATE TABLE IF NOT EXISTS chud_sub_stageindicator (steamid VARCHAR(32) NOT NULL, enabled INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(steamid)) DEFAULT CHARSET=utf8mb4;";