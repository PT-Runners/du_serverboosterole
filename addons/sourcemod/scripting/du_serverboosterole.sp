#include <sourcemod>
#include <discord_utilities>
#include <du_serverboosterole>

//#define DEBUG

ConVar cv_sDiscordRoleId;

Handle g_fClientLoaded;

bool g_bLoaded[MAXPLAYERS + 1] = {false, ...};
bool g_bIsServerBooster[MAXPLAYERS + 1] = {false, ...};

char g_sRoleId[60];

public Plugin myinfo = 
{
	name = "Discord Utilities: Discord Server Booster Role Core",
	author = "Trayz",
	description = "Core Plugin to Manage Discord Server Booster Players",
	version = "1.0",
	url = "ptrunners.net"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("du_serverboosterole");

	//Create natives
	CreateNative("DU_ServerBoosterRole_IsLoaded", Native_IsLoaded);
	CreateNative("DU_ServerBoosterRole_IsServerBooster", Native_IsServerBooster);

	//Create forwards
	g_fClientLoaded = new GlobalForward("DU_ServerBoosterRole_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);

	return APLRes_Success;
}

public int Native_IsLoaded(Handle myplugin, int argc)
{
	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}

	if (!IsClientConnected(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}

	return !!g_bLoaded[client];
}

public int Native_IsServerBooster(Handle myplugin, int argc)
{
	int client = GetNativeCell(1);

	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}

	if (!IsClientConnected(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	}

	if (!g_bLoaded[client])
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d not loaded", client);
	}

	return !!g_bIsServerBooster[client];
}

public void OnPluginStart()
{
	cv_sDiscordRoleId = CreateConVar("sm_du_serverboosterole_id", "921949096967827516", "Role ID Discord.");
	cv_sDiscordRoleId.GetString(g_sRoleId, sizeof(g_sRoleId));
	cv_sDiscordRoleId.AddChangeHook(OnConVarChanged);

	AutoExecConfig(true);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cv_sDiscordRoleId)
		cv_sDiscordRoleId.GetString(g_sRoleId, sizeof(g_sRoleId));
}

public void OnClientPostAdminCheck(int client)
{
	if(!client) return;

	g_bLoaded[client] = false;
	g_bIsServerBooster[client] = false;
}

public void DU_OnClientLoaded(int client)
{
	if(!DU_IsChecked(client))
	{
		return;
	}

	if(!DU_IsMember(client))
	{
		return;
	}

	DU_CheckRole(client, g_sRoleId, OnFetchedRoleId);
}

public void OnFetchedRoleId(int client, bool found, any data)
{
	if(!client) return;

	if(!IsValidClient(client)) return;

	g_bLoaded[client] = true;
	g_bIsServerBooster[client] = found;

	Call_StartForward(g_fClientLoaded);
	Call_PushCell(client);
	Call_PushCell(g_bIsServerBooster[client]);
	Call_Finish();
	
	#if defined DEBUG
	LogMessage("Client: %N | Found Role Id (%s): %i | Data: %i", client, g_sRoleId, !!found, data);
	#endif
}

stock bool IsValidClient(int client)
{
    return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}