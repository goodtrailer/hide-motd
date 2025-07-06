#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "hide-motd",
    author = "goodtrailer, Bacardi",
    description = "Hides the MOTD window.",
    version = "2025.705.0",
    url = "https://github.com/goodtrailer/hide_motd"
};

public void OnPluginStart()
{
    HookUserMessage(GetUserMessageId("VGUIMenu"), onVGUIMenu, true);
}

public void OnClientPutInServer(int client)
{
    CreateTimer(1.0, teamMenu, client, TIMER_FLAG_NO_MAPCHANGE);
}

void teamMenu(Handle timer, int client)
{
    if (IsFakeClient(client))
        return;
    ShowVGUIPanel(client, "team", INVALID_HANDLE, true);
}

Action onVGUIMenu(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
    char buffer[5];
    BfReadString(msg, buffer, sizeof(buffer));
    return StrEqual(buffer, "info") ? Plugin_Handled : Plugin_Continue;
}
