#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin myinfo =
{
	name = "Friendly Fire Damage",
	author = "Ilusion9",
	description = "Manage the damage done to teammates.",
	version = "2.0",
	url = "https://github.com/Ilusion9/"
};

ConVar g_Cvar_GrenadeDamage;
ConVar g_Cvar_GrenadeDamageSelf;
ConVar g_Cvar_MolotovDamage;
ConVar g_Cvar_MolotovDamageSelf;
ConVar g_Cvar_KnifeDamage;
ConVar g_Cvar_TaserDamage;
ConVar g_Cvar_OtherDamage;

public void OnPluginStart()
{
	g_Cvar_GrenadeDamage = CreateConVar("sm_ff_damage_reduction_hegrenade", "1.0", "Damage done to teammates by a thrown hegrenade.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_GrenadeDamageSelf = CreateConVar("sm_ff_damage_reduction_hegrenade_self", "1.0", "Damage done to players by their own hegrenade", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_MolotovDamage = CreateConVar("sm_ff_damage_reduction_molotov", "1.0", "Damage done to teammates by a thrown molotov.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_MolotovDamageSelf = CreateConVar("sm_ff_damage_reduction_molotov_self", "1.0", "Damage done to players by their own molotov.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_KnifeDamage = CreateConVar("sm_ff_damage_reduction_knife", "1.0", "Damage done to teammates by a knife.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_TaserDamage = CreateConVar("sm_ff_damage_reduction_taser", "1.0", "Damage done to teammates by a taser.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_Cvar_OtherDamage = CreateConVar("sm_ff_damage_reduction_other", "1.0", "Damage done to teammates by other things.", FCVAR_NONE, true, 0.0, true, 1.0);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnConfigsExecuted()
{
	SetConVar("ff_damage_reduction_grenade", "1");
	SetConVar("ff_damage_reduction_grenade_self", "1");
	SetConVar("ff_damage_reduction_other", "1");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, SDK_OnTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public Action SDK_OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!IsClientInGame(victim) || !IsEntityClient(attacker) || !IsClientInGame(attacker))
	{
		return Plugin_Continue;
	}
	
	// not friendly fire
	if (GetClientTeam(attacker) != GetClientTeam(victim))
	{
		return Plugin_Continue;
	}
	
	// weapon validation
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if (weapon == -1)
	{
		damage *= g_Cvar_OtherDamage.FloatValue;
		return Plugin_Changed;
	}
	
	// knife damage
	if (view_as<bool>(damagetype & DMG_SLASH))
	{
		damage *= g_Cvar_KnifeDamage.FloatValue;
		return Plugin_Changed;
	}
	
	// taser
	if (view_as<bool>(damagetype & DMG_SHOCK))
	{
		damage *= g_Cvar_TaserDamage.FloatValue;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action SDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!IsClientInGame(victim) || !IsEntityClient(attacker) || !IsClientInGame(attacker))
	{
		return Plugin_Continue;
	}
	
	// handle this in TraceAttack
	if (IsEntityClient(inflictor))
	{
		return Plugin_Continue;
	}
	
	// not friendly fire
	if (GetClientTeam(attacker) != GetClientTeam(victim))
	{
		return Plugin_Continue;
	}
	
	char classname[256];
	GetEntityClassname(inflictor, classname, sizeof(classname));
	
	if (StrEqual(classname, "inferno", true))
	{
		if (attacker == victim)
		{
			damage *= g_Cvar_MolotovDamageSelf.FloatValue;
		}
		else
		{
			damage *= g_Cvar_MolotovDamage.FloatValue;
		}
		
		return Plugin_Changed;
	}
	
	if (StrEqual(classname, "hegrenade_projectile", true))
	{
		if (attacker == victim)
		{
			damage *= g_Cvar_GrenadeDamageSelf.FloatValue;
		}
		else
		{
			damage *= g_Cvar_GrenadeDamage.FloatValue;
		}
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

void SetConVar(const char[] cvarName, const char[] value)
{
	ConVar cvar = FindConVar(cvarName);
	if (cvar)
	{
		cvar.SetString(value);
	}
}

bool IsEntityClient(int client)
{
	return (client > 0 && client <= MaxClients);
}