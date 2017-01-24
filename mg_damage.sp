#include <cg_core>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = " MG Damage ",
	author = "Kyle",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/id/_xQy_/"
};

public void CG_OnClientLoaded(int client)
{
	if(PA_GetGroupID(client) == 9999)
	{
		CreateTimer(0.5, Timer_Armor, client);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnClientDisconnect(int client)
{
	if(PA_GetGroupID(client) == 9999)
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(damagetype & DMG_FALL)
	{
		damage *= 0.5;
		return Plugin_Changed;
	}
	
	if(attacker < 1 || attacker > MaxClients)
		return Plugin_Continue;

	if(IsValidEdict(inflictor))
	{
		char entityclass[32];
		GetEdictClassname(inflictor, entityclass, 32);
		if(StrEqual(entityclass, "hegrenade_projectile"))
		{
			damage *= 0.35;
			return Plugin_Changed;
		}
		else if(StrEqual(entityclass, "inferno") || StrEqual(entityclass, "trigger_hurt"))
		{
			damage *= 0.50;
			return Plugin_Changed;
		}
	}

	if(IsValidEdict(weapon))
	{
		char classname[32];
		GetEdictClassname(weapon, classname, 32);
		if(StrEqual(classname, "weapon_taser"))
		{
			damage *= 0.5;
			return Plugin_Changed;
		}
		else if(StrEqual(classname, "weapon_knife"))
		{
			if(damage > 65.0)
			{
				damage = 65.0;
				return Plugin_Changed;
			}
		}
		else if(StrEqual(classname, "weapon_awp"))
		{
			if(damage > 400.0)
			{
				damage = 300.0;
				return Plugin_Changed;
			}
		}
		else
			damage *= 0.8;
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action Timer_Armor(Handle timer, int client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	
	if(!IsPlayerAlive(client))
		return Plugin_Continue;
	
	if(GetEntProp(client, Prop_Send, "m_ArmorValue") <= 0)
	{
		SetEntProp(client, Prop_Send, "m_ArmorValue", 10, 1);
		//RequestFrame(ResetArmorValue, client);
	}
	
	return Plugin_Continue;
}

stock void ResetArmorValue(int client)
{
	SetEntProp(client, Prop_Send, "m_ArmorValue", 0, 1);
}