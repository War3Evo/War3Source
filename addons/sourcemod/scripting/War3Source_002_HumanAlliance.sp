#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
    name = "War3Source - Race - Human Alliance",
    author = "War3Source Team",
    description = "The Human Alliance race for War3Source."
};

new thisRaceID;

new bool:RaceDisabled=true;
public OnWar3RaceEnabled(newrace)
{
    if(newrace==thisRaceID)
    {
        RaceDisabled=false;
    }
}
public OnWar3RaceDisabled(oldrace)
{
    if(oldrace==thisRaceID)
    {
        RaceDisabled=true;
    }
}

new Handle:ultCooldownCvar;

// Chance/Info Arrays
new Float:BashChance[5]={0.0,0.07,0.13,0.19,0.25};
new Float:TeleportDistance[5]={0.0,600.0,700.0,850.0,1000.0};
//TEST ONLY
//new Float:TeleportDistance[5]={0.0,240.0,240.0,240.0,240.0};

new Float:InvisibilityAlphaTF[5]={1.0,0.84,0.68,0.56,0.40};

new Float:InvisibilityAlphaCS[5]={1.0,0.90,0.8,0.7,0.6};


new DevotionHealth[5]={0,15,25,35,45};


// Effects
new BeamSprite,HaloSprite;

new SKILL_INVIS, SKILL_BASH, SKILL_HEALTH,ULT_TELEPORT;


//new String:teleportSound[]="war3source/blinkarrival.wav";

public OnPluginStart()
{
    ultCooldownCvar = CreateConVar("war3_human_teleport_cooldown","20.0","Cooldown between teleports");
    
    LoadTranslations("w3s.race.human.phrases.txt");
    
    War3_RaceOnPluginStart("human");
}

public OnPluginEnd()
{
    if(LibraryExists("RaceClass"))
        War3_RaceOnPluginEnd("human");
}

public OnWar3LoadRaceOrItemOrdered2(num,reloadrace_id,String:shortname[])
{
    //if(GAMECSANY)
    //{
    if(num == 20||(reloadrace_id>0&&StrEqual("human",shortname,false)))
    {
        thisRaceID=War3_CreateNewRaceT("human","Teleport,Invis,+hp",reloadrace_id);
        SKILL_INVIS=War3_AddRaceSkillT(thisRaceID,"Invisibility",false,4,"60% (CS), 40% (TF)");
        SKILL_HEALTH=War3_AddRaceSkillT(thisRaceID,"DevotionAura",false,4,"15/25/35/45");
        SKILL_BASH=War3_AddRaceSkillT(thisRaceID,"Bash",false,4,"7/13/19/25%","0.2");
        ULT_TELEPORT=War3_AddRaceSkillT(thisRaceID,"Teleport",true,4,"600/800/1000/1200");
        
        W3SkillCooldownOnSpawn(thisRaceID,ULT_TELEPORT,10.0,_);
        
        War3_CreateRaceEnd(thisRaceID);
        
        War3_AddSkillBuff(thisRaceID, SKILL_BASH, fBashChance, BashChance);
        War3_AddSkillBuff(thisRaceID, SKILL_INVIS, fInvisibilitySkill, GameTF() ? InvisibilityAlphaTF : InvisibilityAlphaCS);
        War3_AddSkillBuff(thisRaceID, SKILL_HEALTH, iAdditionalMaxHealth, DevotionHealth);
    }
}

public OnMapStart()
{
    BeamSprite=War3_PrecacheBeamSprite();
    HaloSprite=War3_PrecacheHaloSprite();
}


public OnWar3EventSpawn(client)
{
    if(RaceDisabled)
    {
        return;
    }

    ActivateSkills(client); //DO NOT OPTIMIZE, ActivateSkills checks for skill level
}
public ActivateSkills(client)
{
    if(RaceDisabled)
    {
        return;
    }

    new skill_devo=War3_GetSkillLevel(client,thisRaceID,SKILL_HEALTH);
    if(skill_devo)
    {
        // Devotion Aura
        new Float:vec[3];
        GetClientAbsOrigin(client,vec);
        vec[2]+=20.0;
        new ringColor[4]={0,0,0,0};
        new team=GetClientTeam(client);
        if(team==2)
        {
            ringColor={255,0,0,255};
        }
        else if(team==3)
        {
            ringColor={0,0,255,255};
        }
        TE_SetupBeamRingPoint(vec,40.0,10.0,BeamSprite,HaloSprite,0,15,1.0,15.0,0.0,ringColor,10,0);
        TE_SendToAll();
        
    }
}


//public OnGenericSkillLevelChanged(client,generic_skill_id,newlevel,Handle:generic_Skill_Options,customer_race,customer_skill)
//{
    //new String:name[32];
    //GetClientName(client,name,sizeof(name));
    //DP("client %d %s genericskill %d level %d, cus %d %d",client,name,generic_skill_id,newlevel,customer_race,customer_skill);
//}

public OnUltimateCommand(client,race,bool:pressed)
{
    if(RaceDisabled)
    {
        return;
    }

    //DP("ult pressed");
    if( race==thisRaceID && pressed  && ValidPlayer(client,true) && !Silenced(client))
    {
        new ult_level=War3_GetSkillLevel(client,thisRaceID,ULT_TELEPORT);
        //DP("level CUSrace CUSskill %d %d %d",level,customerrace,customerskill);
        if(ult_level)
        {
            //DP("cool %f",cooldown);
            if(War3_SkillNotInCooldown(client,thisRaceID,ult_level,true)) //not in the 0.2 second delay when we check stuck via moving
            {
                W3Teleport(client,_,_,TeleportDistance[ult_level],thisRaceID,ULT_TELEPORT);
            }
        
        }
        else
        {
            W3MsgUltNotLeveled(client);
        }
    }
}

public OnW3Teleported(client,target,distance,raceid,skillid)
{
    if(ValidPlayer(client) && raceid==thisRaceID)
    {
        new Float:cooldown=GetConVarFloat(ultCooldownCvar);
        War3_CooldownMGR(client,cooldown,thisRaceID,ULT_TELEPORT,_,_);
    }
}

public Action:OnW3TeleportLocationChecking(client,Float:playerVec[3])
{
    if(ValidPlayer(client) && War3_GetRace(client)==thisRaceID)
    {
        //DP("teleport location checking");
        //ELIMINATE ULTIMATE IF THERE IS IMMUNITY AROUND
        new Float:otherVec[3];
        new team = GetClientTeam(client);

        for(new i=1;i<=MaxClients;i++)
        {
            if(ValidPlayer(i,true)&&GetClientTeam(i)!=team&&W3HasImmunity(i,Immunity_Ultimates))
            {
                GetClientAbsOrigin(i,otherVec);
                if(GetVectorDistance(playerVec,otherVec)<350)
                {
                    War3_NotifyPlayerImmuneFromSkill(client, i, ULT_TELEPORT);
                    return Plugin_Handled;
                }
            }
        }
    }
    return Plugin_Continue;
}

public OnSkillLevelChanged(client,race,skill,newskilllevel)
{
    if(RaceDisabled)
    {
        return;
    }

    if(race==thisRaceID)
    {
        ActivateSkills(client); //on a race change, this is called 4 times, but that performance hit is insignificant
    }
}
    