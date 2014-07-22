#define PLUGIN_VERSION "0.0.1.0 (12/15/2013)"

#pragma semicolon 1    ///WE RECOMMEND THE SEMICOLON

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

new bool:Autobuy[MAXPLAYERSCUSTOM];

public Plugin:myinfo= 
{
    name="W3S Addon Autobuy",
    author="El Diablo",
    description="W3S Addon Autobuy",
    version="1.0",
    url="http://war3evo.info/"
};

//new Handle:hEnableAutobuy;
new Handle:Cvar_ChatBlocking;

public OnPluginStart()
{
    CreateConVar("war3source_autobuy",PLUGIN_VERSION,"War3Source autobuy system",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    //hEnableAutobuy = CreateConVar("war3_autobuy_enable", "0", "Enable/Disable(1/0) autobuy");
}

public OnAllPluginsLoaded()
{
    Cvar_ChatBlocking = FindConVar("war3_command_blocking");
}

public OnWar3PlayerAuthed(client)
{
    if(ValidPlayer(client))
    {
        Autobuy[client]=false;
    }
}

public OnClientDisconnect(client)
{
    Autobuy[client]=false;
}

public OnWar3EventSpawn(client)
{
    if(Autobuy[client])
    {
        War3_RestoreItemsFromDeath(client,true);
    }
}

public Action:W3SayAllCommandCheckPost(client,String:WholeString[],String:ChatString[],&DelayChat)
{
    new Action:returnblocking = Plugin_Continue;
    
    if(Cvar_ChatBlocking!=INVALID_HANDLE)
    {
        returnblocking = (GetConVarInt(Cvar_ChatBlocking)>0)?Plugin_Handled:Plugin_Continue;
    }
    
    if (StrEqual(ChatString,"autobuy",false)||StrEqual(ChatString,"!autobuy",false))
    {
        Autobuy[client]=!Autobuy[client];
        // An example of DelayChat
        DelayChat=1;
        Format(ChatString, 255, " {olive}Autobuy toggled %s", Autobuy[client] ? "on" : "off");
        return returnblocking;
    }
    if (StrEqual(ChatString,"/autobuy",false))
    {
        Autobuy[client]=!Autobuy[client];
        War3_ChatMessage(client, " {olive}Autobuy toggled %s", Autobuy[client] ? "on" : "off");
        return Plugin_Handled;
    }
    return  Plugin_Continue;
}
