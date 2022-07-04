#if defined _du_serverboosterole_included
 #endinput
#endif
#define _du_serverboosterole_included

/**
 * Called after a client's data has been retrieved from database. 
 *
 * @param client        		Client index loaded client.
 * @noreturn
 */
forward void DU_ServerBoosterRole_OnClientLoaded(int client, bool bIsServerBooster);

/**
 * Discord Database Check
 *
 * @returns true if client was already checked for member status.
 */
native bool DU_ServerBoosterRole_IsLoaded(int client);

/**
 * Discord Member Check
 *
 * @returns true if client is member of discord server else false.
 */
native bool DU_ServerBoosterRole_IsServerBooster(int client);

public SharedPlugin __pl_du_serverboosterole =
{
		name = "du_serverboosterole",
		file = "du_serverboosterole.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_du_serverboosterole_SetNTVOptional()
{
	MarkNativeAsOptional("DU_ServerBoosterRole_IsLoaded");
	MarkNativeAsOptional("DU_ServerBoosterRole_IsServerBooster");
}
#endif 
