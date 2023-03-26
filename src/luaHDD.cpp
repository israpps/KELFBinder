#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <tamtypes.h>
#include <loadfile.h>
#include <malloc.h>
#include <assert.h>
#include <libcdvd-common.h>
#include <hdd-ioctl.h>
#include <libhdd.h>
#define NEWLIB_PORT_AWARE
#include <fileXio_rpc.h>
#include <fileio.h>

#include "include/dbgprintf.h"
#include "include/luaplayer.h"
#ifdef RESERVE_PFS0
extern int bootpath_is_on_HDD;
#endif

int mnt(const char* path, int index, int openmod);

static int MountPart(lua_State *L)
{
#ifdef RESERVE_PFS0
    int indx = 1;
#else
    int indx = 0;
#endif
    int openmod = FIO_MT_RDWR;
    const char* mount;
    int argc = lua_gettop(L);
	if (argc > 1 && argc < 4) return luaL_error(L, "%s: wrong number of arguments, expected 1 or 2", __func__); 

    mount = luaL_checkstring(L, 1);
    if (argc >= 2) indx = luaL_checkinteger(L, 2);
    if (argc == 3) openmod = luaL_checkinteger(L, 3);
#ifdef RESERVE_PFS0
    if (indx == 0 && bootpath_is_on_HDD) luaL_error(L, "%s: pfs0:/ is reserved\n", __func__);
#endif
    lua_pushinteger(L, mnt(mount, indx, openmod));
    return 1;

}

static int UmountPart(lua_State *L)
{
    char PFS[6] = "pfs0:";
	if (lua_gettop(L) != 1) return luaL_error(L, "%s: wrong number of arguments, expected 1", __func__);

    PFS[3] = '0' + luaL_checkinteger(L, 1);
    lua_pushinteger(L, fileXioUmount(PFS));
    return 1;
}

static int lua_GetHDDStatus(lua_State *L)
{
    lua_pushinteger(L, fileXioDevctl("hdd0:", HDIOC_STATUS, NULL, 0, NULL, 0));
    return 1;
}

static int lua_GetHDDSMARTStatus(lua_State *L)
{
    lua_pushinteger(L, fileXioDevctl("hdd0:", HDIOC_SMARTSTAT, NULL, 0, NULL, 0));
    return 1;
}

static int lua_CheckHDDSectorError(lua_State *L)
{
    lua_pushinteger(L, fileXioDevctl("hdd0:", HDIOC_GETSECTORERROR, NULL, 0, NULL, 0));
    return 1;
}

static int lua_CheckDamagedPartitions(lua_State *L)
{
    char ErrorPartName[64] = "";
    int ret = fileXioDevctl("hdd0:", HDIOC_GETERRORPARTNAME, NULL, 0, ErrorPartName, sizeof(ErrorPartName));
    lua_pushinteger(L, ret);
    lua_pushstring(L, ErrorPartName);
    return 2;
}

static int lua_FormatHDD(lua_State *L)
{
    if (hddFormat() != 0)
        lua_pushboolean(L, false);
    else
        lua_pushboolean(L, true);

    return 1;

}

//this function comes from softdev2, alexparrado based this on FreeMcBoot installer.
static int EnableHDDBooting(lua_State *L)
{
	unsigned int OpResult;
    int result;
	unsigned char OSDConfigBuffer[15];

	do
	{
		sceCdOpenConfig(0, 0, 1, &OpResult);
	} while (OpResult & 9);

	do
	{
		result = sceCdReadConfig(OSDConfigBuffer, &OpResult);
	} while (OpResult & 9 || result == 0);

	do
	{
		result = sceCdCloseConfig(&OpResult);
	} while (OpResult & 9 || result == 0);

	if ((OSDConfigBuffer[0] & 3) != 2)
	{ //If ATAD support and HDD booting are not already activated.
        DPRINTF("HDDBooting: HDD Boot is disabled, activating...\n");
		OSDConfigBuffer[0] = (OSDConfigBuffer[0] & ~3) | 2;

		do
		{
			sceCdOpenConfig(0, 1, 1, &OpResult);
		} while (OpResult & 9);

		do
		{
			result = sceCdWriteConfig(OSDConfigBuffer, &OpResult);
		} while (OpResult & 9 || result == 0);

		do
		{
			result = sceCdCloseConfig(&OpResult);
		} while (OpResult & 9 || result == 0);

		result = 0;
	}
	else
		result = 1;
    lua_pushinteger(L, result);
	return 1;
}

static const luaL_Reg HDD_functions[] = {
  	{"MountPartition",           MountPart},
  	{"UMountPartition",          UmountPart},
  	{"Format",                   lua_FormatHDD},
  	{"GetStatus",                lua_GetHDDStatus},
  	{"GetSMARTStatus",           lua_GetHDDSMARTStatus},
  	{"CheckSectorError",         lua_CheckHDDSectorError},
  	{"CheckDamagedPartition",    lua_CheckDamagedPartitions},
  	{"EnableHDDBoot",            EnableHDDBooting},
    {0, 0}
};

void luaHDD_init(lua_State *L) 
{
    lua_newtable(L);
	luaL_setfuncs(L, HDD_functions, 0);
	lua_setglobal(L, "HDD");

	lua_pushinteger(L, FIO_MT_RDWR);
	lua_setglobal (L, "FIO_MT_RDWR");

	lua_pushinteger(L, FIO_MT_RDONLY);
	lua_setglobal (L, "FIO_MT_RDONLY");
}

int mnt(const char* path, int index, int openmod)
{
    char PFS[5+1] = "pfs0:";
    if (index > 0)
        PFS[3] = '0' + index;

    DPRINTF("Mounting '%s' into pfs%d:\n", path, index);
    if (fileXioMount(PFS, path, openmod) < 0) // mount
    {
        DPRINTF("Mount failed. unmounting trying again...\n");
        if (fileXioUmount(PFS) < 0) //try to unmount then mount again in case it got mounted by something else
        {
            DPRINTF("Unmount failed!!!\n");
        }
        if (fileXioMount(PFS, path, openmod) < 0)
        {
            DPRINTF("mount failed again!\n");
            return -1;
        } else {
            DPRINTF("Second mount succed!\n");
        }
    } else DPRINTF("mount successfull on first attemp\n");
    return 0;
}