/**
* File: 
* CommandHook is now extendable for future addons
*/

/* 
 * Allow you to capture only Say
 * 
*/
forward Action:W3SayCommandCheckPre(client,String:ChatString[]);
forward Action:W3SayCommandCheckPost(client,String:ChatString[]);

/* 
 * Allow you to capture only Team Say
 * 
*/
forward Action:W3SayTeamCommandCheckPre(client,String:ChatString[]);
forward Action:W3SayTeamCommandCheckPost(client,String:ChatString[]);

/* 
 * Allow you to capture both Team Say and Say commands
 * 
*/
forward Action:W3SayAllCommandCheckPre(client,String:ChatString[]);
forward Action:W3SayAllCommandCheckPost(client,String:ChatString[]);
