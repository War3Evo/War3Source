#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo =
{
    name = "WCX Bash",
    author = "El Diablo",
    description = "WCX Teleport",
    version = "0.1",
    url = "http://war3evo.info"
}

enum W3TeleportProp
{
    tele_target,
    Float:tele_target_ScaleVector_distance,
    Float:tele_distance,
    tele_raceid,
    tele_skillid
}

new String:teleportSound[]="war3source/blinkarrival.mp3";

new PlayerProp[MAXPLAYERSCUSTOM][W3TeleportProp];

new ClientTracer;
new Float:emptypos[3];
new Float:oldpos[MAXPLAYERSCUSTOM][3];
new Float:teleportpos[MAXPLAYERSCUSTOM][3];
new bool:inteleportcheck[MAXPLAYERSCUSTOM];

new Handle:g_OnW3TeleportGetAngleVectorsPre;
new Handle:g_OnW3TeleportEntityCustom;
new Handle:g_OnW3TeleportLocationChecking;
new Handle:g_OnW3Teleported;

public bool:InitNativesForwards()
{
    CreateNative("W3Teleport", Native_War3_Teleport);
    MarkNativeAsOptional("W3Teleport");

    g_OnW3Teleported=CreateGlobalForward("OnW3Teleported",ET_Ignore,Param_Cell,Param_Cell,Param_Float,Param_Cell,Param_Cell);

    g_OnW3TeleportGetAngleVectorsPre=CreateGlobalForward("OnW3TeleportGetAngleVectorsPre",ET_Hook,Param_Cell,Param_Cell,Param_Array);

    g_OnW3TeleportEntityCustom=CreateGlobalForward("OnW3TeleportEntityCustom",ET_Hook,Param_Cell,Param_Cell,Param_Array,Param_Array);

    g_OnW3TeleportLocationChecking=CreateGlobalForward("OnW3TeleportLocationChecking",ET_Hook,Param_Cell,Param_Array);

    return true;
}

public OnAddSound(sound_priority)
{
    if(sound_priority==PRIORITY_MEDIUM)
    {
        War3_AddSound(teleportSound);
    }
}

public Native_War3_Teleport(Handle:plugin, numParams)
{
    new client = GetNativeCell(1);
    if(ValidPlayer(client))
    {
        PlayerProp[client][tele_target] = GetNativeCell(2);
        PlayerProp[client][tele_target_ScaleVector_distance] = Float:GetNativeCell(3);
        PlayerProp[client][tele_distance] = Float:GetNativeCell(4);
        PlayerProp[client][tele_raceid] = GetNativeCell(5);
        PlayerProp[client][tele_skillid] = GetNativeCell(6);

        Teleport(client,PlayerProp[client][tele_target],PlayerProp[client][tele_target_ScaleVector_distance],PlayerProp[client][tele_distance]);
    }
}


bool:Teleport(client,target,Float:ScaleVectorDistance,Float:distance)
{
    if(!inteleportcheck[client])
    {
        if(target>-1 && !ValidPlayer(target,true))
        {
            return false;
        }
        new Float:angle[3];
        new Float:endpos[3];
        new Float:startpos[3];
        new Float:clientpos[3];
        if(target>-1)
        {
            GetClientEyePosition(target,startpos);
            GetClientEyePosition(client,clientpos);
        }
        else
        {
            GetClientEyePosition(client,startpos);
        }
        new Float:dir[3];

        new Action:returnVal = Plugin_Continue;
        Call_StartForward(g_OnW3TeleportGetAngleVectorsPre);
        Call_PushCell(client);
        Call_PushCell(target);
        Call_PushArrayEx(angle,sizeof(angle),SM_PARAM_COPYBACK);
        Call_Finish(_:returnVal);
        if(returnVal == Plugin_Continue)
        {
            GetClientEyeAngles(client,angle);
        }

        GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
        if(ScaleVectorDistance>-1.0)
        {
            ScaleVector(dir, ScaleVectorDistance);
        }
        else
        {
            ScaleVector(dir, distance);
        }

        AddVectors(startpos, dir, endpos);

        GetClientAbsOrigin(client,oldpos[client]);


        if(target>-1)
        {
            ClientTracer=target;
        }
        else
        {
            ClientTracer=client;
        }
        TR_TraceRayFilter(startpos,endpos,MASK_ALL,RayType_EndPoint,AimTargetFilter);
        TR_GetEndPosition(endpos);

        if(enemyImmunityInRange(client,endpos)){
            W3MsgEnemyHasImmunity(client);
            return false;
        }

        new Float:distanceteleport;
        new Float:distanceteleport2;

        if(target>-1)
        {
            distanceteleport=GetVectorDistance(startpos,endpos);
            distanceteleport2=GetVectorDistance(clientpos,startpos);
            if(distanceteleport2 > distance){
                new String:buffer[100];
                Format(buffer, sizeof(buffer), "You are too far away from your target!");
                //DP("%f > %f",distanceteleport,distance);
                PrintHintText(client,buffer);
                return false;
            }
            if(distanceteleport2<200.0){
                new String:buffer[100];
                Format(buffer, sizeof(buffer), "You are too close too teleport!");
                PrintHintText(client,buffer);
                return false;
            }
        }
        else
        {
            distanceteleport=GetVectorDistance(startpos,endpos);
            if(distanceteleport<200.0){
                new String:buffer[100];
                Format(buffer, sizeof(buffer),"Distance too short.");
                PrintHintText(client,buffer);
                return false;
            }
        }

        GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);///get dir again
        ScaleVector(dir, distanceteleport-33.0);

        AddVectors(startpos,dir,endpos);
        emptypos[0]=0.0;
        emptypos[1]=0.0;
        emptypos[2]=0.0;

        endpos[2]-=30.0;
        getEmptyLocationHull(client,endpos);

        if(GetVectorLength(emptypos)<1.0){
            new String:buffer[100];
            Format(buffer, sizeof(buffer), "No empty location found");
            PrintHintText(client,buffer);
            return false; //it returned 0 0 0
        }

        returnVal = Plugin_Continue;
        Call_StartForward(g_OnW3TeleportEntityCustom);
        Call_PushCell(client);
        Call_PushCell(target);
        Call_PushArray(dir,sizeof(dir));
        Call_PushArray(emptypos,sizeof(emptypos));
        Call_Finish(_:returnVal);
        if(returnVal == Plugin_Continue)
        {
            TeleportEntity(client,emptypos,NULL_VECTOR,NULL_VECTOR);
        }

        EmitSoundToAll(teleportSound,client);
        EmitSoundToAll(teleportSound,client);

        teleportpos[client][0]=emptypos[0];
        teleportpos[client][1]=emptypos[1];
        teleportpos[client][2]=emptypos[2];

        inteleportcheck[client]=true;
        CreateTimer(0.14,checkTeleport,client);

        return true;
    }

    return false;
}

public Action:checkTeleport(Handle:h,any:client){
    inteleportcheck[client]=false;
    new Float:pos[3];

    GetClientAbsOrigin(client,pos);

    if(GetVectorDistance(teleportpos[client],pos)<0.001)//he didnt move in this 0.1 second
    {
        TeleportEntity(client,oldpos[client],NULL_VECTOR,NULL_VECTOR);
        PrintHintText(client,"Cannot teleport there");
        if(PlayerProp[client][tele_raceid]>-1 && PlayerProp[client][tele_skillid]>-1)
        {
            War3_CooldownReset(client,PlayerProp[client][tele_raceid],PlayerProp[client][tele_skillid]);
        }
    }
    else
    {
        PrintHintText(client,"Teleported!");

        Call_StartForward(g_OnW3Teleported);
        Call_PushCell(client);
        Call_PushCell(PlayerProp[client][tele_target]);
        Call_PushFloat(PlayerProp[client][tele_distance]);
        Call_PushCell(PlayerProp[client][tele_raceid]);
        Call_PushCell(PlayerProp[client][tele_skillid]);
        Call_Finish();
    }
    return Plugin_Continue;
}

public bool:AimTargetFilter(entity,mask)
{
    return !(entity==ClientTracer);
}


//new absincarray[]={0,4,-4,8,-8,12,-12,18,-18,22,-22,25,-25};//,27,-27,30,-30,33,-33,40,-40}; //for human it needs to be smaller
new absincarray[]={0,4,-4,8,-8,12,-12,18,-18,22,-22,25,-25,27,-27,30,-30,33,-33,40,-40,-50,-75,-90,-110}; //for human it needs to be smaller

public bool:getEmptyLocationHull(client,Float:originalpos[3]){


    new Float:mins[3];
    new Float:maxs[3];
    GetClientMins(client,mins);
    GetClientMaxs(client,maxs);

    new absincarraysize=sizeof(absincarray);

    new limit=5000;
    for(new x=0;x<absincarraysize;x++){
        if(limit>0){
            for(new y=0;y<=x;y++){
                if(limit>0){
                    for(new z=0;z<=y;z++){
                        new Float:pos[3]={0.0,0.0,0.0};
                        AddVectors(pos,originalpos,pos);
                        pos[0]+=float(absincarray[x]);
                        pos[1]+=float(absincarray[y]);
                        pos[2]+=float(absincarray[z]);

                        TR_TraceHullFilter(pos,pos,mins,maxs,MASK_SOLID,CanHitThis,client);
                        //new ent;
                        if(!TR_DidHit(_))
                        {
                            AddVectors(emptypos,pos,emptypos); ///set this gloval variable
                            limit=-1;
                            break;
                        }

                        if(limit--<0){
                            break;
                        }
                    }

                    if(limit--<0){
                        break;
                    }
                }
            }

            if(limit--<0){
                break;
            }

        }

    }

}

public bool:CanHitThis(entityhit, mask, any:data)
{
    if(entityhit == data )
    {// Check if the TraceRay hit the itself.
        return false; // Don't allow self to be hit, skip this result
    }
    if(ValidPlayer(entityhit)&&ValidPlayer(data)&&GetClientTeam(entityhit)==GetClientTeam(data)){
        return false; //skip result, prend this space is not taken cuz they on same team
    }
    return true; // It didn't hit itself
}


public bool:enemyImmunityInRange(client,Float:playerVec[3])
{
    new Action:returnVal = Plugin_Continue;
    Call_StartForward(g_OnW3TeleportLocationChecking);
    Call_PushCell(client);
    Call_PushArray(playerVec, sizeof(playerVec));
    Call_Finish(_:returnVal);
    if(returnVal != Plugin_Continue)
    {
        return true;
    }
    return false;
}
