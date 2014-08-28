//#pragma semicolon 1

//#include <sourcemod>
//#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
    name = "War3Source - Engine - AttributeBuffs",
    author = "War3Source Team",
    description = "Manages the attributes on a player"
};

// Natives

public Native_War3_ApplyTimedBuff(Handle:plugin, numParams)
{
    return ApplyTimedBuffOrDebuff(BUFFTYPE_BUFF);
}

public Native_War3_ApplyTimedDebuff(Handle:plugin, numParams)
{
    return ApplyTimedBuffOrDebuff(BUFFTYPE_DEBUFF);
}

public Native_War3_ApplyRaceBuff(Handle:plugin, numParams)
{
    return ApplyRaceBuffOrDebuff(BUFFTYPE_BUFF);
}

public Native_War3_ApplyRaceDebuff(Handle:plugin, numParams)
{
    return ApplyRaceBuffOrDebuff(BUFFTYPE_DEBUFF);
}

public Native_War3_RemoveBuff(Handle:plugin, numParams)
{
    new buffIndex = GetNativeCell(1);
    
    RemoveBuff(buffIndex);
}

// Not natives :P

ApplyTimedBuffOrDebuff(W3BuffType:buffType)
{
    new client = GetNativeCell(1);
    new iAttributeId = GetNativeCell(2);
    new any:value = GetNativeCell(3);
    new Float:fDuration = GetNativeCell(4);
    new W3BuffSourceType:sourceType = GetNativeCell(5);
    new source = GetNativeCell(6);
    new expireFlag = GetNativeCell(7);
    new bool:bCanStack = GetNativeCell(9);
    
    // Check if the client already has this buff/debuff and if he has check if it's stackable
    if (!bCanStack)
    {
        for(new i = 0; i < GetArraySize(g_hBuffClient); i++)
        {
            new buffedclient = GetArrayCell(g_hBuffClient, i);
            
            if (buffedclient == client)
            {
                new buffedSource = GetArrayCell(g_hBuffSource, i);
                new W3BuffSourceType:buffedSourceType = GetArrayCell(g_hBuffSourceType, i);
                new bool:bBuffedCanStack = GetArrayCell(g_hBuffCanStack, i);
                
                if ((buffedSource != source) || (buffedSourceType != sourceType) || !bBuffedCanStack)
                {
                    return INVALID_BUFF;
                }
            }
        }
    }
    
    // Buffs in general
    new buffindex = PushArrayCell(g_hBuffClient, client);
    PushArrayCell(g_hAttributeID, iAttributeId);
    PushArrayCell(g_hBuffValue, value);
    PushArrayCell(g_hBuffExpireFlag, expireFlag);
    PushArrayCell(g_hBuffType, buffType);
    PushArrayCell(g_hBuffSource, source);
    PushArrayCell(g_hBuffSourceType, sourceType);
    
    // Timed buffs
    PushArrayCell(g_hBuffDuration, fDuration);
    PushArrayCell(g_hBuffCanStack, bCanStack);
    
    // Race buff - not needed here
    PushArrayCell(g_hRaceBuffRaceId, -1);
    
    // Internals
    PushArrayCell(g_hBuffActive, true);
    PushArrayCell(g_hBuffExpireTime, GetEngineTime() + fDuration);
    
    War3_ModifyAttribute(client, iAttributeId, value);
    
    return buffindex;
}

ApplyRaceBuffOrDebuff(W3BuffType:buffType)
{
    new client = GetNativeCell(1);
    new iAttributeId = GetNativeCell(2);
    new any:value = GetNativeCell(3);
    new raceID = GetNativeCell(4);
    new W3BuffSourceType:sourceType = GetNativeCell(5);
    new source = GetNativeCell(6);
    
    // Buffs in general
    new buffindex = PushArrayCell(g_hBuffClient, client);
    PushArrayCell(g_hAttributeID, iAttributeId);
    PushArrayCell(g_hBuffValue, value);
    PushArrayCell(g_hBuffExpireFlag, BUFF_EXPIRES_MANUALLY);
    PushArrayCell(g_hBuffType, buffType);
    PushArrayCell(g_hBuffSource, source);
    PushArrayCell(g_hBuffSourceType, sourceType);
    
    // Timed buffs - not needed here
    PushArrayCell(g_hBuffDuration, 0.0);
    PushArrayCell(g_hBuffCanStack, false);
    
    // Race buff
    PushArrayCell(g_hRaceBuffRaceId, raceID);
    
    // Internals
    PushArrayCell(g_hBuffActive, true);
    PushArrayCell(g_hBuffExpireTime, 0.0);
    
    return buffindex;
}

// Cleanup

RemoveBuff(buffIndex)
{
    new client = GetArrayCell(g_hBuffClient, buffIndex);
    new iAttributeId = GetArrayCell(g_hAttributeID, buffIndex);
    
    // implement
    War3_LogInfo("Removing buff %i for attribute %i on client %i", buffIndex, iAttributeId, client);
    
    new any:value = GetArrayCell(g_hBuffValue, buffIndex);
    War3_ModifyAttribute(client, iAttributeId, -value);
    
    SetArrayCell(g_hBuffActive, buffIndex, false);
}