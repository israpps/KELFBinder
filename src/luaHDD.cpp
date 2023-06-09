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
#include <errno.h>

#include "include/dbgprintf.h"
#include "include/strUtils.h"
#include "include/luaplayer.h"
#ifdef RESERVE_PFS0
extern int bootpath_is_on_HDD;
#endif

int mnt(const char* path, int index, int openmod);
int umnt(int indx);

static int MountPart(lua_State *L)
{

    int openmod = FIO_MT_RDWR;
    const char* mount;
#ifdef RESERVE_PFS0
    int indx = 1;
#else
    int indx = 0;
#endif
    int argc = lua_gettop(L);
	if (argc < 1 || argc >= 4) return luaL_error(L, "%s: wrong number of arguments, expected 1 or 2", __func__); 

    mount = luaL_checkstring(L, 1);
    if (argc >= 2) 
        indx = luaL_checkinteger(L, 2);
    if (argc == 3) 
        openmod = luaL_checkinteger(L, 3);
#ifdef RESERVE_PFS0
    if (indx == 0 && bootpath_is_on_HDD) luaL_error(L, "%s: pfs0:/ is reserved\n", __func__);
#endif
    DPRINTF("%s: %s %d %d\n", __func__, mount, indx, openmod);
    lua_pushinteger(L, mnt(mount, indx, openmod));
    return 1;

}

static int UmountPart(lua_State *L)
{
	if (lua_gettop(L) != 1) return luaL_error(L, "%s: wrong number of arguments, expected 1 integer", __func__);

    int index = luaL_checkinteger(L, 1);
    lua_pushinteger(L, umnt(index));
    return 1;
}

static int lua_GetHDDStatus(lua_State *L)
{
    int ret = fileXioDevctl("hdd0:", HDIOC_STATUS, NULL, 0, NULL, 0);
    DPRINTF("HDIOC_STATUS: %d\n", ret);
    lua_pushinteger(L, ret);
    return 1;
}

static int lua_GetHDDSMARTStatus(lua_State *L)
{
    int ret = fileXioDevctl("hdd0:", HDIOC_SMARTSTAT, NULL, 0, NULL, 0);
    DPRINTF("HDIOC_SMARTSTAT: %d\n", ret);
    lua_pushinteger(L, ret);
    return 1;
}

static int lua_CheckHDDSectorError(lua_State *L)
{
    int ret = fileXioDevctl("hdd0:", HDIOC_GETSECTORERROR, NULL, 0, NULL, 0);
    DPRINTF("HDIOC_GETSECTORERROR: %d\n", ret);
    lua_pushinteger(L, ret);
    return 1;
}

static int lua_CheckDamagedPartitions(lua_State *L)
{
    char ErrorPartName[64] = "";
    int ret = fileXioDevctl("hdd0:", HDIOC_GETERRORPARTNAME, NULL, 0, ErrorPartName, sizeof(ErrorPartName));
    DPRINTF("HDIOC_GETERRORPARTNAME: %d - [%s]\n", ret, ErrorPartName);
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

static int lua_installMBRKELF(lua_State *L)
{
    int argc = lua_gettop(L);
	if (argc != 1) return luaL_error(L, "%s: wrong number of arguments, expected only one", __func__); 

    const char* input = luaL_checkstring(L, 1);
    unsigned int size;
//
	int result = 0;
	iox_stat_t statFile;
	unsigned int numSectors;
	unsigned int sector;
	unsigned int remainder;
	unsigned int i;
	unsigned int numBytes;
    unsigned char* buffer = NULL;
	hddSetOsdMBR_t MBRInfo;

	//Buffer for I/O devctl operations on HDD
	uint8_t IOBuffer[512 + sizeof(hddAtaTransfer_t)] __attribute__((aligned(64)));

//()
    int fd = open(input, O_RDONLY);
    DPRINTF("%s: input fd is %d\n", __func__, fd); 
    if (fd < 0) {
            result = -201;
            DPRINTF("CANNOT OPEN INPUT KELF: %d error\n", fd);
    } 
    else
    {
        size = lseek(fd, 0, SEEK_END);
        DPRINTF("%s: KELF size is %d\n", __func__, size); 
        if (size < 0) {
            close(fd);
            result = -EIO;
        }
    }

    if (result >= 0)
    {
        lseek(fd, 0, SEEK_SET);
        if ((buffer = ( unsigned char * )malloc(size)) != NULL) {
            if ((read(fd, buffer, size)) != size) {
                DPRINTF("ERROR: Could not read %d bytes from file\n", size);
                result = -EIO;
            }
            close(fd);
        } else {
            DPRINTF("ERROR: failed to malloc %d bytes for MBR\n", size);
            result = -ENOMEM;
        }
    }
//()
    if (result >= 0)
    {
	    if ((result = fileXioGetStat("hdd0:__mbr", &statFile)) >= 0)
	    {
	    	//Sector to write
	    	sector = statFile.private_5 + 0x2000;

	    	//Bytes in last sector
	    	remainder = (size & 0x1FF);

	    	//Total sectors to inject
	    	numSectors = (size / 512) + ((remainder) ? 1 : 0);
	    	numBytes = 512;
            DPRINTF("Beginning MBR writing... %d sectors to be written.\n", numSectors);
	    	//Writes sectors
	    	for (i = 0; i < numSectors; i++)
	    	{
	    		//If last sector
	    		if ((i == (numSectors - 1)) && (remainder != 0))
	    		{
	    			numBytes = remainder;
	    			//Performs read operation for one sector
	    			((hddAtaTransfer_t *)IOBuffer)->lba = sector + i;
	    			((hddAtaTransfer_t *)IOBuffer)->size = 1;
	    			if ((result = fileXioDevctl("hdd0:", APA_DEVCTL_ATA_READ, IOBuffer, sizeof(hddAtaTransfer_t), IOBuffer + sizeof(hddAtaTransfer_t), 512)) < 0)
	    		    {
                        DPRINTF("ERROR: failed to read final sector on MBR install (%d)\n", result);
                    	break;
                    }
	    		}
	    		//Copies from buffer
	    		memcpy(IOBuffer + sizeof(hddAtaTransfer_t), buffer + 512 * i, numBytes);
	    		//Performs write operation for one sector
	    		((hddAtaTransfer_t *)IOBuffer)->lba = sector + i;
	    		((hddAtaTransfer_t *)IOBuffer)->size = 1;

	    		if ((result = fileXioDevctl("hdd0:", APA_DEVCTL_ATA_WRITE, IOBuffer, 512 + sizeof(hddAtaTransfer_t), NULL, 0)) < 0)
	    		{
                    DPRINTF("ERROR: failed to write MBR program (%d) while writing to sector %d\n", result, sector + i);
                	break;
                }
	    	}
	    	//Writes MBR information
	    	if (result >= 0)
	    	{
	    		MBRInfo.start = sector;
	    		MBRInfo.size = numSectors;
	    		fileXioDevctl("hdd0:", APA_DEVCTL_SET_OSDMBR, &MBRInfo, sizeof(MBRInfo), NULL, 0);
	    	}
	    } else {
            DPRINTF("ERROR: Cannot stat __mbr\n");
        }
    }
    if (buffer != NULL)
        free(buffer);
    DPRINTF("MBR INSTALL: finished with result %d\n", result);
    lua_pushinteger(L, result);
//
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
        DPRINTF("%s: HDD Boot is disabled, activating...\n", __func__);
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

		result = 0; // HDD Boot enabled
	}
	else
		result = 1; //it was already enabled
    lua_pushinteger(L, result);
	return 1;
}

static int getpartitionsizeKB(lua_State *L)
{
    char PFS[5+1] = "pfs0:";
    int argc = lua_gettop(L);
    unsigned int AvailableSpace = 0;
    int pfs_index = 0;
	if (argc != 1 && argc != 2) 
        return luaL_error(L, "%s: wrong number of arguments, expected one or two argumments", __func__); 

    const char* partition = luaL_checkstring(L, 1);
    if (argc == 2) 
        pfs_index = luaL_checkinteger(L, 2);
    PFS[3] = '0' + pfs_index;

	if (mnt(partition, pfs_index, FIO_MT_RDONLY) == 0) {
        AvailableSpace = (unsigned int)(fileXioDevctl(PFS, PDIOC_ZONEFREE, NULL, 0, NULL, 0) * fileXioDevctl(PFS, PDIOC_ZONESZ, NULL, 0, NULL, 0));
        DPRINTF("\tFree space on '%s' is [%uB | %dMb]\n", partition, AvailableSpace, ((AvailableSpace / 1024) / 1024));
        umnt(pfs_index);
        lua_pushinteger(L, AvailableSpace);
    } else {
        DPRINTF("%s: impossible to mount '%s' into %s:, returning %d\n", __func__, partition, PFS, -ENOENT);
        lua_pushinteger(L, -ENOENT);
    }
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
  	{"InstallBootstrap",         lua_installMBRKELF},
    {"GetPartitionSize",         getpartitionsizeKB},
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
            DPRINTF("Second mount succeeded!\n");
        }
    } else DPRINTF("mount successfull on first attemp\n");
    return 0;
}

int umnt(int indx)
{
    char PFS[5+1] = "pfs0:";
    PFS[3] = '0' + indx;
    int ret = fileXioUmount(PFS);
    DPRINTF("%s: pfs%d: returned %d\n", __func__, indx, ret);
    return ret;
}