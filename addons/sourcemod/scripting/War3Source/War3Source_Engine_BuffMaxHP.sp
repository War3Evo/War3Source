//#pragma semicolon 1

//#undef REQUIRE_EXTENSIONS 
//#include <tf2>
//#include <tf2_stocks>
//#define REQUIRE_EXTENSIONS

//#include <sourcemod>
//#include <sdkhooks>
//#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
    name = "War3Source - Engine - Buff Max HP",
    author = "War3Source Team",
    description = "Controls a players Max HP via Buffs"
};

public Action:checkHeadsTimer(Handle:h, any:attackerRef)
{
    new attacker = EntRefToEntIndex(attackerRef);
    if(!ValidPlayer(attacker, true))
    {
        return;
    }
    
    // Increase the internally stored max health 
    // There is a limit to how many heads that can be counted toward health
    new heads = GetEntProp(attacker, Prop_Send, "m_iDecapitations");
    if (heads > 0 && heads <= 4)
    {
        War3_SetMaxHP_INTERNAL(attacker, War3_GetMaxHP(attacker) + 15);
    }
}

public Action:CheckHPBuffChange(Handle:h,any:client)
{
    hCheckBuffTimer[client] = INVALID_HANDLE;
    
    if(ValidPlayer(client, true))
    {
        new iAdditionalHP = W3GetBuffSumInt(client, iAdditionalMaxHealth);
        new iAdditionalHPNoBuff = W3GetBuffSumInt(client, iAdditionalMaxHealthNoHPChange);
        new iOldBuff = War3_GetMaxHP(client) - iClientSpawnHP[client] - iAdditionalHPNoBuff;
        War3_SetMaxHP_INTERNAL(client, iClientSpawnHP[client] + iAdditionalHP + iAdditionalHPNoBuff); //set max hp
        
        new newhp = GetClientHealth(client) + iAdditionalHP - iOldBuff; //difference
        if(newhp < 1)
        {
            newhp = 1;
        }

        SetEntityHealth(client, newhp);
    }
}

public OnWar3EventPostHurt(victim, attacker, Float:damage, const String:weapon[32], bool:isWarcraft)
{
    if (ValidPlayer(victim)) 
    {
        fLastDamageTime[victim] = GetEngineTime();
    }
}
