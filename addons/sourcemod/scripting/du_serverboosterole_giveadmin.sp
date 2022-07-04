#include <sourcemod>
#include <multicolors>
#include <du_serverboosterole>

//#define DEBUG

ConVar cv_sAdminGroup;

char g_sAdminGroup[32];

public Plugin myinfo = 
{
    name = "Discord Utilities: Discord Server Booster Role Give Admin Group",
    author = "Trayz",
    description = "Give Admin Group based on Discord Utilities: Discord Server Booster Role Core",
    version = "1.0",
    url = "ptrunners.net"
};

public void OnPluginStart()
{
    cv_sAdminGroup = CreateConVar("sm_du_serverboosterole_giveadmin_group", "ServerBooster", "Admin Group to apply clients that met the requirements.");
    cv_sAdminGroup.GetString(g_sAdminGroup, sizeof(g_sAdminGroup));
    cv_sAdminGroup.AddChangeHook(OnConVarChanged);

    AutoExecConfig(true);

    ReloadServerBoosters();
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cv_sAdminGroup)
		cv_sAdminGroup.GetString(g_sAdminGroup, sizeof(g_sAdminGroup));
}

public void OnRebuildAdminCache(AdminCachePart part)
{
    if (part != AdminCache_Admins) return;

    ReloadServerBoosters();
}

public void DU_ServerBoosterRole_OnClientLoaded(int client, bool bIsServerBooster)
{
    #if defined DEBUG
    LogMessage("Client: %N | bIsServerBooster: %i", client, !!bIsServerBooster);
    #endif

    if(!bIsServerBooster) return;

    SetClientAdminGroup(client);
}

void ReloadServerBoosters()
{
    for (int i = 1; i < MAXPLAYERS; i++)
    {
        if(!IsValidClient(i)) continue;

        if(!DU_ServerBoosterRole_IsLoaded(i)) continue;

        if(!DU_ServerBoosterRole_IsServerBooster(i)) continue;

        SetClientAdminGroup(i);
    }
}

void SetClientAdminGroup(int client)
{
    if(StrEqual(g_sAdminGroup, "")) return;

    GroupId id = FindAdmGroup(g_sAdminGroup);

    AdminId admin = GetUserAdmin(client);

    if(admin == INVALID_ADMIN_ID)
    {
        admin = CreateAdmin();

        SetUserAdmin(client, admin, true);
    }
    
    AdminInheritGroup(admin, id);
}

stock bool IsValidClient(int client)
{
    return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}