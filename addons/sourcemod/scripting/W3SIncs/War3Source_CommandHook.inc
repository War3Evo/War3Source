/**
* File: 
* CommandHook is now extendable for future addons
*
* In order to use these natives, you must include this file in your sourcecode.
* 
*/

/* 
 * Allow you to capture only Say
 * 
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 * 
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 * 
*/
forward Action:W3SayCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:W3SayCommandCheckPost(client,String:WholeString[],String:ChatString[]);

/* 
 * Allow you to capture only Team Say
 * 
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 * 
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 * 
*/
forward Action:W3SayTeamCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:W3SayTeamCommandCheckPost(client,String:WholeString[],String:ChatString[]);

/* 
 * Allow you to capture both Team Say and Say commands
 *
 * This is called last.
 *
 * Both W3SayCommandCheck* and W3SayTeamCommandCheck* get called first,
 * Then SayAll is called last.
 *
 * All of the chat commands are in the SayAll.   So, if your addon wants to catch a command
 * before it is actually handled, use W3SayCommandCheck* or W3SayTeamCommandCheck* or
 * W3SayAllCommandCheckPre first and return Plugin_Handled.
 *
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 * 
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 *
 * If you need you message have a extra 1 second delay, you can add it, but
 * most of the War3_ChatMessages have a 0.5 second delay added to them for single
 * clients.
 *
 * DelayChat is a hack to display your return chat message back to the player
 * without the chat being before their typed text.   This will help prevent confusion
 * when the player is looking for certain information.
 * 
 * DelayChat lets you change WholeString or ChatString and depending on the one you choose
 * return 0 for WholeString or return 1 for ChatString and it will delay chat so
 * that your message will be after they type thier command into chat.
 * 
*/
forward Action:W3SayAllCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:W3SayAllCommandCheckPost(client,String:WholeString[],String:ChatString[],&DelayChat);
