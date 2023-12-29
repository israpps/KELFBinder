#include <unistd.h>
#include <libmc.h>
#include <malloc.h>
#include <errno.h>
#include <sys/fcntl.h>
#include <dirent.h>
#include <sys/stat.h>
#include "include/luaplayer.h"
#include "include/md5.h"
#include "include/graphics.h"

#include "include/system.h"
#include "include/dbgprintf.h"

#define MAX_DIR_FILES 512
extern int AllowPoweroff;

void recursive_mkdir(char *dir);

static int lua_getCurrentDirectory(lua_State *L)
{
    char path[256];
    getcwd(path, 256);
    lua_pushstring(L, path);

    return 1;
}

static int lua_setCurrentDirectory(lua_State *L)
{
    static char temp_path[256];
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: System.currentDirectory(file) takes a filename as string as argument.");

    lua_getCurrentDirectory(L);

    // let's do what the ps2sdk should do,
    // some normalization... :)
    // if absolute path (contains [drive]:path/)
    if (strchr(path, ':')) {
        strcpy(temp_path, path);
    } else // relative path
    {
        // remove last directory ?
        if (!strncmp(path, "..", 2)) {
            getcwd(temp_path, 256);
            if ((temp_path[strlen(temp_path) - 1] != ':')) {
                int idx = strlen(temp_path) - 1;
                do {
                    idx--;
                } while (temp_path[idx] != '/');
                temp_path[idx] = '\0';
            }

        }
        // add given directory to the existing path
        else {
            getcwd(temp_path, 256);
            strcat(temp_path, "/");
            strcat(temp_path, path);
        }
    }

    DPRINTF("changing directory to %s\n", __ps2_normalize_path(temp_path)); 
    chdir(__ps2_normalize_path(temp_path));

    return 1;
}

static int lua_AllowPowerOFF(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1)
        return luaL_error(L, "AllowPoweroff needs 1 argumment only");
    AllowPoweroff = luaL_checkinteger(L, 1);
    //if (AllowPoweroff > 1) AllowPoweroff = 1;
    return 0;
}

static int lua_curdir(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc == 0)
        return lua_getCurrentDirectory(L);
    if (argc == 1)
        return lua_setCurrentDirectory(L);
    return luaL_error(L, "Argument error: System.currentDirectory([file]) takes zero or one argument.");
}

static int lua_direxists(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1)
        return luaL_error(L, "Argument error: lua_direxists takes one argument.");
    const char *folder = luaL_checkstring(L, 1);
    DPRINTF("%s: %s\n", __func__, folder);
    DIR *d = opendir(folder);
    bool ret = false;
	if (d) 
    {
        ret = true;
        if (closedir(d) != 0)
            DPRINTF("### ERROR: cannot close dir (%d)\n", errno);
    } else {
        ret = false;
    }
    DPRINTF("\t%s %s\n", folder, (ret)? "exists":"not found");
    lua_pushboolean(L, ret);
    return 1;
}

static int lua_dir(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 0 && argc != 1)
        return luaL_error(L, "Argument error: System.listDirectory([path]) takes zero or one argument.");

    const char *temp_path = "";
    char path[255];

    getcwd((char *)path, 256);

    if (argc != 0) {
        temp_path = luaL_checkstring(L, 1);
        // append the given path to the boot_path

        strcpy((char *)path, boot_path);

        if (strchr(temp_path, ':'))
            // workaround in case of temp_path is containing
            // a device name again
            strcpy((char *)path, temp_path);
        else
            strcat((char *)path, temp_path);
    }

    strcpy(path, __ps2_normalize_path(path));
    DPRINTF("\nchecking path : %s\n", path); 



    //-----------------------------------------------------------------------------------------

    // read from MC ?

    if (!strcmp(path, "mc0:") || !strcmp(path, "mc1:")) {
        int nPort;
        int numRead;
        char mcPath[256];
        sceMcTblGetDir mcEntries[MAX_DIR_FILES] __attribute__((aligned(64)));

        if (!strcmp(path, "mc0:"))
            nPort = 0;
        else
            nPort = 1;


        // copy only the path without the device (ie : mc0:/xxx/xxx -> /xxx/xxx)
        strcpy(mcPath, (char *)&path[4]);

        // it temp_path is empty put a "/" inside
        if (strlen(mcPath) == 0)
            strcpy((char *)mcPath, (char *)"/");


        if (mcPath[strlen(mcPath) - 1] != '/')
            strcat(mcPath, "/-*");
        else
            strcat(mcPath, "*");

        mcGetDir(nPort, 0, mcPath, 0, MAX_DIR_FILES, mcEntries);
        while (!mcSync(MC_WAIT, NULL, &numRead))
            ;

        int cpt = 1;
        lua_newtable(L);

        for (int i = 0; i < numRead; i++) {
            lua_pushnumber(L, cpt++); // push key for file entry

            lua_newtable(L);
            lua_pushstring(L, "name");
            lua_pushstring(L, (const char *)mcEntries[i].EntryName);
            lua_settable(L, -3);

            lua_pushstring(L, "size");
            lua_pushnumber(L, mcEntries[i].FileSizeByte);
            lua_settable(L, -3);

            lua_pushstring(L, "directory");
            lua_pushboolean(L, (mcEntries[i].AttrFile & MC_ATTR_SUBDIR));
            lua_settable(L, -3);
            lua_settable(L, -3);
        }
        return 1; // table is already on top
    }
    //-----------------------------------------------------------------------------------------

    // else regular one using Dopen/Dread

    int i = 1;

    DIR *d;
    struct dirent *dir;
    d = opendir(path);
    lua_newtable(L);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            lua_pushnumber(L, i++); // push key for file entry
            lua_newtable(L);
            lua_pushstring(L, "name");
            lua_pushstring(L, dir->d_name);
            lua_settable(L, -3);

            lua_pushstring(L, "directory");
            lua_pushboolean(L, (dir->d_type == DT_DIR));
            lua_settable(L, -3);
            lua_settable(L, -3);
        }
        closedir(d);
    } else {
        lua_pushnil(L); // return nil
        return 1;
    }
    return 1; /* table is already on top */
}

static int lua_createDir(lua_State *L)
{
    DPRINTF("%s: start\n", __FUNCTION__); 
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: System.createDirectory(directory) takes a directory name as string as argument.");
    int ret = mkdir(path, 0777);
    DPRINTF("\tmkdir: path '%s'. result = %d\n", path, ret);
    return 0;
}

static int lua_recursivemkdir(lua_State *L)
{
    if (lua_gettop(L) != 1)
        return luaL_error(L, "%s: one argumment expected with path.", __func__);
    char* path = (char*)luaL_checkstring(L, 1);
    recursive_mkdir(path);
    return 0;
}

static int lua_removeDir(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: System.removeDirectory(directory) takes a directory name as string as argument.");
    rmdir(path);

    return 0;
}
//=============================================================
/// DeleteFolder(); function was SP193's FreeMcBoot installer.
//thanks to SP193 for all his work
static int DeleteFolder(const char *folder)
{
    DPRINTF("\n%s: '%s'\n", __FUNCTION__, folder); 
	DIR *d = opendir(folder);
	size_t path_len = strlen(folder);
	int r = -1;

	if (d)
	{
		DPRINTF("Folder exists. wiping...\n"); 
		struct dirent *p;

		r = 0;
		while (!r && (p = readdir(d)))
		{
			int r2 = -1;
			char *buf;
			size_t len;

			/* Skip the names "." and ".." as we don't want to recurse on them. */
			if (!strcmp(p->d_name, ".") || !strcmp(p->d_name, ".."))
				continue;

			len = path_len + strlen(p->d_name) + 2;
			buf = (char*)malloc(len);

			if (buf)
			{
				struct stat statbuf;

				snprintf(buf, len, "%s/%s", folder, p->d_name);
				if (!stat(buf, &statbuf))
				{
					if (S_ISDIR(statbuf.st_mode))
						r2 = DeleteFolder(buf);
					else
						r2 = unlink(buf);
				}
				free(buf);
			}
			r = r2;
		}
		closedir(d);
	}

	if (!r)
		r = rmdir(folder);

	return r;
}

static int lua_wipedir(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: lua_wipedir takes a directory name as string as argument.");
    DeleteFolder(path);

    return 0;
}

static int lua_movefile(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: System.removeFile(filename) takes a filename as string as argument.");
    const char *oldName = luaL_checkstring(L, 1);
    const char *newName = luaL_checkstring(L, 2);
    if (!oldName || !newName)
        return luaL_error(L, "Argument error: System.rename(source, destination) takes two filenames as strings as arguments.");

    char buf[BUFSIZ];
    size_t size;

    int source = open(oldName, O_RDONLY, 0);
    int dest = open(newName, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    while ((size = read(source, buf, BUFSIZ)) > 0) {
        write(dest, buf, size);
    }

    close(source);
    close(dest);

    remove(oldName);

    return 0;
}

static int lua_removeFile(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    if (!path)
        return luaL_error(L, "Argument error: System.removeFile(filename) takes a filename as string as argument.");
    remove(path);

    return 0;
}

static int lua_rename(lua_State *L)
{
    const char *oldName = luaL_checkstring(L, 1);
    const char *newName = luaL_checkstring(L, 2);
    if (!oldName || !newName)
        return luaL_error(L, "Argument error: System.rename(source, destination) takes two filenames as strings as arguments.");

    char buf[BUFSIZ];
    size_t size;

    int source = open(oldName, O_RDONLY, 0);
    int dest = open(newName, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    while ((size = read(source, buf, BUFSIZ)) > 0) {
        write(dest, buf, size);
    }

    close(source);
    close(dest);

    remove(oldName);

    return 0;
}

static int lua_copyfile(lua_State *L)
{
    const char *ogfile = luaL_checkstring(L, 1);
    const char *newfile = luaL_checkstring(L, 2);
    if (!ogfile || !newfile)
        return luaL_error(L, "%s expected two strings as arguments.", __func__);
    DPRINTF("%s: Copying [%s] to [%s]\n", __func__, ogfile, newfile); 
    char buf[BUFSIZ];
    size_t size;

    int source = open(ogfile, O_RDONLY, 0);
    int dest = open(newfile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    int ret = 0;
    if ((dest < 0) || (source < 0)) 
    {
        ret = (source < 0) ? source : dest; //source not accessible is ENOENT. else I/O ERR
        DPRINTF("### CANT OPEN %s (%d)\n", (source < 0) ? "source" : "destination", ret);
    } 
    else
    {
        while ((size = read(source, buf, BUFSIZ)) > 0) {
            if (write(dest, buf, size) != size)
                {
                    DPRINTF("### CANT WRITE %d bytes to destination\n", size);
                    ret = -EIO;
                    goto err;
                }
        }
    }
err:
    if (source >= 0)
        close(source);
    if (dest >= 0)
        close(dest);
    lua_pushinteger(L, ret);
    return 1;
}

static char modulePath[256];

static void setModulePath()
{
    getcwd(modulePath, 256);
}

static int lua_md5sum(lua_State *L)
{
    size_t size;
    const char *string = luaL_checklstring(L, 1, &size);
    if (!string)
        return luaL_error(L, "Argument error: System.md5sum(string) takes a string as argument.");

    int i;
    char result[33];
    u8 digest[16];

    MD5_CTX ctx;
    MD5Init(&ctx);
    MD5Update(&ctx, (u8 *)string, size);
    MD5Final(digest, &ctx);

    for (i = 0; i < 16; i++)
        sprintf(result + 2 * i, "%02x", digest[i]);
    lua_pushstring(L, result);

    return 1;
}

static int lua_sleep(lua_State *L)
{
    if (lua_gettop(L) != 1)
        return luaL_error(L, "seconds expected.");
    int sec = luaL_checkinteger(L, 1);
    sleep(sec);
    return 0;
}

static int lua_getFreeMemory(lua_State *L)
{
    if (lua_gettop(L) != 0)
        return luaL_error(L, "no arguments expected.");

    size_t result = GetFreeSize();

    lua_pushinteger(L, (uint32_t)(result));
    return 1;
}

static int lua_exit(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 0)
        return luaL_error(L, "System.exitToBrowser");
    asm volatile(
        "li $3, 0x04;"
        "syscall;"
        "nop;");
    return 0;
}

void recursive_mkdir(char *dir)
{
    char *p = dir;
    while (p) {
        char *p2 = strstr(p, "/");
        if (p2) {
            p2[0] = 0;
            mkdir(dir, 0777);
            p = p2 + 1;
            p2[0] = '/';
        } else
            break;
    }
}

static int lua_getmcinfo(lua_State *L)
{
    int argc = lua_gettop(L);
    int type, freespace, format;
    int result, syncret, inforet;

    int mcslot = 0;
    if (argc == 1)
        mcslot = luaL_checkinteger(L, 1);

    inforet = mcGetInfo(mcslot, 0, &type, &freespace, &format);
    syncret = mcSync(0, NULL, &result);

    DPRINTF("\nSLOT=%d\ttype=%d, freespace=%d, format=%d, inforet=%d\n"
            "\tmcSync.result=%d mcSync.syncret=%d\n",
            mcslot, type, freespace, format, inforet,
            result, syncret); 

    lua_newtable(L);

    lua_pushstring(L, "type");
    lua_pushinteger(L, type);
    lua_settable(L, -3);

    lua_pushstring(L, "freemem");
    lua_pushinteger(L, freespace);
    lua_settable(L, -3);

    lua_pushstring(L, "format");
    lua_pushinteger(L, format);
    lua_settable(L, -3);

    return 1;
}

static int lua_openfile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 2)
        return luaL_error(L, "wrong number of arguments");
    const char *file_tbo = luaL_checkstring(L, 1);
    int type = luaL_checkinteger(L, 2);
    int fileHandle = open(file_tbo, type, 0777);
    if (fileHandle < 0)
        return luaL_error(L, "cannot open requested file.\n\t'%s'\n\tfd: %d\n", file_tbo, fileHandle);
    lua_pushinteger(L, fileHandle);
    return 1;
}

static int lua_readfile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 2)
        return luaL_error(L, "wrong number of arguments");
    int file = luaL_checkinteger(L, 1);
    uint32_t size = luaL_checkinteger(L, 2);
    uint8_t *buffer = (uint8_t *)malloc(size + 1);
    int len = read(file, buffer, size);
    buffer[len] = 0;
    lua_pushlstring(L, (const char *)buffer, len);
    free(buffer);
    return 1;
}

static int lua_writefile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 3)
        return luaL_error(L, "wrong number of arguments");
    int fileHandle = luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    int size = luaL_checknumber(L, 3);
    write(fileHandle, text, size);
    return 0;
}

static int lua_closefile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1)
        return luaL_error(L, "wrong number of arguments");
    int fileHandle = luaL_checkinteger(L, 1);
    close(fileHandle);
    return 0;
}

static int lua_seekfile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 3)
        return luaL_error(L, "wrong number of arguments");
    int fileHandle = luaL_checkinteger(L, 1);
    int pos = luaL_checkinteger(L, 2);
    uint32_t type = luaL_checkinteger(L, 3);
    lseek(fileHandle, pos, type);
    return 0;
}

static int lua_sizefile(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1)
        return luaL_error(L, "wrong number of arguments");
    int fileHandle = luaL_checkinteger(L, 1);
    uint32_t cur_off = lseek(fileHandle, 0, SEEK_CUR);
    uint32_t size = lseek(fileHandle, 0, SEEK_END);
    lseek(fileHandle, cur_off, SEEK_SET);
    lua_pushinteger(L, size);
    return 1;
}

int file_exist(const char* path)
{
    int fd = -ENOENT;
    fd = open(path, O_RDONLY, 0777);
    if (fd < 0) 
    {
        return false;
    } else
    {
        close(fd);
        return true;
    }
}

static int lua_checkexist(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1)
        return luaL_error(L, "wrong number of arguments");
    const char *file = luaL_checkstring(L, 1);

    lua_pushboolean(L, file_exist(file));
    return 1;
}


static int lua_loadELF(lua_State *L)
{
    size_t size;
    const char *elftoload = luaL_checklstring(L, 1, &size);
    if (!elftoload)
        return luaL_error(L, "Argument error: System.loadELF() takes a string as argument.");
    load_elf_NoIOPReset(elftoload);
    return 1;
}

DiscType DiscTypes[] = {
    {SCECdGDTFUNCFAIL, "FAIL", -1},
    {SCECdNODISC, "!", 1},
    {SCECdDETCT, "??", 2},
    {SCECdDETCTCD, "CD ?", 3},
    {SCECdDETCTDVDS, "DVD-SL ?", 4},
    {SCECdDETCTDVDD, "DVD-DL ?", 5},
    {SCECdUNKNOWN, "Unknown", 6},
    {SCECdPSCD, "PS1 CD", 7},
    {SCECdPSCDDA, "PS1 CDDA", 8},
    {SCECdPS2CD, "PS2 CD", 9},
    {SCECdPS2CDDA, "PS2 CDDA", 10},
    {SCECdPS2DVD, "PS2 DVD", 11},
    {SCECdESRDVD_0, "ESR DVD (off)", 12},
    {SCECdESRDVD_1, "ESR DVD (on)", 13},
    {SCECdCDDA, "Audio CD", 14},
    {SCECdDVDV, "Video DVD", 15},
    {SCECdIllegalMedia, "Unsupported", 16},
    {0x00, "", 0x00} // end of list
};                   // ends DiscTypes array


static int lua_checkValidDisc(lua_State *L)
{
    int testValid;
    int result;
    result = 0;
    testValid = sceCdGetDiskType();
    switch (testValid) {
        case SCECdPSCD:
        case SCECdPSCDDA:
        case SCECdPS2CD:
        case SCECdPS2CDDA:
        case SCECdPS2DVD:
        case SCECdESRDVD_0:
        case SCECdESRDVD_1:
        case SCECdCDDA:
        case SCECdDVDV:
        case SCECdDETCTCD:
        case SCECdDETCTDVDS:
        case SCECdDETCTDVDD:
            result = 1;
        case SCECdNODISC:
        case SCECdDETCT:
        case SCECdUNKNOWN:
        case SCECdIllegalMedia:
            result = 0;
    }
    DPRINTF("Valid Disc: %d\n", result); 
    lua_pushinteger(L, result); // return the value itself to Lua stack
    return 1;                   // return value quantity on stack
}

static int lua_checkDiscTray(lua_State *L)
{
    int result;
    if (sceCdStatus() == SCECdStatShellOpen) {
        result = 1;
    } else {
        result = 0;
    }
    lua_pushinteger(L, result); // return the value itself to Lua stack
    return 1;                   // return value quantity on stack
}


static int lua_getDiscType(lua_State *L)
{
    int discType;
    int iz;
    discType = sceCdGetDiskType();

    int DiscType_ix = 0;
    for (iz = 0; DiscTypes[iz].name[0]; iz++)
        if (DiscTypes[iz].type == discType)
            DiscType_ix = iz;
    DPRINTF("getDiscType: %d\n", DiscTypes[DiscType_ix].value); 
    lua_pushinteger(L, DiscTypes[DiscType_ix].value); // return the value itself to Lua stack
    return 1;                                         // return value quantity on stack
}

extern void *_gp;

#define BUFSIZE (64 * 1024)

static volatile off_t progress, max_progress;

struct pathMap
{
    const char *in;
    const char *out;
};

static int copyThread(void *data)
{
    pathMap *paths = (pathMap *)data;

    char buffer[BUFSIZE];
    int in = open(paths->in, O_RDONLY, 0);
    int out = open(paths->out, O_WRONLY | O_CREAT | O_TRUNC, 644);

    // Get the input file size
    uint32_t size = lseek(in, 0, SEEK_END);
    lseek(in, 0, SEEK_SET);

    progress = 0;
    max_progress = size;

    ssize_t bytes_read;
    while ((bytes_read = read(in, buffer, BUFSIZE)) > 0) {
        write(out, buffer, bytes_read);
        progress += bytes_read;
    }

    // copy is done, or an error occurred
    close(in);
    close(out);
    free(paths);
    ExitDeleteThread();
    return 0;
}

static int lua_copyasync(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 2)
        return luaL_error(L, "wrong number of arguments");

    pathMap *copypaths = (pathMap *)malloc(sizeof(pathMap));

    copypaths->in = luaL_checkstring(L, 1);
    copypaths->out = luaL_checkstring(L, 2);

    static u8 copyThreadStack[65 * 1024] __attribute__((aligned(16)));

    ee_thread_t thread_param;

    thread_param.gp_reg = &_gp;
    thread_param.func = (void *)copyThread;
    thread_param.stack = (void *)copyThreadStack;
    thread_param.stack_size = sizeof(copyThreadStack);
    thread_param.initial_priority = 0x12;
    int thread = CreateThread(&thread_param);

    StartThread(thread, (void *)copypaths);
    return 0;
}

static int lua_getfileprogress(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 0)
        return luaL_error(L, "wrong number of arguments");

    lua_newtable(L);

    lua_pushstring(L, "current");
    lua_pushinteger(L, (int)progress);
    lua_settable(L, -3);

    lua_pushstring(L, "final");
    lua_pushinteger(L, (int)max_progress);
    lua_settable(L, -3);

    return 1;
}

static int lua_getbootpath(lua_State *L)
{
    lua_pushstring(L, boot_path);
    return 1;
}

static int lua_printf(lua_State *L)
{
    DPRINTF(luaL_checkstring(L, 1)); 
    return 0;
}

static const luaL_Reg System_functions[] = {
    {"log",          lua_printf},
    {"getbootpath", lua_getbootpath},
    {"AllowPowerOffButton", lua_AllowPowerOFF},
    {"openFile", lua_openfile},
    {"readFile", lua_readfile},
    {"writeFile", lua_writefile},
    {"closeFile", lua_closefile},
    {"seekFile", lua_seekfile},
    {"sizeFile", lua_sizefile},
    //{"doesFileExist", lua_checkexist}, BREAKS ERROR HANDLING IF DECLARED INSIDE TABLE. DONT ASK ME WHY
    {"doesDirExist", lua_direxists},
    {"currentDirectory", lua_curdir},
    {"listDirectory", lua_dir},
    {"createDirectory", lua_createDir},
    {"createDirectoryRecursive", lua_recursivemkdir},
    {"removeDirectory", lua_removeDir},
    {"WipeDirectory", lua_wipedir},
    {"moveFile", lua_movefile},
    {"copyFile", lua_copyfile},
    {"threadCopyFile", lua_copyasync},
    {"getFileProgress", lua_getfileprogress},
    {"removeFile", lua_removeFile},
    {"rename", lua_rename},
    {"md5sum", lua_md5sum},
    {"sleep", lua_sleep},
    {"getFreeMemory", lua_getFreeMemory},
    {"exitToBrowser", lua_exit},
    {"getMCInfo", lua_getmcinfo},
    {"loadELF", lua_loadELF},
    {"checkValidDisc", lua_checkValidDisc},
    {"getDiscType", lua_getDiscType},
    {"checkDiscTray", lua_checkDiscTray},
    {0, 0}};


static int lua_sifloadmodule(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 1 && argc != 3)
        return luaL_error(L, "wrong number of arguments");
    const char *path = luaL_checkstring(L, 1);

    int arg_len = 0;
    const char *args = NULL;

    if (argc == 3) {
        arg_len = luaL_checkinteger(L, 2);
        args = luaL_checkstring(L, 3);
    }


    int result = SifLoadModule(path, arg_len, args);
    lua_pushinteger(L, result);
    return 1;
}


static int lua_sifloadmodulebuffer(lua_State *L)
{
    int argc = lua_gettop(L);
    if (argc != 2 && argc != 4)
        return luaL_error(L, "wrong number of arguments");
    const char *ptr = luaL_checkstring(L, 1);
    int size = luaL_checkinteger(L, 2);

    int arg_len = 0;
    const char *args = NULL;

    if (argc == 4) {
        arg_len = luaL_checkinteger(L, 3);
        args = luaL_checkstring(L, 4);
    }

    int result = SifExecModuleBuffer((void *)ptr, size, arg_len, args, NULL);
    lua_pushinteger(L, result);
    return 1;
}

static const luaL_Reg Sif_functions[] = {
    {"loadModule", lua_sifloadmodule},
    {"loadModuleBuffer", lua_sifloadmodulebuffer},

    {0, 0}};

void luaSystem_init(lua_State *L)
{
	lua_register(L, "doesFileExist", lua_checkexist);
    setModulePath();
    lua_newtable(L);
    luaL_setfuncs(L, System_functions, 0);
    lua_setglobal(L, "System");

    lua_newtable(L);
    luaL_setfuncs(L, Sif_functions, 0);
    lua_setglobal(L, "Sif");

    lua_pushinteger(L, O_RDONLY);
    lua_setglobal(L, "FREAD");

    lua_pushinteger(L, O_WRONLY);
    lua_setglobal(L, "FWRITE");

    lua_pushinteger(L, O_CREAT | O_WRONLY);
    lua_setglobal(L, "FCREATE");

    lua_pushinteger(L, O_RDWR);
    lua_setglobal(L, "FRDWR");

    lua_pushinteger(L, SEEK_SET);
    lua_setglobal(L, "SET");

    lua_pushinteger(L, SEEK_END);
    lua_setglobal(L, "END");

    lua_pushinteger(L, SEEK_CUR);
    lua_setglobal(L, "CUR");

    lua_pushinteger(L, 1);
    lua_setglobal(L, "READ_ONLY");

    lua_pushinteger(L, 2);
    lua_setglobal(L, "READ_WRITE");
}
