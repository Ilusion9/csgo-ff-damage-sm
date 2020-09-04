#include <sourcemod>
#include <sdkhooks>
#pragma newdecls required

public Plugin myinfo =
{
	name = "Molotov Friendly Fire",
	author = "Ilusion9",
	description = "Enable only molotov damage for teammates and block everything else.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

bool g_IsPluginLoadedLate;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_IsPluginLoadedLate = late;
}

public void OnPluginStart()
{
	if (g_IsPluginLoadedLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public Action SDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (attacker < 1 || attacker > MaxClients || attacker == victim || inflictor < 1 || !IsClientInGame(victim) || !IsClientInGame(attacker))
	{
		return Plugin_Continue;
	}
	
	if (GetClientTeam(attacker) != GetClientTeam(victim))
	{
		return Plugin_Continue;
	}
	
	if (inflictor > MaxClients)
	{
		char inflictorClass[64];
		GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass));
		
		if (StrEqual(inflictorClass, "planted_c4") || StrEqual(inflictorClass, "inferno"))
		{
			return Plugin_Continue;
		}
	}
	
	damage = 0.0;
	damagetype |= DMG_PREVENT_PHYSICS_FORCE;
	return Plugin_Changed;
}
