#include <sourcemod>
#include "W3SIncs/War3Source_Interface"
#include "W3SIncs/War3Source_CommandHook"

public Plugin:myinfo =
{
  name = "War3Source - Engine - Command Hooks",
  author = "War3Source Team",
  description = "Command Hooks for War3Source"
};

new Handle:g_OnUltimateCommandHandle;
new Handle:g_OnAbilityCommandHandle;

public OnPluginStart()
{
  RegConsoleCmd("say",War3Source_SayCommand);
  RegConsoleCmd("say_team",War3Source_TeamSayCommand);
  RegConsoleCmd("say",War3Source_SayAllCommand);
  RegConsoleCmd("say_team",War3Source_SayAllCommand);
  RegConsoleCmd("+ultimate",War3Source_UltimateCommand);
  RegConsoleCmd("-ultimate",War3Source_UltimateCommand);
  RegConsoleCmd("+ability",War3Source_NoNumAbilityCommand);
  RegConsoleCmd("-ability",War3Source_NoNumAbilityCommand); //dont blame me if ur race is a failure because theres too much buttons to press
  RegConsoleCmd("+ability1",War3Source_AbilityCommand);
  RegConsoleCmd("-ability1",War3Source_AbilityCommand);
  RegConsoleCmd("+ability2",War3Source_AbilityCommand);
  RegConsoleCmd("-ability2",War3Source_AbilityCommand);
  RegConsoleCmd("+ability3",War3Source_AbilityCommand);
  RegConsoleCmd("-ability3",War3Source_AbilityCommand);
  RegConsoleCmd("+ability4",War3Source_AbilityCommand);
  RegConsoleCmd("-ability4",War3Source_AbilityCommand);

  RegConsoleCmd("ability",War3Source_OldWCSCommand);
  RegConsoleCmd("ability1",War3Source_OldWCSCommand);
  RegConsoleCmd("ability2",War3Source_OldWCSCommand);
  RegConsoleCmd("ability3",War3Source_OldWCSCommand);
  RegConsoleCmd("ability4",War3Source_OldWCSCommand);
  RegConsoleCmd("ultimate",War3Source_OldWCSCommand);

  RegConsoleCmd("shopmenu",War3Source_CmdShopmenu);
}

new Handle:g_hOnW3SayCommandCheckPre;
new Handle:g_hOnW3SayCommandCheckPost;

new Handle:g_hOnW3SayTeamCommandCheckPre;
new Handle:g_hOnW3SayTeamCommandCheckPost;

new Handle:g_hOnW3SayAllCommandCheckPre;
new Handle:g_hOnW3SayAllCommandCheckPost;

public bool:InitNativesForwards()
{
  g_OnUltimateCommandHandle=CreateGlobalForward("OnUltimateCommand",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
  g_OnAbilityCommandHandle=CreateGlobalForward("OnAbilityCommand",ET_Ignore,Param_Cell,Param_Cell,Param_Cell);

  g_hOnW3SayCommandCheckPre       = CreateGlobalForward("W3SayCommandCheckPre", ET_Hook, Param_Cell, Param_Array);
  g_hOnW3SayCommandCheckPost        = CreateGlobalForward("W3SayCommandCheckPost", ET_Hook, Param_Cell, Param_Array);

  g_hOnW3SayTeamCommandCheckPre       = CreateGlobalForward("W3SayTeamCommandCheckPre", ET_Hook, Param_Cell, Param_Array);
  g_hOnW3SayTeamCommandCheckPost        = CreateGlobalForward("W3SayTeamCommandCheckPost", ET_Hook, Param_Cell, Param_Array);

  g_hOnW3SayAllCommandCheckPre       = CreateGlobalForward("W3SayAllCommandCheckPre", ET_Hook, Param_Cell, Param_Array);
  g_hOnW3SayAllCommandCheckPost        = CreateGlobalForward("W3SayAllCommandCheckPost", ET_Hook, Param_Cell, Param_Array);

  return true;
}

public Action:War3Source_CmdShopmenu(client,args)
{
  W3CreateEvent(DoShowShopMenu,client);
  return Plugin_Handled;
}

public Action:War3Source_SayAllCommand(client,args)
{
  decl String:arg1[256]; //was 70
  //decl String:msg[256]; //was 70
  GetCmdArg(1,arg1,sizeof(arg1));
  TrimString(arg1);
  //GetCmdArgString(msg, sizeof(msg));
  //StripQuotes(msg);

  // remove color tags that a player could type in to
  // add color to your chat (bug fixed)
  CRemoveTag2(arg1, sizeof(arg1));

  new Action:returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayAllCommandCheckPre);
  Call_PushCell(client);
  // copyback allows changing of client text on pre
  Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }

  returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayAllCommandCheckPost);
  Call_PushCell(client);
  Call_PushArray(arg1,sizeof(arg1));
  // May want to copy back in the future?
  // for now, no need
  //Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }
  
  return Plugin_Continue;
}

public Action:War3Source_TeamSayCommand(client,args)
{
  decl String:arg1[256]; //was 70
  //decl String:msg[256]; //was 70
  GetCmdArg(1,arg1,sizeof(arg1));
  TrimString(arg1);
  //GetCmdArgString(msg, sizeof(msg));
  //StripQuotes(msg);

  // remove color tags that a player could type in to
  // add color to your chat (bug fixed)
  CRemoveTag2(arg1, sizeof(arg1));

  new Action:returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayTeamCommandCheckPre);
  Call_PushCell(client);
  // copyback allows changing of client text on pre
  Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }

  returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayTeamCommandCheckPost);
  Call_PushCell(client);
  Call_PushArray(arg1,sizeof(arg1));
  // May want to copy back in the future?
  // for now, no need
  //Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }
  
  return Plugin_Continue;
}

public Action:War3Source_SayCommand(client,args)
{
  decl String:arg1[256]; //was 70
  //decl String:msg[256]; //was 70
  GetCmdArg(1,arg1,sizeof(arg1));
  TrimString(arg1);
  //GetCmdArgString(msg, sizeof(msg));
  //StripQuotes(msg);

  // remove color tags that a player could type in to
  // add color to your chat (bug fixed)
  CRemoveTag2(arg1, sizeof(arg1));

  new Action:returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayCommandCheckPre);
  Call_PushCell(client);
  // copyback allows changing of client text on pre
  Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }

  returnVal = Plugin_Continue;
  Call_StartForward(g_hOnW3SayCommandCheckPost);
  Call_PushCell(client);
  Call_PushArray(arg1,sizeof(arg1));
  // May want to copy back in the future?
  // for now, no need
  //Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
  Call_Finish(_:returnVal);
  if(returnVal != Plugin_Continue)
  {
    return Plugin_Handled;
  }

  return Plugin_Continue;
}

public Action:War3Source_UltimateCommand(client,args)
{
  //PrintToChatAll("ult cmd");
  decl String:command[32];
  GetCmdArg(0,command,sizeof(command));

  //PrintToChatAll("%s",command) ;


  //PrintToChatAll("ult cmd2");
  new race=War3_GetRace(client);
  if(race>0)
  {
    //PrintToChatAll("ult cmd3");
    new bool:pressed=false;
    if(StrContains(command,"+")>-1)
      pressed=true;
    Call_StartForward(g_OnUltimateCommandHandle);
    Call_PushCell(client);
    Call_PushCell(race);
    Call_PushCell(pressed);
    new result;
    Call_Finish(result);
    //PrintToChatAll("ult cmd4");
  }

  return Plugin_Handled;
}

public Action:War3Source_AbilityCommand(client,args)
{
  decl String:command[32];
  GetCmdArg(0,command,sizeof(command));

  new bool:pressed=false;
  //PrintToChatAll("%s",command) ;

  if(StrContains(command,"+")>-1)
    pressed=true;
  if(!IsCharNumeric(command[8]))
    return Plugin_Handled;
  new num=_:command[8]-48;
  if(num>0 && num<7)
  {
    Call_StartForward(g_OnAbilityCommandHandle);
    Call_PushCell(client);
    Call_PushCell(num);
    Call_PushCell(pressed);
    new result;
    Call_Finish(result);
  }

  return Plugin_Handled;
}

public Action:War3Source_NoNumAbilityCommand(client,args)
{
  decl String:command[32];
  GetCmdArg(0,command,sizeof(command));
  //PrintToChatAll("%s",command) ;

  new bool:pressed=false;
  if(StrContains(command,"+")>-1)
    pressed=true;
  Call_StartForward(g_OnAbilityCommandHandle);
  Call_PushCell(client);
  Call_PushCell(0);
  Call_PushCell(pressed);
  new result;
  Call_Finish(result);

  return Plugin_Handled;
}

public Action:War3Source_OldWCSCommand(client,args) {
  War3_ChatMessage(client,"%T","The proper commands are +ability, +ability1 ... and +ultimate",client);
}
