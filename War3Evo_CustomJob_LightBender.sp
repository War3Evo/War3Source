/**
 * File: War3Source_Light_Bender.sp
* Description: The Light Bender race for SourceCraft.
* Author(s): xDr.HaaaaaaaXx
**/

#pragma semicolon 1
#pragma tabsize 0
#include <sourcemod>
#include <sdktools>
#include <sdktools_stocks>
#include <sdktools_functions>

#include "W3SIncs/War3Source_Interface"

// War3Source stuff
new thisRaceID, SKILL_RED, SKILL_GREEN, SKILL_BLUE, ULT_DISCO;

new Float:RGBChance[6] = { 0.00, 0.05, 0.10, 0.15, 0.20, 0.25 };
new ClientTarget[64];

const Maximum_Players_array=100;

new HaloSprite, BeamSprite;

public Plugin:myinfo = 
{
	name = "War3Source Race - Light Bender",
	author = "xDr.HaaaaaaaXx",
	description = "The Light Bender race for War3Source.",
	version = "1.0.0.0",
	url = ""
};

public OnMapStart()
{
	HaloSprite = PrecacheModel( "materials/sprites/halo01.vmt" );
	BeamSprite = PrecacheModel( "materials/sprites/laser.vmt" );
}

public OnPluginStart()
{
	// Must be put into a race that is reloadable.
	War3_RaceOnPluginStart("lightbender");
}

public OnPluginEnd()
{
	// Must be put into a race that is reloadable.
	War3_RaceOnPluginEnd("lightbender");
}

// Must look almost like this to be reloadable:
public OnWar3LoadRaceOrItemOrdered4(num,reloadrace_id,String:shortname[])
{
	if(num==83||(reloadrace_id>0&&StrEqual("lightbender",shortname,false)))
	{
		thisRaceID = War3_CreateNewRace( "Light Bender", "lightbender",reloadrace_id );
	
		SKILL_RED = War3_AddRaceSkill( thisRaceID, "Red Laser: Burn", "Burn your targets", false, 5 );
		SKILL_GREEN = War3_AddRaceSkill( thisRaceID, "Green Laser: Shake", "Shake your targets", false, 5 );
		SKILL_BLUE = War3_AddRaceSkill( thisRaceID, "Blue Laser: Freeze", "Freeze your Targets", false, 5 );
		ULT_DISCO = War3_AddRaceSkill( thisRaceID, "Flash", "Teleport a random ally!", true, 1 );
		War3_CreateRaceEnd( thisRaceID );
	}
}


public OnRaceChanged(client,oldrace,newrace)
{
	if( newrace != thisRaceID )
	{
		W3ResetAllBuffRace( client, thisRaceID );
	}
}

public OnWar3EventDeath( victim, attacker )
{
	W3ResetAllBuffRace( victim, thisRaceID );
}

//public OnWar3EventPostHurt( victim, attacker, damage )
public OnW3TakeDmgAll(victim,attacker,Float:damage)
{
	// W3IsOwnerSentry checks internally if the game is TF or not.  Returns false if not TF.
	// In TF, the sentry makes a race so OP.  So a lot of my races I check for the sentry via OnW3TakeDmgAll and W3IsOwnerSentry(attacker) function.
	if(!W3IsOwnerSentry(attacker) && W3GetDamageIsBullet() && ValidPlayer( victim, true ) && ValidPlayer( attacker, true ) && GetClientTeam( victim ) != GetClientTeam( attacker ) )
	{
		if( War3_GetRace( attacker ) == thisRaceID && !W3HasImmunity(victim,Immunity_Skills) )
		{
			new skill_red = War3_GetSkillLevel( attacker, thisRaceID, SKILL_RED );
			if( !Hexed( attacker, false ) && skill_red > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_red] && !W3HasImmunity(victim,Immunity_Skills) )
			{
				IgniteEntity( victim, 1.0 );
				
				new Float:StartPos[3];
				new Float:EndPos[3];
				
				GetClientAbsOrigin( victim, StartPos );
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );

				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );
				
				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );
				
				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 255, 11, 15, 255 }, 1 );
				TE_SendToAll();
			}
			
			new skill_green = War3_GetSkillLevel( attacker, thisRaceID, SKILL_GREEN );
			if( !Hexed( attacker, false ) && skill_green > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_green] && !W3HasImmunity(victim,Immunity_Skills) )
			{
				War3_SetBuff( victim, bHexed, thisRaceID, true );
				CreateTimer( 3.0, StopHex, victim );
				
				new Float:StartPos[3];
				new Float:EndPos[3];
				
				GetClientAbsOrigin( victim, StartPos );
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );

				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );
				
				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );

				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 11, 255, 15, 255 }, 1 );
				TE_SendToAll();
			}
			
			new skill_blue = War3_GetSkillLevel( attacker, thisRaceID, SKILL_BLUE );
			if( !Hexed( attacker, false ) && skill_blue > 0 && GetRandomFloat( 0.0, 1.0 ) <= RGBChance[skill_blue] && !W3HasImmunity(victim,Immunity_Skills) )
			{
				War3_SetBuff( victim, bNoMoveMode, thisRaceID, true );
				CreateTimer( 0.5, StopFreeze, victim );
				
				new Float:StartPos[3];
				new Float:EndPos[3];
				
				GetClientAbsOrigin( victim, StartPos );
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );

				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );
				
				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
				TE_SendToAll();
				
				GetClientAbsOrigin( victim, EndPos );
				
				EndPos[0] += GetRandomFloat( -100.0, 100.0 );
				EndPos[1] += GetRandomFloat( -100.0, 100.0 );
				EndPos[2] += GetRandomFloat( -100.0, 100.0 );
				
				TE_SetupBeamPoints( StartPos, EndPos, BeamSprite, HaloSprite, 0, 1, 4.0, 20.0, 2.0, 0, 0.0, { 15, 11, 255, 255 }, 1 );
				TE_SendToAll();
			}
		}
	}
}

public Action:StopFreeze( Handle:timer, any:client )
{
	if( ValidPlayer( client, true ) )
	{
		War3_SetBuff( client, bNoMoveMode, thisRaceID, false );
	}
}

public Action:StopHex( Handle:timer, any:client )
{
	if( ValidPlayer( client, true ) )
	{
		War3_SetBuff( client, bHexed, thisRaceID, false );
	}
}

public OnUltimateCommand( client, race, bool:pressed )
{
	if( race == thisRaceID && pressed && ValidPlayer( client, true ) )
	{
		new ult_level = War3_GetSkillLevel( client, race, ULT_DISCO );
        if(!W3HasImmunity(ClientTarget[client],Immunity_Ultimates))
		 if( ult_level > 0)
		 {
			if( War3_SkillNotInCooldown( client, thisRaceID, ULT_DISCO, true ) )
			{
				Disco( client );
			}
		 }
		 else
		 {
			PrintHintText( client, "Level Your Ultimate First" );
		 }
	}
}

stock Disco( client )
{
	// changing so that the client goes to a random ally player
	if( GetClientTeam( client ) == TEAM_T )
		ClientTarget[client] = War3_GetRandomPlayer( "#t", true, true );
	if( GetClientTeam( client ) == TEAM_CT )
		ClientTarget[client] = War3_GetRandomPlayer( "#ct", true, true );

	if( ClientTarget[client] == 0 || ClientTarget[client] == client )
	{
		PrintHintText( client, "No Target Found" );
	}
	else
	{
		//GetClientAbsOrigin( ClientTarget[client], ClientPos[client] );
		CreateTimer( 3.0, Teleport, client );

		new String:NameAttacker[64];
		GetClientName( client, NameAttacker, 64 );
		
		new String:NameVictim[64];
		GetClientName( ClientTarget[client], NameVictim, 64 );
		
		PrintToChat( ClientTarget[client], "\x05: \x4%s \x03will teleport to you and to aid you in your \x04fight \x03in \x043 \x03seconds", NameAttacker );
		PrintToChat( client, "\x05: \x03You will teleport to \x04%s \x03and aid him/her in thier \x04fight \x03in \x043 \x03seconds", NameVictim );
		
		War3_CooldownMGR( client, 20.0, thisRaceID, ULT_DISCO, true, true);
	}
}

public Action:Teleport( Handle:timer, any:client )
{
	if( ValidPlayer( ClientTarget[client], true ) )
	{
		new Float:ang[3];
		new Float:ClientPos[3];
		GetClientAbsOrigin( ClientTarget[client], ClientPos );
		GetClientEyeAngles( ClientTarget[client], ang);
		TeleportEntity( client, ClientPos, ang, NULL_VECTOR );
	}
	else
	{
		War3_CooldownReset(client, thisRaceID, ULT_DISCO);
		PrintHintText( client, "Your Target Died!" );
	}
}

public War3_GetRandomPlayer( const String:type[], bool:check_alive, bool:check_immunity )
{
	new targettable[MaxClients];
	new target = 0;
	new bool:all;
	new x = 0;
	new team;
	if( StrEqual( type, "#t" ) )
	{
		team = TEAM_T;
		all = false;
	}
	else if( StrEqual( type, "#ct" ) )
	{
		team = TEAM_CT;
		all = false;
	}
	else if( StrEqual( type, "#a" ) )
	{
		team = 0;
		all = true;
	}
	for( new i = 1; i <= MaxClients; i++ )
	{
		if( i > 0 && i <= MaxClients && IsClientConnected( i ) && IsClientInGame( i ) )
		{
			if( check_alive && !IsPlayerAlive( i ) )
				continue;
			if( check_immunity && W3HasImmunity( i, Immunity_Ultimates ) )
				continue;
			if( !all && GetClientTeam( i ) != team )
				continue;
			targettable[x] = i;
			x++;
		}
	}
	for( new y = 0; y <= x; y++ )
	{
		if( target == 0 )
		{
			target = targettable[GetRandomInt( 0, x - 1 )];
		}
		else if( target != 0 && target > 0 )
		{
			return target;
		}
	}
	return 0;
}
