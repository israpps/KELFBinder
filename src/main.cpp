
#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sifrpc.h>
#include <loadfile.h>
#include <libmc.h>
#include <libcdvd.h>
#include <iopheap.h>
#include <iopcontrol.h>
#include <iopcontrol_special.h>
#include <smod.h>
#include <usbhdfsd-common.h>
#include <libpwroff.h>
// #include <audsrv.h>
#include <sys/stat.h>

#include <dirent.h>

#include <sbv_patches.h>
#include <smem.h>

#include "include/graphics.h"
// #include "include/sound.h"
#include "include/luaplayer.h"
#include "include/pad.h"

#define NEWLIB_PORT_AWARE
#include <fileXio_rpc.h>
#include <fileio.h>

extern "C" {
#include <libds34bt.h>
#include <libds34usb.h>
}

#include "include/dbgprintf.h"

#define IMPORT_BIN2C(_n)       \
    extern unsigned char _n[]; \
    extern unsigned int size_##_n

int AllowPoweroff;
static int HaveFileXio;
extern char bootString[];
extern unsigned int size_bootString;

IMPORT_BIN2C(iomanX_irx);
IMPORT_BIN2C(fileXio_irx);
IMPORT_BIN2C(sio2man_irx);
IMPORT_BIN2C(mcman_irx);
IMPORT_BIN2C(mcserv_irx);
IMPORT_BIN2C(padman_irx);
IMPORT_BIN2C(libsd_irx);
IMPORT_BIN2C(cdfs_irx);
IMPORT_BIN2C(usbd_irx);
IMPORT_BIN2C(bdm_irx);
IMPORT_BIN2C(bdmfs_vfat_irx);
IMPORT_BIN2C(usbmass_bd_irx);
// IMPORT_BIN2C(audsrv_irx);
IMPORT_BIN2C(ds34usb_irx);
IMPORT_BIN2C(ds34bt_irx);
IMPORT_BIN2C(secrsif_irx);
IMPORT_BIN2C(secrman_irx);
IMPORT_BIN2C(IOPRP);
IMPORT_BIN2C(poweroff_irx);

char boot_path[255];
char ConsoleROMVER[17];

void setLuaBootPath(int argc, char **argv, int idx)
{
    if (argc >= (idx + 1)) {

        char *p;
        if ((p = strrchr(argv[idx], '/')) != NULL) {
            snprintf(boot_path, sizeof(boot_path), "%s", argv[idx]);
            p = strrchr(boot_path, '/');
            if (p != NULL)
                p[1] = '\0';
        } else if ((p = strrchr(argv[idx], '\\')) != NULL) {
            snprintf(boot_path, sizeof(boot_path), "%s", argv[idx]);
            p = strrchr(boot_path, '\\');
            if (p != NULL)
                p[1] = '\0';
        } else if ((p = strchr(argv[idx], ':')) != NULL) {
            snprintf(boot_path, sizeof(boot_path), "%s", argv[idx]);
            p = strchr(boot_path, ':');
            if (p != NULL)
                p[1] = '\0';
        }
    }

    // check if path needs patching
    if (!strncmp(boot_path, "mass:/", 6) && (strlen(boot_path) > 6)) {
        strcpy((char *)&boot_path[5], (const char *)&boot_path[6]);
    }

    DPRINTF("%s: boot_path=%s\n", __func__, boot_path);
}


void initMC(void)
{
    int ret;
    // mc variables
    int mc_Type, mc_Free, mc_Format;


    DPRINTF("initMC: Initializing Memory Card\n");

    ret = mcInit(MC_TYPE_XMC);

    if (ret < 0) {
        DPRINTF("initMC: failed to initialize memcard server.\n");
    } else {
        DPRINTF("initMC: memcard server started successfully.\n");
    }

    // Since this is the first call, -1 should be returned.
    // makes me sure that next ones will work !
    mcGetInfo(0, 0, &mc_Type, &mc_Free, &mc_Format);
    mcSync(MC_WAIT, NULL, &ret);
}

void alternative_poweroff(void *arg)
{ // Power button was pressed. If no installation is in progress, begin shutdown of the PS2.
    DPRINTF("%s: called\n", __func__);
    if (AllowPoweroff == 1) {
        // If dev9.irx was loaded successfully, shut down DEV9.
        // As required by some (typically 2.5") HDDs, issue the SCSI STOP UNIT command to avoid causing an emergency park.
        if (HaveFileXio)
            fileXioDevctl("mass:", USBMASS_DEVCTL_STOP_ALL, NULL, 0, NULL, 0);

        /* Power-off the PlayStation 2 console. */
        poweroffShutdown();
    }
}

#include "SIOCookie.h"
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sio.h>

// GLOBAL
// char PRINTFBUG[64];
FILE *EE_SIO;
cookie_io_functions_t COOKIE_FNCTS;

ssize_t cookie_sio_write(void *c, const char *buf, size_t size);
ssize_t cookie_sio_read(void *c, char *buf, size_t size);
// int cookie_sio_seek(void *c, _off64_t *offset, int whence);
// int cookie_sio_close(void *c);

int ee_sio_start(u32 baudrate, u8 lcr_ueps, u8 lcr_upen, u8 lcr_usbl, u8 lcr_umode)
{
    sio_init(baudrate, lcr_ueps, lcr_upen, lcr_usbl, lcr_umode);

    COOKIE_FNCTS.read = cookie_sio_read;
    COOKIE_FNCTS.close = NULL;
    COOKIE_FNCTS.seek = NULL;
    COOKIE_FNCTS.write = cookie_sio_write;
    // fclose(stdout);
    EE_SIO = fopencookie(NULL, "w+", COOKIE_FNCTS);
    stdout = fopencookie(NULL, "w+", COOKIE_FNCTS); // fprintf does not replace format specifiers on C++. hook into stdout instead
    // setbuf(stdout, NULL);
    // setvbuf(EE_SIO, NULL, _IONBF, 0); // no buffering for this bad boy
    //  setvbuf(stdout, NULL, _IONBF, 1); // no buffering for this bad boy
    // fprintf(EE_SIO, "%s: finished\n", __func__);
    printf("lol %d\r\n", baudrate);
    fflush(stdout);
    printf("lol %d\n", baudrate);
    return EESIO_SUCESS;
}


ssize_t cookie_sio_write(void *c, const char *buf, size_t size)
{
    return sio_putsn(buf);
}

ssize_t cookie_sio_read(void *c, char *buf, size_t size)
{
    return sio_read(buf, size);
}


int main(int argc, char *argv[])
{
    int fd;
    init_scr();
    const char *errMsg;
    int ret = -1, STAT;
#ifdef RESET_IOP
    SifInitRpc(0);
    // ONLY ONE OF THE LINES BETWEEN THESE TWO COMMENTS CAN BE ENABLED AT THE SAME TIME
    // while (!SifIopReset("", 0)){}; // common IOP Reset
    SifIopRebootBuffer(IOPRP, size_IOPRP); // use IOPRP image with SECRMAN_special inside. ensures only the minimal and necessary IRXes are inside.
    // ONLY ONE OF THE LINES BETWEEN THESE TWO COMMENTS CAN BE ENABLED AT THE SAME TIME
    while (!SifIopSync()) {};
    SifInitRpc(0);
#endif

    DPRINTF_INIT();
    // install sbv patch fix
    DPRINTF("Installing SBV Patches...\n");
    sbv_patch_enable_lmb();
    sbv_patch_disable_prefix_check();
    sbv_patch_fileio();

    DIR *directorytoverify;
    directorytoverify = opendir("host:.");
    if (directorytoverify == NULL) {
        ret = SifExecModuleBuffer(&iomanX_irx, size_iomanX_irx, 0, NULL, &STAT);
        DPRINTF("[IOMANX.IRX]: ret=%d, stat=%d\n", ret, STAT);
        ret = SifExecModuleBuffer(&fileXio_irx, size_fileXio_irx, 0, NULL, &STAT);
        DPRINTF("[FILEXIO.IRX]: ret=%d, stat=%d\n", ret, STAT);
    }
    ret = SifExecModuleBuffer(&sio2man_irx, size_sio2man_irx, 0, NULL, &STAT);
    DPRINTF("[SIO2MAN.IRX]: ret=%d, stat=%d\n", ret, STAT);
    if (directorytoverify == NULL) {
        fileXioInit();
        HaveFileXio = 1;
    } else
        HaveFileXio = 0;
    if (directorytoverify != NULL) {
        closedir(directorytoverify);
    }
    ret = SifExecModuleBuffer(&mcman_irx, size_mcman_irx, 0, NULL, &STAT);
    DPRINTF("[MCMAN.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&mcserv_irx, size_mcserv_irx, 0, NULL, &STAT);
    DPRINTF("[MCSERV.IRX]: ret=%d, stat=%d\n", ret, STAT);
    initMC();

    ret = SifExecModuleBuffer(&padman_irx, size_padman_irx, 0, NULL, &STAT);
    DPRINTF("[PADMAN.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&libsd_irx, size_libsd_irx, 0, NULL, &STAT);
    DPRINTF("[LIBSD.IRX]: ret=%d, stat=%d\n", ret, STAT);

    // load USB modules
    ret = SifExecModuleBuffer(&usbd_irx, size_usbd_irx, 0, NULL, &STAT);
    DPRINTF("[USBD.IRX]: ret=%d, stat=%d\n", ret, STAT);


    int ds3pads = 1;
    ret = SifExecModuleBuffer(&ds34usb_irx, size_ds34usb_irx, 4, (char *)&ds3pads, &STAT);
    DPRINTF("[DS34USB.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&ds34bt_irx, size_ds34bt_irx, 4, (char *)&ds3pads, &STAT);
    DPRINTF("[DS34BT.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ds34usb_init();
    ds34bt_init();

    ret = SifExecModuleBuffer(&bdm_irx, size_bdm_irx, 0, NULL, &STAT);
    DPRINTF("[BDM.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&bdmfs_vfat_irx, size_bdmfs_vfat_irx, 0, NULL, &STAT);
    DPRINTF("[BDMFS_VFAT.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&usbmass_bd_irx, size_usbmass_bd_irx, 0, NULL, &STAT);
    DPRINTF("[USBMASS_BD.IRX]: ret=%d, stat=%d\n", ret, STAT);

    ret = SifExecModuleBuffer(&cdfs_irx, size_cdfs_irx, 0, NULL, &STAT);
    DPRINTF("[CDFS.IRX]: ret=%d, stat=%d\n", ret, STAT);

    // ret = SifExecModuleBuffer(&audsrv_irx, size_audsrv_irx, 0, NULL, &STAT);
    // DPRINTF("[AUDSRV.IRX]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&poweroff_irx, size_poweroff_irx, 0, NULL, &STAT);
    DPRINTF("[POWEROFF.IRX]: ret=%d, stat=%d\n", ret, STAT);
#ifndef RESET_IOP
    ret = SifExecModuleBuffer(&secrman_irx, size_secrman_irx, 0, NULL, &STAT);
    DPRINTF("[SECRMAN_SPECIAL.IRX]: ret=%d, stat=%d\n", ret, STAT);
#endif
    ret = SifExecModuleBuffer(&secrsif_irx, size_secrsif_irx, 0, NULL, &STAT);
    DPRINTF("[SECRSIF.IRX]: ret=%d, stat=%d\n", ret, STAT);
    DPRINTF("\n\n\nFINISHED LOADING IRX FILES\n");
    // waitUntilDeviceIsReady by fjtrujy

    struct stat buffer;
    ret = -1;
    int retries = 50;

    while (ret != 0 && retries > 0) {
        ret = stat("mass:/", &buffer);
        /* Wait until the device is ready */
        nopdelay();

        retries--;
    }
    DPRINTF("FINISHED WAITING FOR USB DEVICE READY\n");

    DPRINTF("INITIALIZING POWEROFF\n");
    poweroffInit();
    DPRINTF("Hooking alternative poweroff\n");
    AllowPoweroff = 1;
    poweroffSetCallback(alternative_poweroff, NULL);

    if ((fd = open("rom0:ROMVER", O_RDONLY)) > 0) // Reading ROMVER
    {
        read(fd, ConsoleROMVER, 16);
        ConsoleROMVER[16] = '\0';
        close(fd);
    }
    // if no parameters are specified, use the default boot
    if (argc < 2) {
        // set boot path global variable based on the elf path
        setLuaBootPath(argc, argv, 0);
    } else // set path based on the specified script
    {
        if (!strchr(argv[1], ':')) // filename doesn't contain device
                                   // set boot path global variable based on the elf path
            setLuaBootPath(argc, argv, 0);
        else
            // set path global variable based on the given script path
            setLuaBootPath(argc, argv, 1);
    }

    // Lua init
    // init internals library

    // graphics (gsKit)
    initGraphics();
    DPRINTF("initGraphics() Finished\n");

    pad_init();
    DPRINTF("pad_init() Finished\n");

    // set base path luaplayer
    chdir(boot_path);

    DPRINTF("boot path : %s\n", boot_path);

    while (1) {
        DPRINTF("running bootstring\n");
        errMsg = runScript(bootString, true);

        if (errMsg != NULL) {
#ifndef SCR_PRINTF
            init_scr();
#endif
            scr_clear();
            DPRINTF("\n\nerrMsg is not null and it's contents are:\n%s\n\n", errMsg);
#ifndef SCR_PRINTF
            scr_printf("\n\nerrMsg is not null and it's contents are:\n%s\n\n", errMsg);
#endif
            scr_setXY(5, 2);
            scr_printf("Enceladus ERROR!\n");
            scr_printf(errMsg);
            scr_printf("\nPress [start] to restart\n");
            while (!isButtonPressed(PAD_START)) {
            }
        }
    }

    return 0;
}
