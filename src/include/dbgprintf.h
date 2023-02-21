#ifndef DPRINTF_H
#define DPRINTF_H

#ifdef __cplusplus
extern "C" {
#endif
void sio_printf(const char *fmt, ...);
#ifdef __cplusplus
}
#endif

#ifdef SIO_PRINTF
    #include <SIOCookie.h>
    #define DPRINTF_INIT() ee_sio_start(38400, 0, 0, 0, 0)
    #define DPRINTF(x...) sio_printf(x)
    //#define DFLUSH() fflush(stdout)
#endif

#ifdef SCR_PRINTF
    #include <debug.h>
    #define DPRINTF(x...) scr_printf(x)
#endif

#ifdef COMMON_PRINTF
    #define DPRINTF(x...) printf(x)
#endif

#ifndef DPRINTF
    #include <SIOCookie.h>
    #define DPRINTF_INIT() ee_sio_start(38400, 0, 0, 0, 0)
    #define DPRINTF(x...) sio_printf(x)
    //#define DFLUSH() fflush(stdout)
#endif

#ifndef DPRINTF_INIT
    #define DPRINTF_INIT(x...);
#endif

#endif