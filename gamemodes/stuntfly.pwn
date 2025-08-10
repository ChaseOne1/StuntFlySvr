#include <open.mp>
#include <Pawn.CMD>
#include <sscanf2>
#include <mapandreas>

#define MAX_RCP 200
#define MAX_RACE 9999

//���ڴ洢��������
enum E_RCP_DATA {
    Float:posx[MAX_RCP],
    Float:posy[MAX_RCP],
    Float:posz[MAX_RCP],
    Float:nextx[MAX_RCP],
    Float:nexty[MAX_RCP],
    Float:nextz[MAX_RCP],
    type[MAX_RCP],
    size[MAX_RCP],
    enable[MAX_RCP]
}

new g_PlayerLastVeh[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... };

CMD:ok(playerid, params[])
{
    SetPVarInt(playerid, "ok", 1);
    return 1;
}

new RcpData[MAX_PLAYERS + 1][E_RCP_DATA];

CMD:saverace(playerid, params[])
{
    new race_file_name[24];
    if (sscanf(params, "s[24]", race_file_name)) {
        SendClientMessage(playerid, 0x7b8cdeff, "/saverace [����] - ��������");
        return 1;
    }
    if (RcpData[playerid][enable][0] == 0) {
        SendClientMessage(playerid, 0xe4026fff, "��⵽���0�ż���û�����ݡ���ȷ��������һ�����㣬���߼���Ľڵ������Ҫ��0��ʼ������");
        return 1;
    }
    if (GetPVarInt(playerid, "ok") == 0) {
        SendClientMessage(playerid, 0xe4026fff, "����ȥ����Ҫ����������λ�òȵ��ٱ������������������� /ok �ٱ������� ��");
        SendClientMessage(playerid, 0xe4026fff, "�����߿���ķ����ǿ�ʼ������ɻ��ĳ���");
        SendClientMessage(playerid, 0xe4026fff, "������ʹ��/showrcpָ����ʾ���㣩");
        return 1;
    }
    format(race_file_name, sizeof(race_file_name), "%s.ini", race_file_name);

    //ɾ���ɵ��ļ�������
    fremove(race_file_name);

    new File:handle = fopen(race_file_name);
    new tmp[64];
    // ---���￪ʼд���������---
    tmp = startdate(playerid);
    fwrite(handle, tmp);

    // ---���￪ʼд�����---

    if (handle) {
        for (new a = 0; a < MAX_RCP ; a++) {
            if (RcpData[playerid][enable][a] == 1) {
                format(tmp, sizeof(tmp), "%.2f %.2f %.2f %.2f %.2f %.2f %d %d %d\n", RcpData[playerid][posx][a], RcpData[playerid][posy][a], RcpData[playerid][posz][a], RcpData[playerid][nextx][a], RcpData[playerid][nexty][a], RcpData[playerid][nextz][a], RcpData[playerid][type][a], RcpData[playerid][size][a], RcpData[playerid][enable][a]);
                fwrite(handle, tmp);
            }
            else {
                a = 999;
                //ɾ���ڴ��оɵ�����
                RcpData[playerid] = RcpData[MAX_PLAYERS];
            }
        }
        fclose(handle);
    }
    else {
        print("The file does not exists, or can't be opened.");
    }
    SendClientMessage(playerid, 0x8db700ff, "�����������");
    //������ʾ����cp
    SpawnCP(playerid);
    //����rcp����
    DisablePlayerRaceCheckpoint(playerid);
    return 1;
}

CMD:creatercp(playerid, params[])
{

    //ʹ��GetPlayerCameraFrontVector��GetPlayerCameraPos��������ʹ�ã���������ӽ�������
    //Ȼ����ӽ�����ת����rcp�������һ�������� ʹ��floatmul����ʵ��

    new rcp_size, rcp_node;
    if (sscanf(params, "ii", rcp_size, rcp_node)) {
        //�����������Ƿ�淶
        SendClientMessage(playerid, 0x7b8cdeff, "�����������ӽ�λ�ô���һ����������ǰ���ļ��� - /rcp [��С] [�ڵ����]");
        return 1;
    }
    new Float:fPX, Float:fPY, Float:fPZ,
        Float:fVX, Float:fVY, Float:fVZ,
        Float:point_of_sight_x, Float:point_of_sight_y, Float:point_of_sight_z;


    const Float:fScale = 50.0;

    //��ȡ����ӽ������������
    GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
    GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

    //͸�������������������ϵ�ĳһ��
    point_of_sight_x = fPX + floatmul(fVX, fScale);
    point_of_sight_y = fPY + floatmul(fVY, fScale);
    point_of_sight_z = fPZ + floatmul(fVZ, fScale);


    //���ÿ�������
    DisablePlayerCheckpoint(playerid);
    //����RCP����
    SetPlayerRaceCheckpoint(playerid, 3, fPX, fPY, fPZ, point_of_sight_x, point_of_sight_y, point_of_sight_z, rcp_size);

    //����ҿͻ����Ϸ��ش�ӡ�ı�
    new var[128];
    format(var, sizeof(var), "�������㣺��С=%d,���=%d", rcp_size, rcp_node);
    SendClientMessage(playerid, -1, var);

    //���浽ȫ�ֱ�������
    RcpData[playerid][posx][rcp_node] = fPX;
    RcpData[playerid][posy][rcp_node] = fPY;
    RcpData[playerid][posz][rcp_node] = fPZ;
    RcpData[playerid][nextx][rcp_node] = point_of_sight_x;
    RcpData[playerid][nexty][rcp_node] = point_of_sight_y;
    RcpData[playerid][nextz][rcp_node] = point_of_sight_z;
    RcpData[playerid][size][rcp_node] = rcp_size;
    RcpData[playerid][type][rcp_node] = 3;
    RcpData[playerid][enable][rcp_node] = 1;

    return 1;
}

CMD:testrace(playerid, params[])
{
    new race_file_name[64];
    if (sscanf(params, "s[64]", race_file_name)) {
        //�����������Ƿ�淶

        SendClientMessage(playerid, 0xffffff, "����һ������·�� - /testrace [������]");
        return 1;
    }
    startrace(playerid, race_file_name);
    return 1;
}

new RaceLoopnumber[MAX_PLAYERS + 1] = 0;

startrace(playerid, race_file_name[64])
{
    RcpData[playerid] = RcpData[MAX_PLAYERS];//��������
    new RaceFullName[64];
    format(RaceFullName, sizeof(race_file_name), "%s.ini", race_file_name);
    if (fexist(RaceFullName)) {

    }
    else {
        SendClientMessage(playerid, 0xe4026fff, "���������ڣ�");
        return 1;
    }
    new File:handle = fopen(RaceFullName, io_read), buf[128];
    //����������
    fread(handle, buf);
    new Float:AirplanePosX;
    new Float:AirplanePosY;
    new Float:AirplanePosZ;
    new Float:AirplanePosZ_angle;
    sscanf(buf, "ffff", AirplanePosX, AirplanePosY, AirplanePosZ, AirplanePosZ_angle);

    // �����������ݼ���
    new i = 0;
    while (fread(handle, buf)) {
        //���￪ʼѭ�����ü���
        new Float:posx_start;
        new Float:posy_start;
        new Float:posz_start;
        new Float:nextx_start;
        new Float:nexty_start;
        new Float:nextz_start;
        new size_start;
        new type_start;
        //ÿһ������д����ʱ����
        sscanf(buf, "ffffffii", posx_start, posy_start, posz_start, nextx_start, nexty_start, nextz_start, type_start, size_start);

        //������ʱ������ѭ���ṹ������������д�����顣���������ݣ�
        RcpData[playerid][posx][i] = posx_start;
        RcpData[playerid][posy][i] = posy_start;
        RcpData[playerid][posz][i] = posz_start;
        RcpData[playerid][nextx][i] = nextx_start;
        RcpData[playerid][nexty][i] = nexty_start;
        RcpData[playerid][nextz][i] = nextz_start;
        RcpData[playerid][size][i] = size_start;
        RcpData[playerid][type][i] = type_start;
        RcpData[playerid][enable][i] = 1;
        i++;
    }
    fclose(handle);
    //���ÿ�������
    DisablePlayerCheckpoint(playerid);
    //���õ�һ������
    SetPlayerRaceCheckpoint(playerid, RcpData[playerid][type][RaceLoopnumber[playerid]], RcpData[playerid][posx][RaceLoopnumber[playerid]], RcpData[playerid][posy][RaceLoopnumber[playerid]], RcpData[playerid][posz][RaceLoopnumber[playerid]], RcpData[playerid][nextx][RaceLoopnumber[playerid]], RcpData[playerid][nexty][RaceLoopnumber[playerid]], RcpData[playerid][nextz][RaceLoopnumber[playerid]], RcpData[playerid][size][RaceLoopnumber[playerid]]);
    //�����ؾ߲��Ұ���ҷŽ�ȥ
    new vid = CreateVehicle(520, AirplanePosX, AirplanePosY, AirplanePosZ, AirplanePosZ_angle, -1, -1, -1);
    PutPlayerInVehicle(playerid, vid, 0);
    return 1;
}

RaceLooper(playerid)
{
    //����ѭ������Ա
    if (RcpData[playerid][enable][RaceLoopnumber[playerid]] != 0) { //���������enable����Ϊ0���ͽ�������ѭ�����������
        SetPlayerRaceCheckpoint(playerid, RcpData[playerid][type][RaceLoopnumber[playerid]], RcpData[playerid][posx][RaceLoopnumber[playerid]], RcpData[playerid][posy][RaceLoopnumber[playerid]], RcpData[playerid][posz][RaceLoopnumber[playerid]], RcpData[playerid][nextx][RaceLoopnumber[playerid]], RcpData[playerid][nexty][RaceLoopnumber[playerid]], RcpData[playerid][nextz][RaceLoopnumber[playerid]], RcpData[playerid][size][RaceLoopnumber[playerid]]);
    }
    else {
        RaceLoopnumber[playerid] = 0;
        DisablePlayerRaceCheckpoint(playerid);
        SendClientMessage(playerid, 0xffba13ff, "��ϲ��");
        //��ʾ��������,��������һص�������
        SpawnCP(playerid);
        SpawnPlayer(playerid);
    }
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if (GetPVarInt(playerid, "FlyMode")) { //�������Ƿ��ڷ���ģʽ���С�����ǾͲ���������ѭ��������Ӱ�������༭��
        return 1;
    }
    RaceLoopnumber[playerid]++;
    RaceLooper(playerid);//��ʱ��������+1�����ٴδ��κ�������ѭ������Ա
    return 1;
}

//---������������---
enum E_RACEDATA {
    RACEDATA_ID,
    RACEDATA_RACENAME,
    RACEDATA_FROM,
    RACEDATA_FILENAME
}

new RaceData[MAX_RACE][E_RACEDATA][64];
new TotalLine;

public OnGameModeInit()
{
    new File:handle = fopen("list", io_read);
    new buf1[128];
    new id[32];
    new racename[64];
    new from[32];
    new filename[32];
    new nope[32];
    new i = 0;
    while (fread(handle, buf1)) {
        sscanf(buf1, "s[32]s[64]s[32]s[32]s[32]", id, racename, from, filename, nope);
        sscanf(id, "P<=>s[32]s[32]", nope, id);
        sscanf(racename, "P<=>s[32]s[64]", nope, racename);
        sscanf(from, "P<=>s[32]s[32]", nope, from);
        sscanf(filename, "P<=>s[32]s[32]", nope, filename);
        RaceData[i][RACEDATA_ID] = id;
        RaceData[i][RACEDATA_RACENAME] = racename;
        RaceData[i][RACEDATA_FROM] = from;
        RaceData[i][RACEDATA_FILENAME] = filename;
        i++;
        TotalLine = i;
    }
    fclose(handle);

    //�������Ƥ��
    new const skinId[] = { 299, 29, 86, 137, 138, 150, 168, 195, 217, 230, 246, 249, 280 };
    for(i = 0; i < sizeof(skinId); ++i){
        AddPlayerClass(skinId[i], 380.0, 2480.0, GetPointZPos(380.0, 2480.0) + 1.0, 0, WEAPON_FIST, 0, 0, 0, 0, 0);
    }

    return 1;
}

//---������������ end---

CMD:mypos(playerid, params[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new string[64];
    format(string, sizeof(string), "����λ��Ϊ: x: %.2f, y: %.2f, z: %.2f", x, y, z);
    SendClientMessage(playerid, 0x00E5EEFF, string);
    return 1;
}

//���巭ҳ���ÿҳ��ʾ��Χ
#define PAGE_SIZE 18 //ÿҳ��ʾ20����Ŀ

//-----������ҳ-------

enum E_RACE_PAGE_STATUS {
    RACESTATUS_PAGEENDPOINT,
    ON_THAT_PAGE_START_INDEX_NOW,
    CURRENT_PAGE
}

new RacePageStatus[MAX_PLAYERS + 1][E_RACE_PAGE_STATUS];

RaceListFormat(playerid, page)
{
    new stringlist[1024];
    RacePageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW] = (page - 1) * PAGE_SIZE;
    new end_index = min(TotalLine, RacePageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW] + PAGE_SIZE);
    RacePageStatus[playerid][RACESTATUS_PAGEENDPOINT] = end_index - RacePageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW];
    for (new i = RacePageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW]; i < end_index; i++) {
        strcat(stringlist, RaceData[i][RACEDATA_RACENAME]);
        strcat(stringlist, "\t");
        strcat(stringlist, RaceData[i][RACEDATA_FROM]);
        strcat(stringlist, "\n");
    }
    strcat(stringlist, "��һҳ\n��һҳ\n");
    return stringlist;
}

enum {
    DIALOG_STARTRACE,
    DIALOG_SHOWRCP,
}

ShowRaceDlList(playerid)
{
    RacePageStatus[playerid][CURRENT_PAGE] = 1;
    ShowPlayerDialog(playerid, DIALOG_STARTRACE, DIALOG_STYLE_LIST, "�ؼ���������ѡ��ϵͳ", RaceListFormat(playerid, RacePageStatus[playerid][CURRENT_PAGE]), "open", "nope");
    return 1;
}
//-----������ҳ end-------

//-----����༭��------

enum E_RCP_PAGE_STATUS {
    RCPSTATUS_PAGEENDPOINT,
    ON_THAT_PAGE_START_INDEX_NOW,
    CURRENT_PAGE
}

new RcpPageStatus[MAX_PLAYERS + 1][E_RCP_PAGE_STATUS];
new RcpTotalLine;//��ǰ�����ܹ�����ļ���

RcpListFormat(playerid, page)
{
    new stringlist[1024];
    RcpPageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW] = (page - 1) * PAGE_SIZE;
    new end_index = min(RcpTotalLine, RcpPageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW] + PAGE_SIZE);
    RcpPageStatus[playerid][RCPSTATUS_PAGEENDPOINT] = end_index - RcpPageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW];
    new tmp[16];
    for (new i = RcpPageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW]; i < end_index; i++) {
        format(tmp, sizeof(tmp), "����%d", i);
        strcat(stringlist, tmp);
        strcat(stringlist, "\n");
    }
    strcat(stringlist, "��һҳ\n��һҳ\n");
    return stringlist;
}

CMD:showrcp(playerid, params[])
{
    //ȷ���ܹ��ж����м���
    new i = 0;
    while (RcpData[playerid][enable][i] == 1) {
        i++;
        RcpTotalLine = i; //������Ҫi - 1  ��Ϊ���Ǵ�1��ʼ����ġ� rcp0 = i1
    }
    //������һҳ��Ⱦ
    RcpPageStatus[playerid][CURRENT_PAGE] = 1;
    ShowPlayerDialog(playerid, DIALOG_SHOWRCP, DIALOG_STYLE_LIST, "����༭��", RcpListFormat(playerid, RcpPageStatus[playerid][CURRENT_PAGE]), "open", "nope");
    return 1;
}

//-----����༭�� end------

//�Ի���ص��ṹ��
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    //----����ѡ������----
    if (dialogid == DIALOG_STARTRACE && response) {
        if (listitem < RacePageStatus[playerid][RACESTATUS_PAGEENDPOINT]) {
            startrace(playerid, RaceData[RacePageStatus[playerid][ON_THAT_PAGE_START_INDEX_NOW] + listitem][RACEDATA_FILENAME]);
        }
        else if (listitem == RacePageStatus[playerid][RACESTATUS_PAGEENDPOINT]) {   //��һҳ �� ����պ���������������Ͼ�����һҳ��λ��
            if (RacePageStatus[playerid][CURRENT_PAGE] == 1) {
                //�ڸô����У�CURRENT_PAGE��ʾ��ǰҳ���ҳ�룬��1��ʼ�������������ڵ�һҳѡ������һҳ����ôCURRENT_PAGE��1��ͻ��Ϊ0������Ȼ�ǲ��Ϸ��ġ�
                ShowPlayerDialog(playerid, DIALOG_STARTRACE, DIALOG_STYLE_LIST, "�ؼ���������ѡ��ϵͳ", RaceListFormat(playerid, RacePageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
            else {
                RacePageStatus[playerid][CURRENT_PAGE]--;
                ShowPlayerDialog(playerid, DIALOG_STARTRACE, DIALOG_STYLE_LIST, "�ؼ���������ѡ��ϵͳ", RaceListFormat(playerid, RacePageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
        }
        else if (listitem > RacePageStatus[playerid][RACESTATUS_PAGEENDPOINT]) {  //��һҳ   +1 ������һҳ
            if (RacePageStatus[playerid][CURRENT_PAGE] < (TotalLine / PAGE_SIZE) + 1) {
                //���д��������ж��Ƿ���Լ������·�ҳ����������ҳ���С����ȡ��������Ȳ�����ǰҳ��󡣾Ͳ���ҳ����֮��ǰҳ���1
                RacePageStatus[playerid][CURRENT_PAGE]++;
                ShowPlayerDialog(playerid, DIALOG_STARTRACE, DIALOG_STYLE_LIST, "�ؼ���������ѡ��ϵͳ", RaceListFormat(playerid, RacePageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
            else {
                ShowPlayerDialog(playerid, DIALOG_STARTRACE, DIALOG_STYLE_LIST, "�ؼ���������ѡ��ϵͳ", RaceListFormat(playerid, RacePageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
        }
        return 1;
    }

    //----�������༭��-----
    if (dialogid == DIALOG_SHOWRCP && response) {
        if (listitem < RcpPageStatus[playerid][RCPSTATUS_PAGEENDPOINT]) {
            //��ʾѡ�еļ��㣬�����listitem
            SetPlayerRaceCheckpoint(playerid, RcpData[playerid][type][listitem], RcpData[playerid][posx][listitem], RcpData[playerid][posy][listitem], RcpData[playerid][posz][listitem], RcpData[playerid][nextx][listitem], RcpData[playerid][nexty][listitem], RcpData[playerid][nextz][listitem], RcpData[playerid][size][listitem]);
        }
        else if (listitem == RcpPageStatus[playerid][RCPSTATUS_PAGEENDPOINT]) {   //��һҳ �� ����պ���������������Ͼ�����һҳ��λ��
            if (RcpPageStatus[playerid][CURRENT_PAGE] == 1) {
                //�ڸô����У�CURRENT_PAGE��ʾ��ǰҳ���ҳ�룬��1��ʼ�������������ڵ�һҳѡ������һҳ����ô��ǰҳ���1��ͻ��Ϊ0������Ȼ�ǲ��Ϸ��ġ�
                ShowPlayerDialog(playerid, DIALOG_SHOWRCP, DIALOG_STYLE_LIST, "����༭��", RcpListFormat(playerid, RcpPageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
            else {
                RcpPageStatus[playerid][CURRENT_PAGE]--;
                ShowPlayerDialog(playerid, DIALOG_SHOWRCP, DIALOG_STYLE_LIST, "����༭��", RcpListFormat(playerid, RcpPageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
        }
        else if (listitem > RcpPageStatus[playerid][RCPSTATUS_PAGEENDPOINT]) {  //��һҳ
            if (RcpPageStatus[playerid][CURRENT_PAGE] < (TotalLine / PAGE_SIZE) + 1) {
                //���д��������ж��Ƿ���Լ������·�ҳ����������ҳ���С����ȡ����������ǰҳ�泬����ﵽ���ֵ�����ⷭҳ�����߽硣
                RcpPageStatus[playerid][CURRENT_PAGE]++;
                ShowPlayerDialog(playerid, DIALOG_SHOWRCP, DIALOG_STYLE_LIST, "����༭��", RcpListFormat(playerid, RcpPageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
            else {
                ShowPlayerDialog(playerid, DIALOG_SHOWRCP, DIALOG_STYLE_LIST, "����༭��", RcpListFormat(playerid, RcpPageStatus[playerid][CURRENT_PAGE]), "open", "nope");
            }
        }
        return 1;
    }
    return 0;
}

public OnPlayerConnect(playerid)
{
    PlayAudioStreamForPlayer(playerid, "https://file.stuntfly.com/classmusic.mp3");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    StopAudioStreamForPlayer(playerid);
    SpawnCP(playerid);

    new const offset_x = random(50), offset_y = random(50);
    SetPlayerPos(playerid, 380.0 + offset_x, 2480.0 + offset_y, GetPointZPos(380.0, 2480.0) + 1.0);

    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 290.79, 2534.48, 25.49);
    SetPlayerFacingAngle(playerid, 180.00);
    LoadUpScreenAnimation(playerid);
    SetPlayerCameraPos(playerid, 290.9113, 2528.5571, 26.1096);
    SetPlayerCameraLookAt(playerid, 290.9021, 2529.5525, 26.0191);
    return 1;
}

LoadUpScreenAnimation(playerid)
{
    ApplyAnimation(playerid, "ON_LOOKERS", "WAVE_IN", 4.1, 0, 0, 0, 0, 0);
    ApplyAnimation(playerid, "ON_LOOKERS", "WAVE_LOOP", 4.1, 1, 0, 0, 0, 0);
    return 1;
}

SpawnCP(playerid)
{
    SetPlayerCheckpoint(playerid, 365.40, 2537.26, 16.66, 3);
}

public OnPlayerEnterCheckpoint(playerid)
{
    //ClearVehicle();
    ShowRaceDlList(playerid);
    return 0;
}

main()
{

    return 1;
}


//�������˽���
//ClearVehicle()
//{
//    for (new i = 1; i < MAX_VEHICLES ; i++) {
//        if (GetVehicleDriver(i) == INVALID_PLAYER_ID) {
//            DestroyVehicle(i);
//        }
//    }
//    return 1;
//}

CMD:cameradate(playerid, params[])
{
    startdate(playerid);
    return 1;
}

startdate(playerid)
{
    //������ʼ������꣨fPX��fPY��fPZ����ֱ���ϵ�һ������꣨OnTheLineX��OnTheLineY��OnTheLineZ��
    //�����������֮��������delta_x��delta_y��delta_z��
    //Ȼ��ʹ�÷����к��������磬atan2��������delta_y��delta_x֮��ļнǣ�Ҳ����Z�Ƕȣ�
    new Float:fPX, Float:fPY, Float:fPZ;
    new Float:fVX, Float:fVY, Float:fVZ;
    new Float:OnTheLineX, Float:OnTheLineY, Float:OnTheLineZ;
    new Float:delta_x, Float:delta_y, Float:delta_z;

    const Float:fScale = 5.0;

    GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
    GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

    OnTheLineX = fPX + floatmul(fVX, fScale);
    OnTheLineY = fPY + floatmul(fVY, fScale);
    OnTheLineZ = fPZ + floatmul(fVZ, fScale);

    delta_x = OnTheLineX - fPX;
    delta_y = OnTheLineY - fPY;
    delta_z = OnTheLineZ - fPZ;
    //ʹ�÷����к�������Z�Ƕ�
    new z_angle = atan2(delta_y, delta_x) - 90; //�㷨û���⣬������90�ȵ�ƫ����������

    new data[64];
    format(data, sizeof(data), "%.2f %.2f %.2f %.2f\n", fPX, fPY, fPZ, z_angle);
    // SendClientMessage(playerid, -1, data);
    return data;
}

CMD:spawn(playerid, params[])
{
    SpawnPlayer(playerid);
    return 1;
}


public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER) {
        new currVehicle = GetPlayerVehicleID(playerid);
        if (g_PlayerLastVeh[playerid] != currVehicle && IsValidVehicle(g_PlayerLastVeh[playerid])) {
            DestroyVehicle(currVehicle);
        }
        g_PlayerLastVeh[playerid] = currVehicle;
    }
}

CMD:hydra(playerid, params[])
{
    if (IsValidVehicle(g_PlayerLastVeh[playerid])) {
        DestroyVehicle(g_PlayerLastVeh[playerid]);
    }

    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    GetPlayerPos(playerid, x, y, z);
    new vid = CreateVehicle(520, x, y, z, angle, -1, -1, -1);
    PutPlayerInVehicle(playerid, vid, 0);

    return 1;
}

CMD:p51(playerid, params[])
{
    if (IsValidVehicle(g_PlayerLastVeh[playerid])) {
        DestroyVehicle(g_PlayerLastVeh[playerid]);
    }

    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    GetPlayerPos(playerid, x, y, z);
    new vid = CreateVehicle(476, x, y, z, angle, -1, -1, -1);
    PutPlayerInVehicle(playerid, vid, 0);

    return 1;
}
alias:p51("rustler")

CMD:stuntplane(playerid, params[])
{
    if (IsValidVehicle(g_PlayerLastVeh[playerid])) {
        DestroyVehicle(g_PlayerLastVeh[playerid]);
    }

    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    GetPlayerPos(playerid, x, y, z);
    new vid = CreateVehicle(513, x, y, z, angle, -1, -1, -1);
    PutPlayerInVehicle(playerid, vid, 0);

    return 1;
}

CMD:v(playerid, params[])
{
    new const modelid = strval(params);

    if (!modelid || modelid < 400 || modelid > 611) {
        SendClientMessage(playerid, 0x00FF00FF, "usage: \"/v [400~611]\" or \"/c [400~611]\"");
        return 1;
    }

    if (IsValidVehicle(g_PlayerLastVeh[playerid])) {
        DestroyVehicle(g_PlayerLastVeh[playerid]);
    }

    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    GetPlayerPos(playerid, x, y, z);
    new vid = CreateVehicle(modelid, x, y, z, angle, -1, -1, -1);
    PutPlayerInVehicle(playerid, vid, 0);

    return 1;
}
alias:v("c")

CMD:fix(playerid, params[])
{
    if (!IsPlayerInAnyVehicle(playerid)) {
        return SendClientMessage(playerid, 0xFF0000FF, "You are not in a vehicle!");
    }

    RepairVehicle(GetPlayerVehicleID(playerid));

    SendClientMessage(playerid, 0x00FF00FF, "Your vehicle has been repaired!");
    SendClientMessage(playerid, 0x00FF00FF, "The physics of the landing gear may be wrong, please join us for a temporary solution.");
    return 1;
}
alias:fix("repair")

new Bool:g_PlayerGodModeToggle[MAX_PLAYERS];
CMD:god(playerid, params)
{
    g_PlayerGodModeToggle[playerid] = Bool:!g_PlayerGodModeToggle[playerid];

    if (g_PlayerGodModeToggle[playerid]) {
        SetPlayerHealth(playerid, 100.0);
        if (IsPlayerInAnyVehicle(playerid)) {
            RepairVehicle(GetPlayerVehicleID(playerid));
        }
    
        SendClientMessage(playerid, 0x00FF00FF, "God mode ON.");
        SendClientMessage(playerid, 0x00FF00FF, "The physics of the landing gear may be wrong after each fix, please join us for a temporary solution.");
    }
    else {
        SendClientMessage(playerid, 0x00FF00FF, "God mode OFF.");
    }

    return 1;
}

#define COLOR_WEATHER_USAGE 0x00FF00FF
#define COLOR_WEATHER_SUCCESS 0x00FF00FF
CMD:weather(playerid, params[])
{
    if (!strlen(params)) {
        SendClientMessage(playerid, COLOR_WEATHER_USAGE, "Usage: /weather [integer:0~19]");
        SendClientMessage(playerid, COLOR_WEATHER_USAGE, "The Weather will slowly change over time. Use the \"/time lock\" before it will apply change instantly.");
        SendClientMessage(playerid, COLOR_WEATHER_USAGE, "More information of weather id can be found in https://open.mp/docs/scripting/resources/weatherid.");
        return 1;
    }

    new const id = strval(params);
    SetPlayerWeather(playerid, id);
    SendClientMessage(playerid, COLOR_WEATHER_SUCCESS, "Successfully set the weather to %d.", id);

    return 1;
}

#define COLOR_TIME_USAGE 0x00FF00FF
#define COLOR_TIME_SUCCESS 0x00FF00FF
CMD:time(playerid, params[])
{
    if (!strlen(params)) {
        SendClientMessage(playerid, COLOR_TIME_USAGE, "Usage: /time [Hour:0~23]|[[un]lock]");
        SendClientMessage(playerid, COLOR_TIME_USAGE, "Use \"/time [un]lock\" to toggle whether time is ticking or not.");

        return 1;
    }

    if (!strcmp(params, "lock", true)) {
        TogglePlayerClock(playerid, false);
        SendClientMessage(playerid, COLOR_TIME_SUCCESS, "Successfully locked the time and weather.");
        return 1;
    }
    else if (!strcmp(params, "unlock", true)) {
        TogglePlayerClock(playerid, true);
        SendClientMessage(playerid, COLOR_TIME_SUCCESS, "Successfully unlocked the time and weather.");
        return 1;
    }

    new const hour = strval(params);
    SetPlayerTime(playerid, hour, 0);
    SendClientMessage(playerid, COLOR_TIME_SUCCESS, "Successfully set the time to %d.", hour);

    return 1;
}

#define COLOR_SKIN_USAGE 0x00FF00FF
#define COLOR_SKIN_SUCCESS 0x00FF00FF
CMD:skin(playerid, params[])
{
    new const skinid = strval(params);
    if (!strlen(params) || skinid < 0 || skinid > 311 || skinid == 74) {
        SendClientMessage(playerid, COLOR_SKIN_USAGE, "Usage: /skin [Integer:0~73|Integer:75~311]");

        return 1;
    }

    SetPlayerSkin(playerid, skinid);
    SendClientMessage(playerid, COLOR_SKIN_SUCCESS, "Successfully set the skin to %d.", skinid);

    return 1;
}

#define COLOR_TV_USAGE 0x00FF00FF
#define COLOR_TV_ERROR 0xFF0000FF
#define COLOR_TV_SUCCESS 0x00FF00FF
CMD:tv(playerid, params[])
{
    if (!strlen(params)) {
        SendClientMessage(playerid, COLOR_TV_USAGE, "Usage: /tv [Integer:playerid]|[off] or /watch [Integer:playerid]|[off]");

        return 1;
    }

    if(!strcmp("off", params, true)){
        TogglePlayerSpectating(playerid, false);
        SendClientMessage(playerid, COLOR_TV_SUCCESS, "Successfully exited the tv mode.");
        
        return 1;
    }

    new const targetid = strval(params);
    if(!IsPlayerConnected(targetid)){
        SendClientMessage(playerid, COLOR_TV_ERROR, "Player %d does not exist!", targetid);

        return 1;
    }

    if(targetid == playerid){
        SendClientMessage(playerid, COLOR_TV_ERROR, "You cannot tv yourself!");

        return 1;
    }

    // there are other invalid arguments actually, but it's enough for now

    TogglePlayerSpectating(playerid, true);
    if(IsPlayerInAnyVehicle(targetid)) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    else PlayerSpectatePlayer(playerid, targetid);
    SendClientMessage(playerid, COLOR_TV_SUCCESS, "Successfully tv-ed player %d.", targetid);

    return 1;
}
alias:tv("watch")

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
    if (!g_PlayerGodModeToggle[playerid]) return 0;

    SetPlayerHealth(playerid, 100.0);
    return 0;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if (!g_PlayerGodModeToggle[playerid]) return 0;

    if (IsPlayerInVehicle(playerid, vehicleid)) {
        RepairVehicle(vehicleid);
    }
    return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    //the 1.0 offset to avoid falling into ground
    SetPlayerPos(playerid, fX, fY, GetPointZPos(fX, fY) + 1.0);
}

public OnPlayerDisconnect(playerid, reason)
{
    if (IsValidVehicle(g_PlayerLastVeh[playerid])) {
        DestroyVehicle(g_PlayerLastVeh[playerid]);
    }

    g_PlayerLastVeh[playerid] = INVALID_VEHICLE_ID;
    g_PlayerGodModeToggle[playerid] = Bool:false;
}