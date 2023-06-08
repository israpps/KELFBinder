#ifndef DPRINTF_H
#define DPRINTF_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SIO_PRINTF
    void sio_printf(const char *fmt, ...);
    #include <SIOCookie.h>
    #include <sio.h>
#endif

#ifdef __cplusplus
}
#endif

#define ANSICOL_BLD_LBLUE //"\033[1;94;40m"
#define ANSICOL_DEF //"\033[m"

#ifdef SIO_PRINTF
    #define DPRINTF_INIT() ee_sio_start(38400, 0, 0, 0, 0, 1)
	#define DPRINTF(format, args...) sio_printf(ANSICOL_BLD_LBLUE format ANSICOL_DEF, ##args)
    #define DPUTS(buf) sio_putsn(buf)
    //#define DFLUSH() fflush(stdout)
#endif

#ifdef SCR_PRINTF
    #include <debug.h>
    #define DPRINTF(format, args...) scr_printf(format, ##args)
    #define DPUTS(buf) scr_puts(buf)
#endif

#ifdef COMMON_PRINTF
    #define DPRINTF(format, args...) printf(ANSICOL_BLD_LBLUE format ANSICOL_DEF, ##args)
    #define DPUTS(buf) puts(buf)
#endif

#ifndef DPRINTF
    #define DPRINTF(format, args...) printf(ANSICOL_BLD_LBLUE format ANSICOL_DEF, ##args)
    #define DPUTS(buf) puts(buf)
#endif

#ifdef DPRINTF_LOG_TO_FILE
    #define LOG2FILE_INIT(OUTPUT) OUTPUT = freopen("KELFBinder_log.txt", "a+", stdout), setvbuf(OUTPUT, NULL, _IONBF, 0), \
    printf("\n\n\n> NEW LOG SESSION:\n")
#else
    #define LOG2FILE_INIT(x)
#endif

#ifndef DPRINTF_INIT
    #define DPRINTF_INIT()
#endif

#define EPRINTF(format, args...) printf(ANSICOL_BLD_LBLUE format ANSICOL_DEF, ##args)

#ifndef DPRINTF_INIT
    #define DPRINTF_INIT(x...)
#endif

#endif