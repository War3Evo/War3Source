#include <sourcemod>
#include "W3SIncs/War3Source_Interface"
#include "W3SIncs/War3Source_CommandHook"

public Plugin:myinfo =
{
  name = "War3Source - Engine - Command Hooks",
  author = "War3Source Team",
  description = "Command Hooks for War3Source"
};

new Handle:Cvar_ChatBlocking;

public OnPluginStart()
{
  Cvar_ChatBlocking=CreateConVar("war3_command_blocking","0","block chat commands from showing up");
}

//insensitive
//say foo
//say /foo
//say \foo
//returns TRUE if found
public bool:CommandCheck(String:compare[],String:commandwanted[])
{
  new String:commandwanted2[70];
  new String:commandwanted3[70];
  Format(commandwanted2,sizeof(commandwanted2),"\\%s",commandwanted);
  Format(commandwanted3,sizeof(commandwanted3),"/%s",commandwanted);
  if(strcmp(compare,commandwanted,false)==0||strcmp(compare,commandwanted2,false)==0||strcmp(compare,commandwanted3,false)==0)
  {
    return true;
  }

  return false;
}

//RETURNS FINAL INTEGER VALUE IN COMMAND
//war3top10 -> 10 if command is "war3top"
//insensitive
//say foo
//say /foo
//say \foo
//returns -1 if NO COMMAND
public CommandCheckEx(String:compare[],String:commandwanted[])
{
  if(StrEqual(commandwanted,"",false))
  {
    return -1;
  }

  new String:commandwanted2[70];
  new String:commandwanted3[70];
  Format(commandwanted2,sizeof(commandwanted2),"\\%s",commandwanted);
  Format(commandwanted3,sizeof(commandwanted3),"/%s",commandwanted);
  if(StrContains(compare,commandwanted,false)==0||StrContains(compare,commandwanted2,false)==0||StrContains(compare,commandwanted3,false)==0)
  {
    ReplaceString(compare,70,commandwanted,"",false);
    ReplaceString(compare,70,commandwanted2,"",false);
    ReplaceString(compare,70,commandwanted3,"",false);
    new val=StringToInt(compare);
    if(val>0)
    {
      return val;
    }
  }
  return -1;
}

public bool:CommandCheckStartsWith(String:compare[],String:commandwanted[])
{
  new String:commandwanted2[70];
  new String:commandwanted3[70];
  Format(commandwanted2,sizeof(commandwanted2),"\\%s",commandwanted);
  Format(commandwanted3,sizeof(commandwanted3),"/%s",commandwanted);
  //matching at == 0 means string is found and is at index 0
  if(StrContains(compare, commandwanted, false)==0||
     StrContains(compare, commandwanted2, false)==0||
     StrContains(compare, commandwanted3, false)==0)
  {
    return true;
  }
  return false;
}

public Action:W3SayAllCommandCheckPost(client,String:WholeString[],String:ChatString[],&DelayChat)
{
  new top_num;

  new Action:returnblocking = (GetConVarInt(Cvar_ChatBlocking)>0)?Plugin_Handled:Plugin_Continue;
  if(CommandCheck(ChatString,"showxp") || CommandCheck(ChatString,"xp"))
  {
    War3_ShowXP(client);
    return returnblocking;
  }
  else if(CommandCheckStartsWith(ChatString,"changerace")||CommandCheckStartsWith(ChatString,"changejob")||CommandCheckStartsWith(ChatString,"cr ")||CommandCheckStartsWith(ChatString,"cj ")||CommandCheck(ChatString,"cr"))
  {

    //index 2 is right after the changerace word
    new String:changeraceArg[32];
    new bool:succ=StrToken(ChatString,2,changeraceArg,sizeof(changeraceArg));
    //DP("%s",changeraceArg);
    new raceFound=0;
    if(succ){

        new String:sRaceName[64];
        new RacesLoaded=War3_GetRacesLoaded();
        SetTrans(client);
        //full name
        for(new race=1;race<=RacesLoaded;race++)
        {
            War3_GetRaceName(race,sRaceName,sizeof(sRaceName));
            if(StrContains(sRaceName,changeraceArg,false)>-1){
                raceFound=race;
                break;
            }
            War3_GetRaceShortname(race,sRaceName,sizeof(sRaceName));
        }
        //shortname
        for(new race=1;raceFound==0&&race<=RacesLoaded;race++)
        {
            War3_GetRaceShortname(race,sRaceName,sizeof(sRaceName));
            if(StrContains(sRaceName,changeraceArg,false)>-1){
                raceFound=race;
                break;
            }
        }
        if(raceFound>0)
        {
            W3UserTriedToSelectRace(client,raceFound,true);
        }
        //no race found, show menu
        else if(!CommandCheckStartsWith(ChatString,"cr"))
        {
            W3CreateEvent(DoShowChangeRaceMenu,client);
        }
    }
    else //no second argument, show menu
    {
        W3CreateEvent(DoShowChangeRaceMenu,client);
    }
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"war3help")||CommandCheck(ChatString,"help")||CommandCheck(ChatString,"wchelp"))
  {
    W3CreateEvent(DoShowHelpMenu,client);
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"war3version"))
  {
    new String:version[64];
    new Handle:g_hCVar = FindConVar("war3_version");
    if(g_hCVar!=INVALID_HANDLE)
    {
      // An Example of Delayed Chat
      GetConVarString(g_hCVar, version, sizeof(version));
      DelayChat=1;
      Format(ChatString, 255, "War3Source Current Version: %s",version);
    }
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"itemsinfo")||CommandCheck(ChatString,"iteminfo"))
  {
    W3CreateEvent(DoShowItemsInfoMenu,client);
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"itemsinfo2")||CommandCheck(ChatString,"iteminfo2"))
  {
    W3CreateEvent(DoShowItems2InfoMenu,client);
    return returnblocking;
  }
  else if(CommandCheckStartsWith(ChatString,"playerinfo"))
  {
    new Handle:array=CreateArray(300);
    PushArrayString(array,ChatString);
    W3SetVar(hPlayerInfoArgStr,array);
    W3CreateEvent(DoShowPlayerinfoEntryWithArg,client);

    CloseHandle(array);
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"raceinfo"))
  {
    W3CreateEvent(DoShowRaceinfoMenu,client);
    return returnblocking;
  }
  else if(CommandCheck(ChatString,"speed"))
  {
    new ClientX=client;
    new bool:SpecTarget=false;
    if(GetClientTeam(client)==1) // Specator
    {
      if (!IsPlayerAlive(client))
      {
        ClientX = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
        if (ClientX == -1)  // if spectator target does not exist then...
        {
          //DP("Spec target does not exist");
          War3_ChatMessage(client,"While being spectator,\nYou must be spectating a player to get player's speed.");
          return returnblocking;
        }
        else
        {
          //DP("Spec target does Exist!");
          SpecTarget=true;
        }
      }
    }
    new Float:currentmaxspeed=GetEntDataFloat(ClientX,War3_GetGame()==Game_TF?FindSendPropOffs("CTFPlayer","m_flMaxspeed"):FindSendPropOffs("CBasePlayer","m_flLaggedMovementValue"));
    if(GameTF())
    {
      if(SpecTarget==true)
      {
        War3_ChatMessage(client,"%T (%.2fx)","Spectating target's max speed is {amount}",client,currentmaxspeed,W3GetSpeedMulti(ClientX));
      }
      else
      {
        War3_ChatMessage(client,"%T (%.2fx)","Your max speed is {amount}",client,currentmaxspeed,W3GetSpeedMulti(client));
      }
    }
    else
    {
      if(SpecTarget==true)
      {
        War3_ChatMessage(client,"%T","Spectating target's max speed is {amount}",client,currentmaxspeed);
      }
      else
      {
        War3_ChatMessage(client,"%T","Your max speed is {amount}",client,currentmaxspeed);
      }
    }
  }
  else if(CommandCheck(ChatString,"maxhp"))
  {
    new maxhp = War3_GetMaxHP(client);
    War3_ChatMessage(client,"%T","Your max health is: {amount}",client,maxhp);
  }
  if(War3_GetRace(client)>0)
  {
    if(CommandCheck(ChatString,"skillsinfo")||CommandCheck(ChatString,"skl"))
    {
      W3ShowSkillsInfo(client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"resetskills"))
    {
      W3CreateEvent(DoResetSkills,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"spendskills"))
    {
      new race=War3_GetRace(client);
      if(W3GetLevelsSpent(client,race)<War3_GetLevel(client,race))
      W3CreateEvent(DoShowSpendskillsMenu,client);
      else
      War3_ChatMessage(client,"%T","You do not have any skill points to spend, if you want to reset your skills use resetskills",client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"shopmenu")||CommandCheck(ChatString,"sh1"))
    {
      W3CreateEvent(DoShowShopMenu,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"shopmenu2")||CommandCheck(ChatString,"sh2"))
    {
      W3CreateEvent(DoShowShopMenu2,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"war3menu")||CommandCheck(ChatString,"w3s")||CommandCheck(ChatString,"wcs"))
    {
      W3CreateEvent(DoShowWar3Menu,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"levelbank"))
    {
      W3CreateEvent(DoShowLevelBank,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"war3rank"))
    {
      if(W3SaveEnabled())
      {
        W3CreateEvent(DoShowWar3Rank,client);
      }
      else
      {
        War3_ChatMessage(client,"%T","This server does not save XP, feature disabled",client);
      }
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"war3stats"))
    {
      W3CreateEvent(DoShowWar3Stats,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"war3dev"))
    {
      War3_ChatMessage(client,"%T","War3Source Developers",client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"myinfo"))
    {
      W3SetVar(EventArg1,client);
      W3CreateEvent(DoShowPlayerInfoTarget,client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"buyprevious")||CommandCheck(ChatString,"bp"))
    {
      War3_RestoreItemsFromDeath(client);
      return returnblocking;
    }
    else if(CommandCheck(ChatString,"myitems"))
    {
      W3SetVar(EventArg1,client);
      W3CreateEvent(DoShowPlayerItemsOwnTarget,client);
      return returnblocking;
    }
    else if((top_num=CommandCheckEx(ChatString,"war3top"))>0)
    {
      if(top_num>100) top_num=100;
      if(W3SaveEnabled())
      {
        W3SetVar(EventArg1,top_num);
        W3CreateEvent(DoShowWar3Top,client);
      }
      else
      {
        War3_ChatMessage(client,"%T","This server does not save XP, feature disabled",client);
      }
      return returnblocking;
    }
    new String:itemshort[100];
    new ItemsLoaded = W3GetItemsLoaded();
    for(new itemid=1;itemid<=ItemsLoaded;itemid++) {
      W3GetItemShortname(itemid,itemshort,sizeof(itemshort));
      if(CommandCheckStartsWith(ChatString,itemshort)&&!W3ItemHasFlag(itemid,"hidden")) {
        W3SetVar(EventArg1,itemid);
        W3SetVar(EventArg2,false); //dont show menu again
        if(CommandCheckStartsWith(ChatString,"tome")) {//item is tome
          new multibuy;
          if( (multibuy=CommandCheckEx(ChatString,"tomes"))>0 || (multibuy=CommandCheckEx(ChatString,"tome"))>0 )
          {
            //            PrintToChatAll("passed commandx");
            if(multibuy>10) multibuy=10;
            for(new i=1;i<multibuy;i++) { //doesnt itterate if its 1
              W3CreateEvent(DoTriedToBuyItem,client);
            }
          }
          else {
            War3_ChatMessage(client,"%T","say tomes5 to buy many tomes at once, up to 10",client);
          }
        }
        W3CreateEvent(DoTriedToBuyItem,client);
        return returnblocking;
      }
    }
  }
  else
  {
    if(CommandCheck(ChatString,"skillsinfo") ||
        CommandCheck(ChatString,"skl") ||
        CommandCheck(ChatString,"resetskills") ||
        CommandCheck(ChatString,"spendskills") ||
        CommandCheck(ChatString,"showskills") ||
        CommandCheck(ChatString,"shopmenu") ||
        CommandCheck(ChatString,"sh1") ||
        CommandCheck(ChatString,"war3menu") ||
        CommandCheck(ChatString,"w3s") ||
        CommandCheck(ChatString,"war3rank") ||
        CommandCheck(ChatString,"war3stats") ||
        CommandCheck(ChatString,"levelbank")||
        CommandCheckEx(ChatString,"war3top")>0)
    {
      if(W3IsPlayerXPLoaded(client))
      {
        War3_ChatMessage(client,"%T","Select a race first!!",client);
        W3CreateEvent(DoShowChangeRaceMenu,client);
      }
      return returnblocking;
    }
  }

  return Plugin_Continue;
}
