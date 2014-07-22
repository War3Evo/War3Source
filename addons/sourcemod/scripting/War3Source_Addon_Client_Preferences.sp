/* ========================================================================== */
/*                                                                            */
/*   War3Source_Addon_Client_Preferences.sp                                   */
/*   (c) 2014 Author   El Diablo                                              */
/*                                                                            */
/*   Description                                                              */
/*                                                                            */
/* ========================================================================== */

#include <clientprefs>
#include <sdktools>
#include "W3SIncs/War3Source_Interface"
new Handle:g_hCookieHud = INVALID_HANDLE;
new Handle:g_hCookieBuffChatInfo = INVALID_HANDLE;
new Handle:g_hCookieBuffChatInfo2 = INVALID_HANDLE;
new Handle:g_hCookieOnDeathMsgDetailed = INVALID_HANDLE;
new Handle:g_hCookieSaySounds = INVALID_HANDLE;
new Handle:g_hIRC = INVALID_HANDLE;
new Handle:g_hPeriodic = INVALID_HANDLE;
new Handle:g_hstats = INVALID_HANDLE;
new Handle:g_hauto = INVALID_HANDLE; 
new Handle:g_hchattext = INVALID_HANDLE;
new Handle:g_hCombatMessages = INVALID_HANDLE;
new Handle:g_hRotateHUD = INVALID_HANDLE;
new Handle:g_hAdminSecurityExtra = INVALID_HANDLE;

public Plugin:myinfo=
{
    name="W3E Addon - Client Preferences",
    author="El Diablo",
    description="War3Source Client Preferences Addon Plugin",
    version="1.0.0.3",
};

public OnPluginStart()
{
    SetCookieMenuItem(War3Prefs, 0, "War3Source Personal Settings");
    
    g_hCookieHud = RegClientCookie("war3source.gold.diamond.hud", "War3Source Gold Diamond Hud", CookieAccess_Public);
    g_hCookieBuffChatInfo = RegClientCookie("war3source.buff.chat.info", "War3Source show buffs on race change", CookieAccess_Public);
    g_hCookieBuffChatInfo2 = RegClientCookie("war3source.buff.chat.info2", "War3Source show buffs during play", CookieAccess_Public);
    g_hCookieOnDeathMsgDetailed = RegClientCookie("war3source.detailed.death.msg", "War3Source Detailed OnDeath Messages", CookieAccess_Public);
    g_hCookieSaySounds = RegClientCookie("war3source.sounds.say.sounds", "War3Source Say Sounds", CookieAccess_Public);
    g_hIRC = RegClientCookie("war3source.IRC", "War3Source IRC Relay", CookieAccess_Public);
    g_hPeriodic = RegClientCookie("war3source.Periodic", "War3Source Periodic Server Advertisements", CookieAccess_Public);
    g_hstats = RegClientCookie("war3source.stats", "War3Source HLStats Messages", CookieAccess_Public);
    g_hauto = RegClientCookie("war3source.autobuylace", "Automatically buy an item at max gold", CookieAccess_Public);
    g_hRotateHUD = RegClientCookie("war3source.rotateHUD", "Automatically rotate gold/diamond/plat HUD", CookieAccess_Public);
    g_hchattext = RegClientCookie("war3source.chattext", "ADMIN/VIP custom chat text", CookieAccess_Public);
    g_hCombatMessages = RegClientCookie("war3source.combatmessages", "Combat Messages", CookieAccess_Public);
    g_hAdminSecurityExtra = RegClientCookie("war3source.admin.security.extra", "Admin Security Messages", CookieAccess_Public);
    AddCommandListener(Command_ShowCookieMenu, "say");
    AddCommandListener(Command_ShowCookieMenu, "say_team");
}
public War3Prefs(client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
    if (action == CookieMenuAction_SelectOption)
    {
        ShowWar3PrefsMenu(client);
    }
}

ShowWar3PrefsMenu(client,page=0)
{

    new Handle:menu = CreateMenu(CallBack_CookieMenuHandler);
    decl String:buffer[100];
    
    Format(buffer, sizeof(buffer), "War3Evo / General Server Settings");
    SetMenuTitle(menu, buffer);

    AddMenuItem(menu, "b", "<- Back To Prefs Menu");
    
    if(W3GetPlayerProp(client,iGoldDiamondHud)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle HUD of Gold/Diamonds/Platinum");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle HUD of Gold/Diamonds/Platinum");
    }
    AddMenuItem(menu, "1", buffer);
    
    if(W3GetPlayerProp(client,iBuffChatInfo)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle War3Source Buff Display on Race Change");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle War3Source Buff Display on Race Change");
    }

    AddMenuItem(menu, "2", buffer);
    
    if(W3GetPlayerProp(client,iDetailedOnDeathMsgs)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle Detailed War3Source Info on Kill/Death");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle Detailed War3Source Info on Kill/Death");
    }
    AddMenuItem(menu, "3", buffer);
    
    if(W3GetPlayerProp(client,iBuffChatInfo2)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle War3Source Buff Display Throughout Game Play");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle War3Source Buff Display Throughout Game Play");
    }   
    
    AddMenuItem(menu, "5", buffer);

    if(W3GetPlayerProp(client,iSaySounds)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle Hearing Say Sounds");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle Hearing Say Sounds");
    }   
    
    AddMenuItem(menu, "6", buffer);
    
    
    if(W3GetPlayerProp(client,iIrcCrossServerChat)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle IRC Cross Server Chat");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle IRC Cross Server Chat");
    }
    
    AddMenuItem(menu, "8", buffer);
    
    
    if(W3GetPlayerProp(client,iServerAds)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle Server Advertisements");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle Server Advertisements");
    }   
    
    AddMenuItem(menu, "9", buffer);
    
    if(W3GetPlayerProp(client,iHlstatsx)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Toggle HLStats Messages");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Toggle HLStats Messages");
    }   
    
    AddMenuItem(menu, "10", buffer);
    
    if(W3GetPlayerProp(client,iAutoBuyMaxGoldItem)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Auto Buy Item at Max Gold");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Auto Buy Item at Max Gold");
    }   
    
    AddMenuItem(menu, "11", buffer);
    
    if(W3GetPlayerProp(client,iRotateHUD)==1)
    {
        Format(buffer, sizeof(buffer), "[MODE=1] Change Currency HUD Display Type");
    } else if (W3GetPlayerProp(client,iRotateHUD)==2) {
        Format(buffer, sizeof(buffer), "[MODE=2] Change Currency HUD Display Type");    
    } else if (W3GetPlayerProp(client,iRotateHUD)==3) {
        Format(buffer, sizeof(buffer), "[MODE=3] ------ Cooldown HUD Display Type");
    } else {
        Format(buffer, sizeof(buffer), "[MODE=4] Change Currency HUD Display Type");
    }   
    
    AddMenuItem(menu, "12", buffer);
    
    new AdminId:ident = GetUserAdmin(client);
    
    if(ident!=INVALID_ADMIN_ID)
    {
        if(W3GetPlayerProp(client,iChatText)==0)
        {
            Format(buffer, sizeof(buffer), "[ON] ADMIN/VIP Chat Text");
        } else {
            Format(buffer, sizeof(buffer), "[OFF] ADMIN/VIP Chat Text");
        }   
        
        AddMenuItem(menu, "13", buffer);
    }
    
    if(W3GetPlayerProp(client,iCombatMessages)==1)
    {
        Format(buffer, sizeof(buffer), "[ON] Combat Messages");
    } else {
        Format(buffer, sizeof(buffer), "[OFF] Combat Messages");
    }   
    
    AddMenuItem(menu, "14", buffer);
    
    if(ident!=INVALID_ADMIN_ID)
    {
        if(W3GetPlayerProp(client,iAdminSecurityExtra)==1)
        {
            Format(buffer, sizeof(buffer), "[ON] ADMIN/VIP F2P/Extra Messages");
        } else {
            Format(buffer, sizeof(buffer), "[OFF] ADMIN/VIP F2P/Extra Messages");
        }   
        
        AddMenuItem(menu, "15", buffer);
    }
    
    new bool:multipage=GetMenuItemCount(menu)>9; 
    if(!multipage){
        SetMenuPagination(menu, MENU_NO_PAGINATION);
    }
    
    SetMenuExitButton(menu, true);
    if(multipage){
        DisplayMenuAtItem(menu, client, page*7, MENU_TIME_FOREVER);
    }else{
        DisplayMenu(menu, client, MENU_TIME_FOREVER);
    }

}

ShowPrefsMenuItemsInfo(client)
{
    ShowCookieMenu(client);
}

public CallBack_CookieMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{

        if(action==MenuAction_Select)
        {
            decl String:info[32];
            if(!GetMenuItem(menu, param2, info, sizeof(info))){
                return;
            }
            if(StrEqual(info, "b")){ 
                ShowCookieMenu(param1);
                return;
            }
            //PrintToServer("info %s",buffer);
            new iTempInt=0;
            decl String:iSTR[5];

            if(StrEqual(info, "1"))   // GOLD DIAMOND HUD 1
            {
                if(W3GetPlayerProp(param1,iGoldDiamondHud)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCookieHud, iSTR);
                W3SetPlayerProp(param1,iGoldDiamondHud,iTempInt);
            } //end of info==1

            if(StrEqual(info, "2"))   // BUFF CHAT INFO
            {
                if(W3GetPlayerProp(param1,iBuffChatInfo)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCookieBuffChatInfo, iSTR);
                W3SetPlayerProp(param1,iBuffChatInfo,iTempInt);
            } //end of info==2

            if(StrEqual(info, "3"))   // DETAILED ON DEATH MSG
            {
                if(W3GetPlayerProp(param1,iDetailedOnDeathMsgs)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCookieOnDeathMsgDetailed, iSTR);
                W3SetPlayerProp(param1,iDetailedOnDeathMsgs,iTempInt);
            } //end of info==3

            if(StrEqual(info, "4"))  // BUFF CHAT INFO 2
            {
                if(W3GetPlayerProp(param1,iBuffChatInfo2)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCookieBuffChatInfo2, iSTR);
                W3SetPlayerProp(param1,iBuffChatInfo2,iTempInt);
            } //end of info==4

            if(StrEqual(info, "6"))  // SAY SOUNDS
            {
                if(W3GetPlayerProp(param1,iSaySounds)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCookieSaySounds, iSTR);
                W3SetPlayerProp(param1,iSaySounds,iTempInt);
            } //end of info==6

            if(StrEqual(info, "8"))   //IRC
            {
                if(W3GetPlayerProp(param1,iIrcCrossServerChat)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hIRC, iSTR);
                W3SetPlayerProp(param1,iIrcCrossServerChat,iTempInt);
            }

            if(StrEqual(info, "9"))   // SERVER ADVERTISMENTS
            {
                if(W3GetPlayerProp(param1,iServerAds)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hPeriodic, iSTR);
                W3SetPlayerProp(param1,iServerAds,iTempInt);
            }

            if(StrEqual(info, "10"))    // HLSTATSX
            {
                if(W3GetPlayerProp(param1,iHlstatsx)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hstats, iSTR);
                W3SetPlayerProp(param1,iHlstatsx,iTempInt);
            }

            if(StrEqual(info, "11"))      // AUTO BUY MAX GOLD
            {
                if(W3GetPlayerProp(param1,iAutoBuyMaxGoldItem)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hauto, iSTR);
                W3SetPlayerProp(param1,iAutoBuyMaxGoldItem,iTempInt);
            }

            if(StrEqual(info, "12"))      // ROTATE HUD
            {
                if(W3GetPlayerProp(param1,iRotateHUD)==0)
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                else if(W3GetPlayerProp(param1,iRotateHUD)==1) 
                {
                    iTempInt = 2;
                    strcopy(iSTR,sizeof(iSTR),"2");                 
                }
                else if(W3GetPlayerProp(param1,iRotateHUD)==2) 
                {
                    iTempInt = 3;
                    strcopy(iSTR,sizeof(iSTR),"3");                 
                }
                else
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                SetClientCookie(param1, g_hRotateHUD, iSTR);
                W3SetPlayerProp(param1,iRotateHUD,iTempInt);
            }

            
            if(StrEqual(info, "13"))      // ADMIN / VIP chat text
            {
                if(W3GetPlayerProp(param1,iChatText)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hchattext, iSTR);
                W3SetPlayerProp(param1,iChatText,iTempInt);
            }
            
            if(StrEqual(info, "14"))      // ADMIN / VIP chat text
            {
                if(W3GetPlayerProp(param1,iCombatMessages)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hCombatMessages, iSTR);
                W3SetPlayerProp(param1,iCombatMessages,iTempInt);
            }

            if(StrEqual(info, "15"))      // ADMIN Security Extra
            {
                if(W3GetPlayerProp(param1,iAdminSecurityExtra)==1)
                {
                    iTempInt = 0;
                    strcopy(iSTR,sizeof(iSTR),"0");
                }
                else
                {
                    iTempInt = 1;
                    strcopy(iSTR,sizeof(iSTR),"1");
                }
                SetClientCookie(param1, g_hAdminSecurityExtra, iSTR);
                W3SetPlayerProp(param1,iAdminSecurityExtra,iTempInt);
            }

            ShowWar3PrefsMenu(param1);
        }
}

public Action:W3SayAllCommandCheckPre(client,String:WholeString[],String:ChatString[])
{
    if (StrEqual(WholeString, "prefs", false)||StrEqual(WholeString, "!prefs", false)||StrEqual(WholeString, "/prefs", false)||StrEqual(WholeString, "preps", false))
    {
        ShowPrefsMenuItemsInfo(client);
        return Plugin_Handled;
    }
    if (StrEqual(WholeString, "cooldownhud", false)||StrEqual(WholeString, "!cooldownhud", false))
    {
        SetCoolDownHud(client);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action:Command_ShowCookieMenu(client, const String:command[], args)
{
    if(!client) return Plugin_Continue;
    
    decl String:szArg[255];
    GetCmdArgString(szArg, sizeof(szArg));

    StripQuotes(szArg);
    TrimString(szArg);  

    if (StrEqual(szArg, "prefs", false)||StrEqual(szArg, "!prefs", false)||StrEqual(szArg, "/prefs", false)||StrEqual(szArg, "preps", false))
    {
        ShowPrefsMenuItemsInfo(client);
        //PrintToChatAll("Debug show cookie menu");

        return Plugin_Handled;
    }
    if (StrEqual(szArg, "cooldownhud", false)||StrEqual(szArg, "!cooldownhud", false))
    {
        SetCoolDownHud(client);
        return Plugin_Handled;
    }   

    return Plugin_Continue;
}


public doZeroes(iClient) 
{
    W3SetPlayerProp(iClient,iGoldDiamondHud,0);
    W3SetPlayerProp(iClient,iBuffChatInfo,0);
    W3SetPlayerProp(iClient,iDetailedOnDeathMsgs,0);
    W3SetPlayerProp(iClient,iBuffChatInfo2,0);
    W3SetPlayerProp(iClient,iSaySounds,0);
    W3SetPlayerProp(iClient,iHlstatsx,0);
    W3SetPlayerProp(iClient,iAutoBuyMaxGoldItem,0);
    W3SetPlayerProp(iClient,iChatText,0);
    W3SetPlayerProp(iClient,iCombatMessages,0);
    W3SetPlayerProp(iClient,iServerAds,0);
    W3SetPlayerProp(iClient,iIrcCrossServerChat,0);
    W3SetPlayerProp(iClient,iRotateHUD,0);
    W3SetPlayerProp(iClient,iAdminSecurityExtra,0);
}

public doDefaults(iClient)
{
    W3SetPlayerProp(iClient,iGoldDiamondHud,1);
    W3SetPlayerProp(iClient,iBuffChatInfo,0);
    W3SetPlayerProp(iClient,iDetailedOnDeathMsgs,0);
    W3SetPlayerProp(iClient,iBuffChatInfo2,0);
    W3SetPlayerProp(iClient,iSaySounds,1);
    W3SetPlayerProp(iClient,iHlstatsx,1);
    W3SetPlayerProp(iClient,iAutoBuyMaxGoldItem,1);
    W3SetPlayerProp(iClient,iChatText,0);
    W3SetPlayerProp(iClient,iCombatMessages,1);
    W3SetPlayerProp(iClient,iServerAds,1);
    W3SetPlayerProp(iClient,iIrcCrossServerChat,1);
    W3SetPlayerProp(iClient,iRotateHUD,1);
    W3SetPlayerProp(iClient,iAdminSecurityExtra,1);
}

public OnClientDisconnect(iClient)
{
    if(IsFakeClient(iClient))
    {
        doZeroes(iClient);
        return;
    }
    //DEFAULTS
    doDefaults(iClient);
}

public OnClientCookiesCached(client)
{
    // Initializations and preferences loading
    loadClientCookiesFor(client);   
}

loadClientCookiesFor(iClient)
{
        if(IsFakeClient(iClient))
        {
            doZeroes(iClient);
            return;
        }
        //DEFAULTS
        //PrintToServer("SETTING CLIENT COOKIES DEFAULT");
        doDefaults(iClient);

        decl String:buffer[5];
    
        //PrintToServer("LOAD CLIENT COOKIES");

        // GOLD / DIAMOND / PLATINUM HUD
        GetClientCookie(iClient, g_hCookieHud, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iGoldDiamondHud,iTempInt);
            //PrintToServer("USER PREF: GOLD DIAMOND HUD %d",W3GetPlayerProp(iClient,iGoldDiamondHud));
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iGoldDiamondHud,1);
            //PrintToServer("DEFAULT: GOLD DIAMOND HUD %d",W3GetPlayerProp(iClient,iGoldDiamondHud));
        }
        
        // BUFF CHAT INFORMATION MESSAGES on job change
        GetClientCookie(iClient, g_hCookieBuffChatInfo, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iBuffChatInfo,iTempInt);
            //PrintToServer("USER PREF: BUFF CHAT INFO1 %d",W3GetPlayerProp(iClient,iBuffChatInfo));
        }
        else
        {
            //default  0
            W3SetPlayerProp(iClient,iBuffChatInfo,0);
            //PrintToServer("DEFAULT: BUFF CHAT INFO1 %d",W3GetPlayerProp(iClient,iBuffChatInfo));
        }
        

        // DETAILED ON DEATH MESSAGES
        GetClientCookie(iClient, g_hCookieOnDeathMsgDetailed, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iDetailedOnDeathMsgs,iTempInt);
            //PrintToServer("USE PREF: ON DEATH MESSAGES %d",W3GetPlayerProp(iClient,iDetailedOnDeathMsgs));
        }
        else
        {
            //default   0
            W3SetPlayerProp(iClient,iDetailedOnDeathMsgs,0);
            //PrintToServer("DEFAULT: ON DEATH MESSAGES %d",W3GetPlayerProp(iClient,iDetailedOnDeathMsgs));
        }


        // BUFF CHAT INFORMATION MESSAGES during play
        GetClientCookie(iClient, g_hCookieBuffChatInfo2, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iBuffChatInfo2,iTempInt);
            //PrintToServer("USE PREF: BUFF CHAT INFORMATION MESSAGES during play %d",W3GetPlayerProp(iClient,iBuffChatInfo2));
        }
        else
        {
            //default   0
            W3SetPlayerProp(iClient,iBuffChatInfo2,0);
            //PrintToServer("DEFAULT: BUFF CHAT INFORMATION MESSAGES during play %d",W3GetPlayerProp(iClient,iBuffChatInfo2));
        }

        // SAY SOUNDS
        GetClientCookie(iClient, g_hCookieSaySounds, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iSaySounds,iTempInt);
            //PrintToServer("USE PREF: SAY SOUNDS %d",W3GetPlayerProp(iClient,iSaySounds));
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iSaySounds,1);
            //PrintToServer("DEFAULT: SAY SOUNDS %d",W3GetPlayerProp(iClient,iSaySounds));
        }

        // HLSTATSX
        GetClientCookie(iClient, g_hstats, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iHlstatsx,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iHlstatsx,1);
        }

        // AUTO BUY MAX GOLD
        GetClientCookie(iClient, g_hauto, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iAutoBuyMaxGoldItem,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iAutoBuyMaxGoldItem,1);
        }

        // SERVER ADVERTISMENTS
        GetClientCookie(iClient, g_hPeriodic, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iServerAds,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iServerAds,1);
        }

        // IRC CROSS CHAT
        GetClientCookie(iClient, g_hIRC, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iIrcCrossServerChat,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iIrcCrossServerChat,1);
        }

        // ROTATE HUD
        GetClientCookie(iClient, g_hRotateHUD, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iRotateHUD,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iRotateHUD,1);
        }
        
        // VIP / ADMIN CHAT 
        GetClientCookie(iClient, g_hchattext, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iChatText,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iChatText,0);
        }

        // COMBAT MESSAGES
        GetClientCookie(iClient, g_hCombatMessages, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iCombatMessages,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iCombatMessages,1);
        }

        // ADMIN Security Extra
        GetClientCookie(iClient, g_hAdminSecurityExtra, buffer, 5);
        if(!StrEqual(buffer, ""))
        {
            new iTempInt = StringToInt(buffer);
            W3SetPlayerProp(iClient,iAdminSecurityExtra,iTempInt);
        }
        else
        {
            //default  1
            W3SetPlayerProp(iClient,iAdminSecurityExtra,1);
        }
        //PrintToServer("END OF: SETTING CLIENT COOKIES DEFAULT");
}

SetCoolDownHud(client)
{
    if(W3GetPlayerProp(client,iGoldDiamondHud)!=1 || W3GetPlayerProp(client,iRotateHUD)!=3)
    {
        W3SetPlayerProp(client,iGoldDiamondHud,1);
        W3SetPlayerProp(client,iRotateHUD,3);
        PrintToChat(client,"Cooldown HUD now ON.");
    }
    else if(W3GetPlayerProp(client,iGoldDiamondHud)==1 && W3GetPlayerProp(client,iRotateHUD)==3)
    {
        W3SetPlayerProp(client,iGoldDiamondHud,0);
        W3SetPlayerProp(client,iRotateHUD,3);
        PrintToChat(client,"Cooldown HUD now OFF.");
    }
}
