#include "include/luaplayer.h"
#include "include/baexec-system_paths.h"
#include "include/luaKELFBinder.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <libmc.h>
#include <osd_config.h>
#include <smem.h>
#include <smod.h>
#include "include/dbgprintf.h"
extern "C" {
#include "modelname.h"
}
#define NEXT_MULTIPLE(VALUE, BASE) (VALUE + (BASE - VALUE % BASE))

static int KELFBinderHelperFunctionsInited = false;
static unsigned long int ROMVERSION;
static unsigned int _MACHINETYPE;
// static int ROMYEAR, ROMMONTH, ROMDAY;
static char ROMREGION;
extern bool HDD_USABLE;
#define ROMVER_LEN 16
#define GET_MACHINE_TYPE(ROMVER)          \
    (ROMVER[5] == 'C') ? MACHINETYPE::CEX :  \
    (ROMVER[5] == 'D') ? MACHINETYPE::DEX :  \
    (ROMVER[5] == 'T') ? ((ROMVER[6] == 'Z') ? MACHINETYPE::COH : MACHINETYPE::TOOL) : \
                 UNKNOWN

/// NOTE: sony made asian machines to use the USA region folder prefixes
#define GET_CONSOLE_REGION(X)              \
    (X == 'J') ? CONSOLE_REGIONS::JAPAN :  \
    (X == 'A') ? CONSOLE_REGIONS::USA :    \
    (X == 'H') ? CONSOLE_REGIONS::ASIA :   \
    (X == 'E') ? CONSOLE_REGIONS::EUROPE : \
    (X == 'C') ? CONSOLE_REGIONS::CHINA :  \
                 UNKNOWN

static int lua_KELFBinderInit(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    int argc = lua_gettop(L);
#ifndef SKIP_ERROR_HANDLING
    if (argc != 1)
        return luaL_error(L, "wrong number of arguments");
#endif
    const char *ROMVER = luaL_checkstring(L, 1);
    char ROMVNUM[4 + 1];
    ROMREGION = GET_CONSOLE_REGION(ROMVER[4]);
    if (ROMREGION == UNKNOWN)
    {
        DPRINTF(      "\t\tROM Region has unknown value [%c]\n\n\t\t\tCONTACT THE DEVELOPER!\n", ROMVER[4]);
        luaL_error(L, "\t\tROM Region has unknown value [%c]\n\n\t\t\tCONTACT THE DEVELOPER!\n", ROMVER[4]);
    }
    _MACHINETYPE = GET_MACHINE_TYPE(ROMVER);
    strncpy(ROMVNUM, ROMVER, 4);
    ROMVNUM[4] = '\0';
    ROMVERSION = strtoul(ROMVNUM, NULL, 10); // convert ROM version to unsigned long int for further use on automatic Install, use hex numbers to compare!! (eg: to check for rom 1.20 do ROMVERSION == 0x120)
    KELFBinderHelperFunctionsInited = true;
    return 1;
}

static int lua_KELFBinderDeInit(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    int argc = lua_gettop(L);
#ifndef SKIP_ERROR_HANDLING
    if (argc != 0)
        return luaL_error(L, "wrong number of arguments");
#endif
    return 1;
}

static int lua_calcsysupdatepath(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    int ver = ROMVERSION, region = ROMREGION;
    if (!KELFBinderHelperFunctionsInited)
        return luaL_error(L, "error initializing kelfbinder helper service!");

    if (region == CONSOLE_REGIONS::JAPAN) {
        switch (ver) {
            case 100:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::JAP_ROM_100]);
                break;
            case 101:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::JAP_ROM_101]);
                break;
            case 120:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::JAP_ROM_120]);
                break;
            default:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::JAP_STANDARD]);
                break;
        }

    } else if (region == CONSOLE_REGIONS::EUROPE) {
        switch (ver) {
            case 120:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::EUR_ROM_120]);
                break;

            default:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::EUR_STANDARD]);
                break;
        }

    } else if (region == CONSOLE_REGIONS::CHINA) {
        lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::CHN_STANDARD]);

    } else if ((region == CONSOLE_REGIONS::USA) || (region == CONSOLE_REGIONS::ASIA)) {
        switch (ver) {
            case 110:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::USA_ROM_110]);
                break;

            case 120:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::USA_ROM_120]);
                break;

            default:
                lua_pushstring(L, sysupdate_paths[SYSUPDATE_COUNT::USA_STANDARD]);
        }
    } else {
        return luaL_error(L, "SYSTEM REGION IS UNKNOWN\nCONTACT THE DEVELOPER!");
    }
    return 1;
}

static int lua_getsystemregion(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    lua_pushinteger(L, ROMREGION);
    return 1;
}

static int lua_getsystemregionString(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    switch (ROMREGION) {

        case CONSOLE_REGIONS::JAPAN:
            lua_pushstring(L, "Japan");
            break;

        case CONSOLE_REGIONS::EUROPE:
            lua_pushstring(L, "Europe");
            break;

        case CONSOLE_REGIONS::USA:
            lua_pushstring(L, "USA");
            break;

        case CONSOLE_REGIONS::ASIA:
            lua_pushstring(L, "Asia");
            break;

        case CONSOLE_REGIONS::CHINA:
            lua_pushstring(L, "China");
            break;

        default:
            lua_pushstring(L, "UNKNOWN!");
            break;
    }
    return 1;
}

static int lua_getsystemupdatefolder(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    switch (ROMREGION) {
        case CONSOLE_REGIONS::JAPAN:
            lua_pushstring(L, "BIEXEC-SYSTEM");
            break;

        case CONSOLE_REGIONS::EUROPE:
            lua_pushstring(L, "BEEXEC-SYSTEM");
            break;

        case CONSOLE_REGIONS::ASIA:
        case CONSOLE_REGIONS::USA:
            lua_pushstring(L, "BAEXEC-SYSTEM");
            break;
            
        case CONSOLE_REGIONS::CHINA:
            lua_pushstring(L, "BCEXEC-SYSTEM");
            break;

        default:
            return luaL_error(L, "SYSTEM REGION IS UNKNOWN\nCONTACT THE DEVELOPER!");
            break;
    }
    return 1;
}

static int lua_getDVDPlayerUpdatefolder(lua_State *L)
{
    int region;
    if (lua_gettop(L) < 1)
        region = ROMREGION;
    else
        region = luaL_checkinteger(L, 1);

    DPRINTF("%s: start\n", __func__);
    switch (region) {
        case CONSOLE_REGIONS::JAPAN:
            lua_pushstring(L, "BIEXEC-DVDPLAYER");
            break;

        case CONSOLE_REGIONS::EUROPE:
            lua_pushstring(L, "BEEXEC-DVDPLAYER");
            break;

        case CONSOLE_REGIONS::ASIA:
        case CONSOLE_REGIONS::USA:
            lua_pushstring(L, "BAEXEC-DVDPLAYER");
            break;
            
        case CONSOLE_REGIONS::CHINA:
            lua_pushstring(L, "BCEXEC-DVDPLAYER");
            break;

        default:
            return luaL_error(L, "SYSTEM REGION IS UNKNOWN\nCONTACT THE DEVELOPER! (%d)", region);
            break;
    }
    return 1;
}

static int lua_getromversion(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    lua_pushinteger(L, ROMVERSION);
    return 1;
}

static int lua_getsysupdateROMPatch(lua_State *L)
{
    char PATH[32];
    const char REG_PREF[5] = {'I', 'A', 'A', 'E', 'C'};
    sprintf(PATH, "B%cEXEC-SYSTEM/osd%03ld.elf", REG_PREF[ROMREGION], NEXT_MULTIPLE(ROMVERSION, 10));
    lua_pushstring(L, PATH);
    return 1;
}

static int lua_getosdconfigLNG(lua_State *L)
{
    DPRINTF("%s: start\n", __func__);
    int lang = configGetLanguage();
    lua_pushinteger(L, lang);
    return 1;
}

static int lua_setsysupdatefoldprops(lua_State *L)
{
    int argc = lua_gettop(L);
	if (argc != 3) 
        return luaL_error(L, "lua_createsysupdatefolder takes 3 argumments\n");
    int result;
    int port = luaL_checkinteger(L, 1);
    int slot = luaL_checkinteger(L, 2);
    const char* path = luaL_checkstring(L, 3);
    DPRINTF("adding copy protection to mc%d:/%s\n", port, path); 
    sceMcTblGetDir table;
    // Set desired file attributes.
    table.AttrFile = sceMcFileAttrReadable | sceMcFileAttrWriteable | sceMcFileAttrExecutable | sceMcFileAttrDupProhibit | sceMcFileAttrSubdir | sceMcFile0400;
    if ((result = mcSetFileInfo(port, slot, path, &table, sceMcFileInfoAttr)) == 0) {
        mcSync(0, NULL, &result);
    }
    DPRINTF("\tresult was %d\n", result);
    lua_pushinteger(L, result);
    return 1;
}

static int lua_getMachineType(lua_State *L)
{
    lua_pushinteger(L, _MACHINETYPE);
    return 1;
}

static int lua_initConsoleModel(lua_State *L)
{
    DPRINTF("%s: starts\n", __func__); 
    ModelNameInit();
    return 1;
}

static int lua_getHDDSTATUS(lua_State *L)
{
    lua_pushboolean(L, HDD_USABLE);
    return 1;
}

static int lua_getConsoleModel(lua_State *L)
{
    const char* model = ModelNameGet();
    lua_pushstring(L, model);
    return 1;
}

static int lua_checkConsoleNeedsExtHDDLOAD(lua_State *L)
{
    bool needs_HDDLOAD = (ROMREGION == CONSOLE_REGIONS::JAPAN && ROMVERSION <= 120) || (ROMVERSION == 200); // PCMCIA or 70k unit
    lua_pushboolean(L, needs_HDDLOAD);
    return 1;
}
extern FILE* LOGFILE;
static int lua_closelog(lua_State *L)
{
    DPRINTF("log file close requested\n");
    fclose(LOGFILE);
    return 0;
}

smod_mod_info_t* GetIRXInfoByName(const char* name);
static int lua_GetIRXInfoByName(lua_State *L)
{
	if (lua_gettop(L) != 1) 
        return luaL_error(L, "GetIRXInfoByName takes 1 string as arg\n");
    const char* name = luaL_checkstring(L, 1);
    DPRINTF("%s: searching for %s\n", __FUNCTION__, name);
    smod_mod_info_t* info = GetIRXInfoByName(name);
    if (info == NULL) 
        lua_pushnil(L);
    else {
        lua_newtable(L);

        lua_pushstring(L, "name");
        lua_pushstring(L, name);
        lua_settable(L, -3);

        lua_pushstring(L, "version");
        lua_pushinteger(L, info->version);
        lua_settable(L, -3);

        lua_pushstring(L, "id");
        lua_pushinteger(L, info->id);
        lua_settable(L, -3);

    }
    return 1;
}

static const luaL_Reg KELFBinder_functions[] = {
    {"init", lua_KELFBinderInit},
    {"deinit", lua_KELFBinderDeInit},
    {"CheckHDDUsable", lua_getHDDSTATUS},
    {"calculateSysUpdatePath", lua_calcsysupdatepath},
    {"calculateSysUpdateROMPatch", lua_getsysupdateROMPatch},
    {"setSysUpdateFoldProps", lua_setsysupdatefoldprops},
    {"getsysupdatefolder", lua_getsystemupdatefolder},
    {"getsystemregion", lua_getsystemregion},
    {"getsystemtype", lua_getMachineType},
    {"getsystemregionString", lua_getsystemregionString},
    {"getROMversion", lua_getromversion},
    {"getsystemLanguage", lua_getosdconfigLNG},
    {"InitConsoleModel", lua_initConsoleModel},
    {"getConsoleModel", lua_getConsoleModel},
    {"getDVDPlayerFolder",lua_getDVDPlayerUpdatefolder},
    {"DoesConsoleNeedHDDLOAD", lua_checkConsoleNeedsExtHDDLOAD},
    {"GetIRXInfoByName", lua_GetIRXInfoByName},
    {"DeinitLOG", lua_closelog},
    {0, 0}
};

void luaKELFBinder_init(lua_State *L)
{
    lua_newtable(L);
    luaL_setfuncs(L, KELFBinder_functions, 0);
    lua_setglobal(L, "KELFBinder");
}

smod_mod_info_t* curr = NULL;
smod_mod_info_t* GetIRXInfoByName(const char* name) {
    smod_mod_info_t info;
    curr = NULL;
    char sName[21];
    int rv;
    while ((rv = smod_get_next_mod(curr, &info)) != 0) {
        curr = &info;
        if (curr == NULL) continue;
        smem_read(info.name, sName, 20);
        DPRINTF("%s: v%x\n", sName, info.version);
        sName[20] = 0;
        if (!strcmp(name, sName)) {
            return curr;
        }
    }
    return NULL;
}