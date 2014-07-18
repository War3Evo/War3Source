#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

//new Float:MessageTimer[MAXPLAYERSCUSTOM];
//new W3Buff:MessageEventType[MAXPLAYERSCUSTOM];

public Plugin:myinfo = 
{
    name = "War3Source - Engine - Notifications",
    author = "War3Source Team",
    description = "Centralize some notifications"
};

new Float:MessageTimer[MAXPLAYERSCUSTOM];
new MessageCount[MAXPLAYERSCUSTOM];
new String:MessageString1[MAXPLAYERSCUSTOM][256];
new String:MessageString_Immunities[MAXPLAYERSCUSTOM][256];
new Float:MessageTimer_Immunities[MAXPLAYERSCUSTOM];

public bool:InitNativesForwards()
{
    CreateNative("War3_NotifyPlayerTookDamageFromSkill", Native_NotifyPlayerTookDamageFromSkill);
    CreateNative("War3_NotifyPlayerTookDamageFromItem", Native_NotifyPlayerTookDamageFromItem);
    CreateNative("War3_NotifyPlayerLeechedFromSkill", Native_NotifyPlayerLeechedFromSkill);
    CreateNative("War3_NotifyPlayerLeechedFromItem", Native_NotifyPlayerLeechedFromItem);
    CreateNative("War3_NotifyPlayerImmuneFromSkill", Native_NotifyPlayerImmuneFromSkill);
    CreateNative("War3_NotifyPlayerImmuneFromItem", Native_NotifyPlayerImmuneFromItem);
    CreateNative("War3_NotifyPlayerSkillActivated", Native_NotifyPlayerSkillActivated);
    CreateNative("War3_NotifyPlayerItemActivated", Native_NotifyPlayerItemActivated);

    return true;
}

public OnPluginStart()
{
    // Load Translations
}

public OnWar3PlayerAuthed(client)
{
    MessageTimer[client]=0.0;
    MessageCount[client]=0;
    strcopy(MessageString1[client], 255, ""); 
}

MessageTimerFunction(victim,attacker)
{
    if(MessageTimer[attacker]<(GetGameTime()-5.0))
    {
        MessageCount[attacker]=0;
        MessageCount[victim]=0;
    }
    if(MessageTimer[victim]<(GetGameTime()-5.0))
    {
        MessageCount[victim]=0;
    }
}

public Native_NotifyPlayerSkillActivated(Handle:plugin, numParams)
{
    new client = GetNativeCell(1);
    new skill = GetNativeCell(2);
    new bool:activated = bool:GetNativeCell(3);
    
    if (skill == 0)
    {
        return;
    }
    
    new String:sSkillName[32];
    new String:sSkillType[32];
    new race=War3_GetRace(client);

    W3GetRaceSkillName(race, skill, sSkillName, sizeof(sSkillName));
    if(War3_IsSkillUltimate(race, skill))
    {
        strcopy(sSkillType, sizeof(sSkillType), "ULTIMATE");
    }
    else
    {
        strcopy(sSkillType, sizeof(sSkillType), "SKILL");
    }
    
    if(activated)
    {
        War3_ChatMessage(client,"{default}[{green}%s {blue}%s {green}ACTIVATED{default}]",sSkillType,sSkillName);
    }
    else
    {
        War3_ChatMessage(client,"{default}[{green}%s {blue}%s {green}DEACTIVATED{default}]",sSkillType,sSkillName);
    }
}

public Native_NotifyPlayerItemActivated(Handle:plugin, numParams)
{
    new client = GetNativeCell(1);
    new item = GetNativeCell(2);
    new bool:activated = bool:GetNativeCell(3);
    
    if (item == 0)
    {
        return;
    }
    
    new String:sItemName[32];

    W3GetItemName(item, sItemName, sizeof(sItemName));
    
    if(activated)
    {
        War3_ChatMessage(client,"{default}[{green}ITEM {blue}%s {green}ACTIVATED{default}]",sItemName);
    }
    else
    {
        War3_ChatMessage(client,"{default}[{green}ITEM {blue}%s {green}DEACTIVATED{default}]",sItemName);
    }
}


NotifyPlayerTookDamageFunction(victim,attacker,damage,skillORitem,bool:IsSkill)
{
    MessageTimerFunction(victim,attacker);
    
    new String:sAttackerName[32];
    GetClientName(attacker, sAttackerName, sizeof(sAttackerName));
        
    new String:sVictimName[32];
    GetClientName(victim, sVictimName, sizeof(sVictimName));
    
    new String:sSkillName[32];
    new String:sSkillType[32];
    new String:sRaceName[64];
    
    new race=War3_GetRace(attacker);
    War3_GetRaceName(race,sRaceName,sizeof(sRaceName));
    
    SetTrans(attacker);
    if(IsSkill)
    {
        W3GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName));
        if(War3_IsSkillUltimate(race, skillORitem))
        {
            strcopy(sSkillType, sizeof(sSkillType), "ultimate");
        }
        else
        {
            strcopy(sSkillType, sizeof(sSkillType), "skill");
        }
    }
    else
    {
        W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
        strcopy(sSkillType, sizeof(sSkillType), "item");
    }
    
    
    decl String:sTmpString[256];
    Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
    
    if(ValidPlayer(attacker))
    {
        if(StrContains(MessageString1[attacker], sTmpString)>-1)
        {
            MessageCount[attacker]+=damage;
            MessageTimer[attacker]=GetGameTime();
    
            W3Hint(attacker, HINT_DMG_DEALT, 0.5, "You did +%i damage to %s with %s", damage, sVictimName, sSkillName);
            PrintToConsole(attacker, "[%d] You did +%i damage to %s with %s", MessageCount[attacker], damage, sVictimName, sSkillName);
            War3_ChatMessage(attacker,"{default}[{red}%d{default}] You did [{green}+%d{default}] damage to [{green}%s{default}] with {green}%s{default} [{green}%s{default}]!", MessageCount[attacker], damage, sVictimName, sSkillType, sSkillName);
        }
        else
        {
            MessageCount[attacker]=damage;
            MessageTimer[attacker]=GetGameTime();
            strcopy(MessageString1[attacker], 255, sTmpString);
            
            W3Hint(attacker, HINT_DMG_DEALT, 0.5, "You did +%i damage to %s with %s", damage, sVictimName, sSkillName);
            PrintToConsole(attacker, "[%d] You did +%i damage to %s with %s", MessageCount[attacker], damage, sVictimName, sSkillName);
            War3_ChatMessage(attacker,"{default}[{red}%d{default}] You did [{green}+%d{default}] damage to [{green}%s{default}] with {green}%s{default} [{green}%s{default}]!", MessageCount[attacker], damage, sVictimName, sSkillType, sSkillName);
        }
    }
    
    if(ValidPlayer(victim))
    {
        if(StrContains(MessageString1[victim], sTmpString)>-1 && attacker!=victim)
        {
            MessageCount[victim]+=damage;
            MessageTimer[victim]=GetGameTime();
    
            W3Hint(victim, HINT_DMG_RCVD, 0.5, "%s did %i damage to you with %s", sAttackerName, damage, sSkillName);
            PrintToConsole(victim, "[%d] %s did %i damage to you with %s", MessageCount[victim], sAttackerName, damage, sSkillName);
            War3_ChatMessage(victim,"{default}[{red}%d{default}] [{green}%s{default}] did [{green}+%d{default}] damage to you with {green}%s{default} [{green}%s{default}] as a {green}%s{default}!", MessageCount[victim], sAttackerName, damage, sSkillType, sSkillName, sRaceName);
        }
        else if(attacker!=victim)
        {
            MessageCount[victim]=damage;
            MessageTimer[victim]=GetGameTime();
            strcopy(MessageString1[victim], 255, sTmpString);
            
            W3Hint(victim, HINT_DMG_RCVD, 0.5, "%s did %i damage to you with %s", sAttackerName, damage, sSkillName);
            PrintToConsole(victim, "[%d] %s did %i damage to you with %s", MessageCount[victim], sAttackerName, damage, sSkillName);
            War3_ChatMessage(victim,"{default}[{red}%d{default}] [{green}%s{default}] did [{green}+%d{default}] damage to you with {green}%s{default} [{green}%s{default}] as a {green}%s{default}!", MessageCount[victim], sAttackerName, damage, sSkillType, sSkillName, sRaceName);
        }
    }
}


public Native_NotifyPlayerTookDamageFromSkill(Handle:plugin, numParams)
{
    new victim = GetNativeCell(1);
    new attacker = GetNativeCell(2);
    new damage = GetNativeCell(3);
    new skill = GetNativeCell(4);
    
    if (skill == 0)
    {
        return;
    }
    
    NotifyPlayerTookDamageFunction(victim,attacker,damage,skill,true);
}

public Native_NotifyPlayerTookDamageFromItem(Handle:plugin, numParams)
{
    new victim = GetNativeCell(1);
    new attacker = GetNativeCell(2);
    new damage = GetNativeCell(3);
    new item = GetNativeCell(4);
    
    if (item == 0)
    {
        return;
    }
    
    NotifyPlayerTookDamageFunction(victim,attacker,damage,item,false);
}


NotifyPlayerLeechedHealthFunction(victim,attacker,health,skillORitem,bool:IsSkill)
{
    MessageTimerFunction(attacker,victim);
    
    new String:sAttackerName[32];
    GetClientName(attacker, sAttackerName, sizeof(sAttackerName));
        
    new String:sVictimName[32];
    GetClientName(victim, sVictimName, sizeof(sVictimName));
    
    new String:sSkillName[32];
    new String:sSkillType[32];
    new String:sRaceName[64];

    new race = War3_GetRace(attacker);
    War3_GetRaceName(race,sRaceName,sizeof(sRaceName));
    
    SetTrans(attacker);
    if(IsSkill)
    {
        W3GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName));
        if(War3_IsSkillUltimate(race, skillORitem))
        {
            strcopy(sSkillType, sizeof(sSkillType), "ultimate");
        }
        else
        {
            strcopy(sSkillType, sizeof(sSkillType), "skill");
        }
    }
    else
    {
        W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
        strcopy(sSkillType, sizeof(sSkillType), "item");
    }
    
    
    decl String:sTmpString[256];
    Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
    
    if(ValidPlayer(attacker))
    {
        if(StrContains(MessageString1[attacker], sTmpString)>-1)
        {
            MessageCount[attacker]+=health;
            MessageTimer[attacker]=GetGameTime();
    
            W3Hint(attacker, HINT_DMG_DEALT, 0.5, "You leeched +%i health from %s with %s", health, sVictimName, sSkillName);
            PrintToConsole(attacker, "[%d] You leeched +%i health from %s with %s", MessageCount[attacker], health, sVictimName, sSkillName);
            War3_ChatMessage(attacker,"{default}[{blue}%d{default}] You leeched [{green}+%d{default}] health from [{green}%s{default}] with {blue}%s{default} [{green}%s{default}]!", MessageCount[attacker], health, sVictimName, sSkillType, sSkillName);
        }
        else
        {
            MessageCount[attacker]=health;
            MessageTimer[attacker]=GetGameTime();
            strcopy(MessageString1[attacker], 255, sTmpString);
            
            W3Hint(attacker, HINT_DMG_DEALT, 0.5, "You leeched +%i health from %s with %s", health, sVictimName, sSkillName);
            PrintToConsole(attacker, "[%d] You leeched +%i health from %s with %s", MessageCount[attacker], health, sVictimName, sSkillName);
            War3_ChatMessage(attacker,"{default}[{blue}%d{default}] You leeched [{green}+%d{default}] health from [{green}%s{default}] with {blue}%s{default} [{green}%s{default}]!", MessageCount[attacker], health, sVictimName, sSkillType, sSkillName);
        }
    }
    
    if(ValidPlayer(victim))
    {
        if(StrContains(MessageString1[victim], sTmpString)>-1 && attacker!=victim)
        {
            MessageCount[victim]+=health;
            MessageTimer[victim]=GetGameTime();
    
            W3Hint(victim, HINT_DMG_RCVD, 0.5, "%s leeched %i health from you with %s", sAttackerName, health, sSkillName);
            PrintToConsole(victim, "[%d] %s leeched %i health from you with %s", MessageCount[victim], sAttackerName, health, sSkillName);
            War3_ChatMessage(victim,"{default}[{blue}%d{default}] [{green}%s{default}] leeched [{green}+%d{default}] health from you with {blue}%s{default} [{green}%s{default}] as a {green}%s{default}!", MessageCount[victim], sAttackerName, health, sSkillType, sSkillName, sRaceName);
        }
        else if(attacker!=victim)
        {
            MessageCount[victim]=health;
            MessageTimer[victim]=GetGameTime();
            strcopy(MessageString1[victim], 255, sTmpString);
            
            W3Hint(victim, HINT_DMG_RCVD, 0.5, "%s leeched %i health from you with %s", sAttackerName, health, sSkillName);
            PrintToConsole(victim, "[%d] %s leeched %i health from you with %s", MessageCount[victim], sAttackerName, health, sSkillName);
            War3_ChatMessage(victim,"{default}[{blue}%d{default}] [{green}%s{default}] leeched [{green}+%d{default}] health from you with {blue}%s{default} [{green}%s{default}] as a {green}%s{default}!", MessageCount[victim], sAttackerName, health, sSkillType, sSkillName, sRaceName);
        }
    }
    
    War3_VampirismEffect(victim, attacker, health);
}

public Native_NotifyPlayerLeechedFromSkill(Handle:plugin, numParams)
{
    new victim = GetNativeCell(1);
    new attacker = GetNativeCell(2);
    new health = GetNativeCell(3);
    new skill = GetNativeCell(4);
    
    if (skill == 0)
    {
        return;
    }
    
    NotifyPlayerLeechedHealthFunction(victim,attacker,health,skill,true);
}
public Native_NotifyPlayerLeechedFromItem(Handle:plugin, numParams)
{
    new victim = GetNativeCell(1);
    new attacker = GetNativeCell(2);
    new health = GetNativeCell(3);
    new item = GetNativeCell(4);
    
    if (item == 0)
    {
        return;
    }
    
    NotifyPlayerLeechedHealthFunction(victim,attacker,health,item,false);
}


//=============================================================================
// Notify immune from skill
//=============================================================================

NotifyPlayerImmuneFromSkillOrItem(attacker,victim,skillORitem,bool:IsSkill)
{
    if(MessageTimer_Immunities[attacker]<(GetGameTime()-5.0))
    {
        strcopy(MessageString_Immunities[attacker], 255, "");
    }
    if(MessageTimer_Immunities[victim]<(GetGameTime()-5.0))
    {
        strcopy(MessageString_Immunities[victim], 255, "");
    }

    
    new String:sAttackerName[32];
    GetClientName(attacker, sAttackerName, sizeof(sAttackerName));
        
    new String:sVictimName[32];
    GetClientName(victim, sVictimName, sizeof(sVictimName));
    
    new String:sSkillName[32];
    new String:sSkillType[32];

    new race = War3_GetRace(attacker);
    
    SetTrans(attacker);
    if(skillORitem==0)
    {
        if(IsSkill)
        {
            strcopy(sSkillName, sizeof(sSkillName), "unknown");
            strcopy(sSkillType, sizeof(sSkillType), "skill/ultimate");
        }
        else
        {
            strcopy(sSkillName, sizeof(sSkillName), "unknown");
            strcopy(sSkillType, sizeof(sSkillType), "item");
        }
    }
    else
    {
        if(IsSkill)
        {
            W3GetRaceSkillName(race, skillORitem, sSkillName, sizeof(sSkillName));
            if(War3_IsSkillUltimate(race, skillORitem))
            {
                strcopy(sSkillType, sizeof(sSkillType), "ultimate");
            }
            else
            {
                strcopy(sSkillType, sizeof(sSkillType), "skill");
            }
        }
        else
        {
            W3GetItemName(skillORitem, sSkillName, sizeof(sSkillName));
            strcopy(sSkillType, sizeof(sSkillType), "item");
        }
    }
    
    decl String:sTmpString[256];
    Format(sTmpString,sizeof(sTmpString)," %s %s", sAttackerName, sSkillName);
    
    if(ValidPlayer(victim))
    {
        if(MessageTimer_Immunities[victim]<(GetGameTime()-1.0) && StrContains(MessageString_Immunities[victim], sTmpString)==-1)
        {
            MessageTimer_Immunities[victim]=GetGameTime();
            strcopy(MessageString_Immunities[victim], 255, sTmpString);
            
            W3Hint(attacker, HINT_DMG_DEALT, 0.5, "You are immune to %s from %s", sSkillName, sAttackerName);
            PrintToConsole(victim, "You are immune to %s from %s", sSkillName, sVictimName);
            War3_ChatMessage(victim,"{default}You are immune to %s [{green}%s{default}] from [{green}%s{default}]!", sSkillType, sSkillName, sAttackerName);
        }
    }
    
    if(ValidPlayer(attacker))
    {
        if(MessageTimer_Immunities[attacker]<(GetGameTime()-1.0) && StrContains(MessageString_Immunities[attacker], sTmpString)==-1 && attacker!=victim)
        {
            MessageTimer_Immunities[attacker]=GetGameTime();
            strcopy(MessageString_Immunities[attacker], 255, sTmpString);
            
            W3Hint(attacker, HINT_DMG_RCVD, 0.5, "%s is immune to %s", sVictimName, sSkillName);
            PrintToConsole(attacker, "%s is immune to %s", sVictimName, sSkillName);
            War3_ChatMessage(attacker,"{default}[{green}%s{default}] is immune to {green}%s{default} [{green}%s{default}]!", sVictimName, sSkillType, sSkillName);
        }
    }
}

public Native_NotifyPlayerImmuneFromSkill(Handle:plugin, numParams)
{
    new attacker = GetNativeCell(1);
    new victim = GetNativeCell(2);
    new skill = GetNativeCell(3);
    
    if (skill == 0)
    {
        return;
    }
    
    NotifyPlayerImmuneFromSkillOrItem(attacker,victim,skill,true);
}

public Native_NotifyPlayerImmuneFromItem(Handle:plugin, numParams)
{
    new attacker = GetNativeCell(1);
    new victim = GetNativeCell(2);
    new item = GetNativeCell(3);
    
    if (item == 0)
    {
        return;
    }
    
    NotifyPlayerImmuneFromSkillOrItem(attacker,victim,item,false);
}
//=============================================================================
// Buff Notifications
//=============================================================================

// Internally forwarded via War3's on EVENT process:
//  W3SetVar(EventArg1,buffindex); //generic war3event arguments
//  W3SetVar(EventArg2,itemraceindex); 
//  W3SetVar(EventArg3,value); 
//  W3CreateEvent(W3EVENT:OnBuffChanged,client);
//
// You'll need to capture the event example:


//I want to create a new War3Buff system where you tell war3buff that the person giving the buff is the attacker or
//is a person whom is not the client or store the OWNER of the buff into the information for OnBuffChanged..
//Then this can compare values and stuff to find out if the OWNER and client is friendly or the buff is good or not to
//give proper warnings.


public OnWar3Event(W3EVENT:event,client){
    if(event==OnBuffChanged)
    {
        if(!ValidPlayer(client))
        {
            return;
        }
        new W3Buff:buffindex=W3Buff:W3GetVar(EventArg1);
        new buffowner=W3GetVar(EventArg4);
        
        if((buffowner>-1) && ValidPlayer(client,true) && ValidPlayer(buffowner,true) && (client!=buffowner))
        {
                if(buffindex==fSlow)
                {
                    War3_ChatMessage(client,"{default}[{blue}SLOW SKILL{default}] You're being slowed by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[SLOW] You are slowed by a enemy!");
                }
                else if(buffindex==fHPDecay)
                {
                    War3_ChatMessage(client,"{default}[{red}HPDECAY SKILL{default}] Your health is being drained by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[HP DECAY] Health is drained by a enemy!");
                }
                else if(buffindex==bStunned)
                {
                    War3_ChatMessage(client,"{default}[{blue}STUN{default}] You are stunned by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[STUN] You are stunned!");
                }
                else if(buffindex==bBashed)
                {
                    War3_ChatMessage(client,"{default}[{blue}BASHED{default}] You are bashed by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[BASHED] You are bashed!");
                }
                else if(buffindex==bDisarm)
                {
                    War3_ChatMessage(client,"{default}[{blue}DISARM{default}] You are disarmed by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[DISARM] You are disarmed!");
                }
                else if(buffindex==bSilenced)
                {
                    War3_ChatMessage(client,"{default}[{blue}SILENCED{default}] You are silenced by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[SILENCED] You are silenced!");
                }
                else if(buffindex==bHexed)
                {
                    War3_ChatMessage(client,"{default}[{blue}HEXED{default}] You are hexed by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[HEXED] You are hexed!");
                }
                else if(buffindex==bPerplexed)
                {
                    War3_ChatMessage(client,"{default}[{blue}PERPLEXED{default}] You are perplexed by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[PERPLEXED] You are perplexed!");
                }
                else if(buffindex==bNoMoveMode)
                {
                    War3_ChatMessage(client,"{default}[{blue}NO MOVE{default}] You are unable to move by a enemy!");
                    W3Hint(client,HINT_SKILL_STATUS,0.5,"[NO MOVE] You are unable to move!");
                }
        }
        //DP("EVENT OnBuffChanged",event);
    }
    //DP("EVENT %d",event);
}
