#define FILTERSCRIPT
#include <open.mp>
#include <Pawn.CMD>
#include <string>

#define COLOR_SUCCESS 0x00FF00FF
#define COLOR_FAIL 0xFF0000FF

static enum E_STATE {
    E_STATE_VEHICLE_MODEL_ID, Bool:E_STATE_ENABLE_QUICK_KEYS,
    PlayerText3D:E_STATE_3DLABEL_ID,
    Float:E_STATE_POS_X, Float:E_STATE_POS_Y, Float:E_STATE_POS_Z,
    Float:E_STATE_VL_X, Float:E_STATE_VL_Y, Float:E_STATE_VL_Z,
    Float:E_STATE_YAW, Float:E_STATE_HEALTH,
    VEHICLE_PANEL_STATUS:E_STATE_PANEL, VEHICLE_DOOR_STATUS:E_STATE_DOOR,
    VEHICLE_LIGHT_STATUS:E_STATE_LIGHT, VEHICLE_TIRE_STATUS:E_STATE_TIRES,
}

new g_PlayerStates[MAX_PLAYERS][E_STATE];

public OnPlayerConnect(playerid)
{
    g_PlayerStates[playerid][E_STATE_VEHICLE_MODEL_ID] = -1;
    g_PlayerStates[playerid][E_STATE_ENABLE_QUICK_KEYS] = Bool:false;

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (IsValidPlayer3DTextLabel(playerid, PlayerText3D:g_PlayerStates[playerid][E_STATE_3DLABEL_ID])) {
        DeletePlayer3DTextLabel(playerid, PlayerText3D:g_PlayerStates[playerid][E_STATE_3DLABEL_ID]);
    }

    g_PlayerStates[playerid][E_STATE_VEHICLE_MODEL_ID] = -1;
    g_PlayerStates[playerid][E_STATE_ENABLE_QUICK_KEYS] = Bool:false;

    return 1;
}

CMD:quickhome(playerId, params[])
{
    g_PlayerStates[playerId][E_STATE_ENABLE_QUICK_KEYS] = Bool:!g_PlayerStates[playerId][E_STATE_ENABLE_QUICK_KEYS];

    if (g_PlayerStates[playerId][E_STATE_ENABLE_QUICK_KEYS]) {
        SendClientMessage(playerId, COLOR_SUCCESS, "Quick home is ENABLED:");
        SendClientMessage(playerId, COLOR_SUCCESS, "/sethome(onfoot: KEY_YES, driving: KET_SKIP)");
        SendClientMessage(playerId, COLOR_SUCCESS, "/home(driving: KEY_HORN, onfoot: KEY_CROUCH)");
    }
    else {
        SendClientMessage(playerId, COLOR_FAIL, "Quick home is DISABLED.");
    }

    return 1;
}

CMD:sethome(playerId, const params[])
{
    new const PLAYER_STATE:playerState = GetPlayerState(playerId);

    //TODO: need to check the WASTED state
    if (playerState != PLAYER_STATE_ONFOOT && playerState != PLAYER_STATE_DRIVER) {
        SendClientMessage(playerId, COLOR_FAIL, "This command is not available at this time.");
        return 1;
    }

    new const vehicleId = GetPlayerVehicleID(playerId);
    if (vehicleId) {
        g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID] = GetVehicleModel(vehicleId);
        GetVehiclePos(vehicleId, g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z]);
        GetVehicleVelocity(vehicleId, g_PlayerStates[playerId][E_STATE_VL_X], g_PlayerStates[playerId][E_STATE_VL_Y], g_PlayerStates[playerId][E_STATE_VL_Z]);
        GetVehicleZAngle(vehicleId, g_PlayerStates[playerId][E_STATE_YAW]);
        GetVehicleHealth(vehicleId, g_PlayerStates[playerId][E_STATE_HEALTH]);
        GetVehicleDamageStatus(vehicleId, g_PlayerStates[playerId][E_STATE_PANEL], g_PlayerStates[playerId][E_STATE_DOOR],
                               g_PlayerStates[playerId][E_STATE_LIGHT], g_PlayerStates[playerId][E_STATE_TIRES]);
    }
    else {
        g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID] = 0;
        GetPlayerPos(playerId, g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z]);
        GetPlayerVelocity(playerId, g_PlayerStates[playerId][E_STATE_VL_X], g_PlayerStates[playerId][E_STATE_VL_Y], g_PlayerStates[playerId][E_STATE_VL_Z]);
        GetPlayerFacingAngle(playerId, g_PlayerStates[playerId][E_STATE_YAW]);
        GetPlayerHealth(playerId, g_PlayerStates[playerId][E_STATE_HEALTH]);
    }

    if (IsValid3DTextLabel(g_PlayerStates[playerId][E_STATE_3DLABEL_ID])) {
        DeletePlayer3DTextLabel(g_PlayerStates[playerId][E_STATE_3DLABEL_ID]);
    }
    new label_text[32];
    format(label_text, sizeof(label_text), "X:%.2f Y:%.2f Z:%.2f",
           g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z]);
    g_PlayerStates[playerId][E_STATE_3DLABEL_ID] = CreatePlayer3DTextLabel(playerId, label_text, COLOR_SUCCESS,
            g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z], 40.0);

    SendClientMessage(playerId, COLOR_SUCCESS, "Successfully saved the current state!");

    return 1;
}

CMD:home(playerId, const params[])
{
    new const PLAYER_STATE:playerState = GetPlayerState(playerId);

    if (playerState != PLAYER_STATE_ONFOOT && playerState != PLAYER_STATE_DRIVER || g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID] == -1) {
        SendClientMessage(playerId, COLOR_FAIL, "This command is not available at this time.");
        return 1;
    }

    new const vehicleId = GetPlayerVehicleID(playerId);
    if (GetVehicleModel(vehicleId) != g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID]) {
        if (g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID]) {
            SendClientMessage(playerId, COLOR_FAIL, "You must be in the same vehicle as when you saved: %d.", g_PlayerStates[playerId][E_STATE_VEHICLE_MODEL_ID]);
        }
        else {
            SendClientMessage(playerId, COLOR_FAIL, "Your driving status should be the same as when you saved.");
        }
        return 1;
    }

    if (vehicleId) {
        SetVehiclePos(vehicleId, g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z]);
        SetVehicleVelocity(vehicleId, g_PlayerStates[playerId][E_STATE_VL_X], g_PlayerStates[playerId][E_STATE_VL_Y], g_PlayerStates[playerId][E_STATE_VL_Z]);
        SetVehicleZAngle(vehicleId, g_PlayerStates[playerId][E_STATE_YAW]);
        SetVehicleHealth(vehicleId, g_PlayerStates[playerId][E_STATE_HEALTH]);
        UpdateVehicleDamageStatus(vehicleId, g_PlayerStates[playerId][E_STATE_PANEL], g_PlayerStates[playerId][E_STATE_DOOR],
                                  g_PlayerStates[playerId][E_STATE_LIGHT], g_PlayerStates[playerId][E_STATE_TIRES]);
    }
    else {
        SetPlayerPos(playerId, g_PlayerStates[playerId][E_STATE_POS_X], g_PlayerStates[playerId][E_STATE_POS_Y], g_PlayerStates[playerId][E_STATE_POS_Z]);
        SetPlayerVelocity(playerId, g_PlayerStates[playerId][E_STATE_VL_X], g_PlayerStates[playerId][E_STATE_VL_Y], g_PlayerStates[playerId][E_STATE_VL_Z]);
        SetPlayerFacingAngle(playerId, g_PlayerStates[playerId][E_STATE_YAW]);
        SetPlayerHealth(playerId, g_PlayerStates[playerId][E_STATE_HEALTH]);
    }

    SetCameraBehindPlayer(playerId);
    SendClientMessage(playerId, COLOR_SUCCESS, "Successfully backed to previous state!");

    return 1;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if (!g_PlayerStates[playerid][E_STATE_ENABLE_QUICK_KEYS]) return 1;

    if ((KEY:oldkeys & KEY_YES) && !(KEY:newkeys & KEY_YES)) {
        pc_cmd_sethome(playerid, "");
    }
    else if ((KEY:oldkeys & KEY_CROUCH) && !(KEY:newkeys & KEY_CROUCH)) {
        pc_cmd_home(playerid, "");
    }

    return 1;
}