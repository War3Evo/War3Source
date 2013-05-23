#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
    name = "War3Source - Engine - Money",
    author = "War3Source Team",
    description = "Handle money related things"
};

new Handle:g_hCurrencyMode;
new W3CurrencyMode:g_CurrencyMode;

new Handle:g_hMaxCurrency;
new g_MaxCurrency;

public OnPluginStart()
{
    g_hCurrencyMode = CreateConVar("war3_currency_mode", "0", "Configure the currency that should be used. 0 - war3 gold, 1 - Counter-Strike $ / Team Fortress 2 MVM $");
    g_hMaxCurrency = CreateConVar("war3_max_currency", GAMECSANY ? "16000" : "100", "Configure the maximum amount of currency a player can hold.");
    
    HookConVarChange(g_hCurrencyMode, OnCurrencyModeChanged);
    HookConVarChange(g_hMaxCurrency, OnMaxCurrencyChanged);
}

public bool:InitNativesForwards()
{
    CreateNative("War3_GetCurrencyMode", Native_War3_GetCurrencyMode);
    CreateNative("War3_GetMaxCurrency", Native_War3_GetMaxCurrency);
    CreateNative("War3_GetCurrency", Native_War3_GetCurrency);
    CreateNative("War3_SetCurrency", Native_War3_SetCurrency);
    
    return true;
}

public OnCurrencyModeChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
    g_CurrencyMode = W3CurrencyMode:StringToInt(newValue);
}

public OnMaxCurrencyChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
    g_MaxCurrency = StringToInt(newValue);
}

public Native_War3_GetCurrencyMode(Handle:plugin, numParams)
{
    return _:g_CurrencyMode;
}

public Native_War3_GetMaxCurrency(Handle:plugin, numParams)
{
    return g_MaxCurrency;
}

public Native_War3_GetCurrency(Handle:plugin, numParams)
{
    new client = GetNativeCell(0);
    
    return GetCurrency(client);
}

public Native_War3_SetCurrency(Handle:plugin, numParams)
{
    new client = GetNativeCell(0);
    new newCurrency = GetNativeCell(1);
    
    SetCurrency(client, newCurrency);
}

GetCurrency(client)
{
    if (g_CurrencyMode == CURRENCY_MODE_WAR3_GOLD)
    {
        return W3GetPlayerProp(client, PlayerGold);
    }
    else if (g_CurrencyMode == CURRENCY_MODE_DORRAR)
    {
        if(GAMECSANY)
        {
            return GetEntProp(client, Prop_Send, "m_iAccount");
        } 
        else if (GAMETF) 
        {
            return GetEntProp(client, Prop_Send, "m_nCurrency");
        }
    }

    return 0;
}

SetCurrency(client, newCurrency)
{
    if(newCurrency > g_MaxCurrency)
    {
        newCurrency = g_MaxCurrency;
    }
    
    if (g_CurrencyMode == CURRENCY_MODE_WAR3_GOLD)
    {
        W3SetPlayerProp(client, PlayerGold, newCurrency);
    }
    else if (g_CurrencyMode == CURRENCY_MODE_DORRAR)
    {
        if(GAMECSANY)
        {
            SetEntProp(client, Prop_Send, "m_iAccount", newCurrency);
        } 
        else if (GAMETF) 
        {
            SetEntProp(client, Prop_Send, "m_nCurrency", newCurrency);
        }
    }
}