
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
#include <hdd-ioctl.h>
#include <sys/stat.h>

#include <dirent.h>

#include <sbv_patches.h>
#include <smem.h>

#include "include/graphics.h"
// #include "include/sound.h"
#include "include/luaplayer.h"
#include "include/pad.h"
#include "include/strUtils.h"

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
IMPORT_BIN2C(bdmfs_fatfs_irx);
IMPORT_BIN2C(usbmass_bd_irx);
// IMPORT_BIN2C(audsrv_irx);
IMPORT_BIN2C(ds34usb_irx);
IMPORT_BIN2C(ds34bt_irx);
IMPORT_BIN2C(secrsif_debug_irx);
IMPORT_BIN2C(secrman_irx);
IMPORT_BIN2C(IOPRP);
IMPORT_BIN2C(poweroff_irx);

IMPORT_BIN2C(poweroff_irx);
IMPORT_BIN2C(ps2dev9_irx);
IMPORT_BIN2C(ps2atad_irx);
IMPORT_BIN2C(ps2hdd_irx);
IMPORT_BIN2C(ps2fs_irx);

#ifdef UDPTTY
IMPORT_BIN2C(ps2ip_irx);
IMPORT_BIN2C(udptty_irx);
IMPORT_BIN2C(netman_irx);
IMPORT_BIN2C(smap_irx);
#endif

FILE* LOGFILE = NULL;
enum DEVID{NONE, MC0, MC1, MASS, HOST, MX4, ILK, HDD, XFROM, CDVD};
unsigned int BOOT_PATH_ID = DEVID::NONE;
char boot_path[255];
char ConsoleROMVER[17];
bool HDD_USABLE = false;
bool dev9_loaded = false;
int file_exist(const char* path);
int LoadHDDIRX(void);
#ifdef UDPTTY
void loadUDPTTY();
#endif
int loadDEV9();
extern int mnt(const char* path, int index, int openmod);

void setLuaBootPath(int argc, char **argv, int idx)
{
    char MountPoint[32+6+1]; // max partition name + 'hdd0:/' = '\0' 
    char newCWD[255];
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

    
    if (!strncmp(boot_path, "mass", 4))
        BOOT_PATH_ID = DEVID::MASS;
    if ((!strncmp(boot_path, "mass:/", 6)) && (strlen(boot_path) > 6)) {
        strcpy((char *)&boot_path[5], (const char *)&boot_path[6]);
    }
    else if (!strncmp(boot_path, "mc0", 3) || !strncmp(boot_path, "mc1", 3)) {
        BOOT_PATH_ID = (boot_path[2] == '0') ? DEVID::MC0 : DEVID::MC1;
    }
    else if (!strncmp(boot_path, "host", 4)) {
        BOOT_PATH_ID = DEVID::HOST;
    }
    else if ((!strncmp(boot_path, "hdd0:", 5)) && (strstr(boot_path, ":pfs:") != NULL)) // hdd path found
    {
        if (getMountInfo(boot_path, NULL, MountPoint, newCWD)) // see if we can parse it
        {
            strcpy(boot_path, newCWD); // replace boot path with mounted pfs path
            /*if (mnt(MountPoint, 0, FIO_MT_RDWR)==0) //mount the partition
            {
                BOOT_PATH_ID = DEVID::HDD;
#ifdef RESERVE_PFS0
                bootpath_is_on_HDD = 1;
#endif
            }
        */
        }
    }

    EPRINTF("%s: boot_path=%s\n", __func__, boot_path);
}


void initMC(void)
{
    int ret;
    // mc variables
    int mc_Type, mc_Free, mc_Format;


    EPRINTF("initMC: Initializing Memory Card\n");

    ret = mcInit(MC_TYPE_XMC);

    if (ret < 0) {
        EPRINTF("initMC: failed to initialize memcard server.\n");
    } else {
        EPRINTF("initMC: memcard server started successfully.\n");
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
        DPRINTF("Poweroff is allowed!\n");
        if (LOGFILE != NULL) fclose(LOGFILE);
        // If dev9.irx was loaded successfully, shut down DEV9.
        // As required by some (typically 2.5") HDDs, issue the SCSI STOP UNIT command to avoid causing an emergency park.
        if (HaveFileXio)
        {
            
            if (dev9_loaded) {
                DPRINTF("pfs: PDIOC_CLOSEALL\n");
                fileXioDevctl("pfs:", PDIOC_CLOSEALL, NULL, 0, NULL, 0);
                DPRINTF("dev9x: DDIOC_OFF\n");
                while (fileXioDevctl("dev9x:", DDIOC_OFF, NULL, 0, NULL, 0) < 0) {};
            }
            DPRINTF("mass: DEVCTL_STOP_ALL\n");
            fileXioDevctl("mass:", USBMASS_DEVCTL_STOP_ALL, NULL, 0, NULL, 0);
        }

        /* Power-off the PlayStation 2 console. */
        DPRINTF("shutting down...\n");
        poweroffShutdown();
    } else {DPRINTF("Poweroff is  NOT allowed right now!\n"); return;}
    
}

#include "SIOCookie.h"
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sio.h>

int main(int argc, char *argv[])
{
    int fd;
    const char *errMsg;
    int ret = -1, STAT;
    DPRINTF_INIT();
#ifdef EPRINTF
    for (fd = 0; fd < argc; fd++)
        EPRINTF("\targv[%d] = '%s'\n", fd, argv[fd]);
#endif
    EPRINTF("KELFBINDER: Compiled on %s %s\n", __DATE__, __TIME__);
#ifdef RESET_IOP
    SifInitRpc(0);
    // ONLY ONE OF THE LINES BETWEEN THESE TWO COMMENTS CAN BE ENABLED AT THE SAME TIME
    // while (!SifIopReset("", 0)){}; // common IOP Reset
    SifIopRebootBuffer(IOPRP, size_IOPRP); EPRINTF("Flashing SECRMAN image\n");// use IOPRP image with SECRMAN_special inside. ensures only the minimal and necessary IRXes are loaded.
    // ONLY ONE OF THE LINES BETWEEN THESE TWO COMMENTS CAN BE ENABLED AT THE SAME TIME
    while (!SifIopSync()) {};
    SifInitRpc(0);
#endif

    // install sbv patch fix
    EPRINTF("Installing SBV Patches...\n");
    sbv_patch_enable_lmb();
    sbv_patch_disable_prefix_check();
    sbv_patch_fileio();

    init_scr();
#ifdef UDPTTY
    if (loadDEV9())
        loadUDPTTY();
#endif

#ifdef NO_FILEXIO_ON_HOST
    DIR *directorytoverify;
    directorytoverify = opendir("host:.");
    if (directorytoverify == NULL) {
#endif
        ret = SifExecModuleBuffer(&iomanX_irx, size_iomanX_irx, 0, NULL, &STAT);
        EPRINTF("[IOMANX]: ret=%d, stat=%d\n", ret, STAT);
        ret = SifExecModuleBuffer(&fileXio_irx, size_fileXio_irx, 0, NULL, &STAT);
        EPRINTF("[FILEXIO]: ret=%d, stat=%d\n", ret, STAT);
#ifdef NO_FILEXIO_ON_HOST
    }
    if (directorytoverify == NULL) {
        fileXioInit();
        HaveFileXio = 1;
    } else
        HaveFileXio = 0;
    if (directorytoverify != NULL) {
        closedir(directorytoverify);
    }
#else
        fileXioInit();
        HaveFileXio = 1;
#endif

    ret = SifExecModuleBuffer(&sio2man_irx, size_sio2man_irx, 0, NULL, &STAT);
    EPRINTF("[SIO2MAN]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&mcman_irx, size_mcman_irx, 0, NULL, &STAT);
    EPRINTF("[MCMAN]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&mcserv_irx, size_mcserv_irx, 0, NULL, &STAT);
    EPRINTF("[MCSERV]: ret=%d, stat=%d\n", ret, STAT);
    initMC();

    ret = SifExecModuleBuffer(&padman_irx, size_padman_irx, 0, NULL, &STAT);
    EPRINTF("[PADMAN]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&libsd_irx, size_libsd_irx, 0, NULL, &STAT);
    EPRINTF("[LIBSD]: ret=%d, stat=%d\n", ret, STAT);

    // load USB modules
    ret = SifExecModuleBuffer(&usbd_irx, size_usbd_irx, 0, NULL, &STAT);
    EPRINTF("[USBD]: ret=%d, stat=%d\n", ret, STAT);


    int ds3pads = 1;
    ret = SifExecModuleBuffer(&ds34usb_irx, size_ds34usb_irx, 4, (char *)&ds3pads, &STAT);
    EPRINTF("[DS34USB]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&ds34bt_irx, size_ds34bt_irx, 4, (char *)&ds3pads, &STAT);
    EPRINTF("[DS34BT]: ret=%d, stat=%d\n", ret, STAT);
    ds34usb_init();
    ds34bt_init();

    ret = SifExecModuleBuffer(&bdm_irx, size_bdm_irx, 0, NULL, &STAT);
    EPRINTF("[BDM]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&bdmfs_fatfs_irx, size_bdmfs_fatfs_irx, 0, NULL, &STAT);
    EPRINTF("[BDMFS_FATFS]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&usbmass_bd_irx, size_usbmass_bd_irx, 0, NULL, &STAT);
    EPRINTF("[USBMASS_BD]: ret=%d, stat=%d\n", ret, STAT);

    ret = SifExecModuleBuffer(&cdfs_irx, size_cdfs_irx, 0, NULL, &STAT);
    EPRINTF("[CDFS]: ret=%d, stat=%d\n", ret, STAT);
    sceCdInit(SCECdINoD);

    // ret = SifExecModuleBuffer(&audsrv_irx, size_audsrv_irx, 0, NULL, &STAT);
    // EPRINTF("[AUDSRV]: ret=%d, stat=%d\n", ret, STAT);
    ret = SifExecModuleBuffer(&poweroff_irx, size_poweroff_irx, 0, NULL, &STAT);
    EPRINTF("[POWEROFF]: ret=%d, stat=%d\n", ret, STAT);

    ret = SifExecModuleBuffer(&secrsif_debug_irx, size_secrsif_debug_irx, 0, NULL, &STAT);
    EPRINTF("[SECRSIF]: ret=%d, stat=%d\n", ret, STAT);

    setLuaBootPath(argc, argv, 0);

    // waitUntilDeviceIsReady by fjtrujy
    struct stat buffer;
    ret = -1;
    int retries = 50;
    if (BOOT_PATH_ID == DEVID::MASS)
    {
        EPRINTF("WAITING FOR USB DEVICE READY\n");
        while (ret != 0 && retries > 0) {
            ret = stat("mass:/", &buffer);
            /* Wait until the device is ready */
            nopdelay();

            retries--;
        }
        EPRINTF("FINISHED\n");
    }

    if (file_exist("INSTALL/CORE/txtlog.opt"))
    {
        EPRINTF("> WRITING PRINTF TO LOG...\n");
        LOG2FILE_INIT(LOGFILE);
        printf("KELFBINDER: Compiled on %s %s\n", __DATE__, __TIME__);
    }

    if (!file_exist("INSTALL/CORE/nohdd.opt"))
    {
        if (HaveFileXio)
            LoadHDDIRX();
    } else {DPRINTF("Skipping HDD functionality\n");}

    EPRINTF("FINISHED LOADING IRX FILES\n");
    EPRINTF("INITIALIZING POWEROFF\n");
    poweroffInit();
    EPRINTF("Hooking alternative poweroff\n");
    AllowPoweroff = 1;
    poweroffSetCallback(alternative_poweroff, NULL);

    if ((fd = open("rom0:ROMVER", O_RDONLY)) > 0) // Reading ROMVER
    {
        read(fd, ConsoleROMVER, 16);
        ConsoleROMVER[16] = '\0';
        close(fd);
    }
    // Lua init
    // init internals library

    // graphics (gsKit)
    initGraphics();
    EPRINTF("initGraphics() Finished\n");

    pad_init();
    EPRINTF("pad_init() Finished\n");

    // set base path luaplayer
    chdir(boot_path);

    EPRINTF("boot path : %s\n", boot_path);

    while (1) {
        EPRINTF("running bootstring\n");
        errMsg = runScript(bootString, true);

        if (errMsg != NULL) {
            init_scr();
            sleep(1);
            scr_clear();
            scr_setXY(5, 2);
            scr_printf("\t\tERROR!\n");
            scr_setfontcolor(0x0000ff);
            scr_printf(errMsg);
            puts(errMsg);
            scr_setfontcolor(0xffffff);
            scr_printf("\n\treport on: https://github.com/israpps/KELFBinder/issues\n\t or: https://www.psx-place.com/threads/kelfbinder-2.39279/");
            while (!isButtonPressed(PAD_START)) {
            }
        }
    }

    return 0;
}


static int CheckHDD(void) {
    int ret = fileXioDevctl("hdd0:", HDIOC_STATUS, NULL, 0, NULL, 0);
    /* 0 = HDD connected and formatted, 1 = not formatted, 2 = HDD not usable, 3 = HDD not connected. */
    DPRINTF("%s: HDD status is %d\n", __func__, ret);
    if ((ret >= 3) || (ret < 0))
        return -1;
    return ret;
}

#ifdef UDPTTY
void loadUDPTTY()
{
    int ID, RET;
    ID = SifExecModuleBuffer(&netman_irx, size_netman_irx, 0, NULL, &RET);
    EPRINTF(" [NETMAN]: ret=%d, ID=%d\n", RET, ID);
    ID = SifExecModuleBuffer(&smap_irx, size_smap_irx, 0, NULL, &RET);
    EPRINTF(" [SMAP]: ret=%d, ID=%d\n", RET, ID);
    ID = SifExecModuleBuffer(&ps2ip_irx, size_ps2ip_irx, 0, NULL, &RET);
    EPRINTF(" [PS2IP]: ret=%d, ID=%d\n", RET, ID);
    ID = SifExecModuleBuffer(&udptty_irx, size_udptty_irx, 0, NULL, &RET);
    EPRINTF(" [UDPTTY]: ret=%d, ID=%d\n", RET, ID);
}
#endif

int loadDEV9()
{
    if (!dev9_loaded)
    {
        int ID, RET;
        ID = SifExecModuleBuffer(&ps2dev9_irx, size_ps2dev9_irx, 0, NULL, &RET);
        EPRINTF("[DEV9]: ret=%d, ID=%d\n", RET, ID);
        if (ID < 0 || RET == 1) // ID smaller than 0: issue reported from modload | RET == 1: driver returned no resident end
            return 0;
        dev9_loaded = true;
    }
    return 1;
}

int LoadHDDIRX(void)
{
    int ID, RET, HDDSTAT;
    static const char hddarg[] = "-o" "\0" "4" "\0" "-n" "\0" "20";
    static const char pfsarg[] = "-m" "\0" "4" "\0" "-o" "\0" "10" "\0" "-n" "\0" "40";

    /* PS2DEV9.IRX */
    if (!loadDEV9())
        return -1;

    /* PS2ATAD.IRX */
    ID = SifExecModuleBuffer(&ps2atad_irx, size_ps2atad_irx, 0, NULL, &RET);
    EPRINTF(" [ATAD]: ret=%d, ID=%d\n", RET, ID);
    if (ID < 0 || RET == 1)
        return -2;

    /* PS2HDD.IRX */
    ID = SifExecModuleBuffer(&ps2hdd_irx, size_ps2hdd_irx, sizeof(hddarg), hddarg, &RET);
    EPRINTF(" [PS2HDD]: ret=%d, ID=%d\n", RET, ID);
    if (ID < 0 || RET == 1)
        return -3;

    /* Check if HDD is formatted and ready to be used */
    HDDSTAT = CheckHDD();
    HDD_USABLE = (HDDSTAT == 0 || HDDSTAT == 1); // ONLY if HDD is usable. as we will offer HDD Formatting operation

    /* PS2FS.IRX */
    if (HDD_USABLE)
    {
        ID = SifExecModuleBuffer(&ps2fs_irx, size_ps2fs_irx, sizeof(pfsarg), pfsarg,  &RET);
        EPRINTF("  [PS2FS]: ret=%d, ID=%d\n", RET, ID);
        if (ID < 0 || RET == 1)
            return -5;
    }

    return 0;
}
