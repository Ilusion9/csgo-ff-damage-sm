#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "Molotov Damage",
	author = "Ilusion9",
	description = "Enable molotov damage for teammates",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (attacker < 1 || attacker > MaxClients || attacker == victim || GetClientTeam(attacker) != GetClientTeam(victim))
	{
		return Plugin_Continue;
	}
	
	if (inflictor != -1)
	{
		char inflictorClass[64];
		if (GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass)))
		{
			if (StrEqual(inflictorClass, "planted_c4"))
			{
				return Plugin_Continue;
			}
			
			if (StrEqual(inflictorClass, "inferno"))
			{
				return Plugin_Continue;
			}
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
