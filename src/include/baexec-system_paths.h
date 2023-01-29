#ifndef SYSUPDATE_PATH
#define SYSUPDATE_PATH

// the following bit shifted macros are intended to be used for special installations, where used picked specific updates
#define BS(X) (1 << X)

#define JAP_100 BS(1)
#define JAP_101 BS(2)
#define JAP_120 BS(3)
#define JAP_STD BS(4)

#define USA_110 BS(5)
#define USA_120 BS(6)
#define USA_STD BS(7)

#define EUR_120 BS(8)
#define EUR_STD BS(9)

#define CHN_STD BS(10)


enum SYSUPDATE_COUNT
{
    JAP_ROM_100 = 0,
    JAP_ROM_101,
    JAP_ROM_120,
    JAP_STANDARD,

    USA_ROM_110,
    USA_ROM_120,
    USA_STANDARD,

    EUR_ROM_120,
    EUR_STANDARD,

    CHN_STANDARD,

    SYSTEM_UPDATE_COUNT

};
extern const char *sysupdate_paths[SYSTEM_UPDATE_COUNT];

// BSM2AI == Bit Shifted Macros to Array Index
#define BSM2AI(X)                   \
    (X == JAP_100) ? JAP_ROM_100 :  \
    (X == JAP_101) ? JAP_ROM_101 :  \
    (X == JAP_120) ? JAP_ROM_120 :  \
    (X == JAP_STD) ? JAP_STANDARD : \
    (X == USA_110) ? USA_ROM_110 :  \
    (X == USA_120) ? USA_ROM_120 :  \
    (X == USA_STD) ? USA_STANDARD : \
    (X == EUR_120) ? EUR_ROM_120 :  \
    (X == EUR_STD) ? EUR_STANDARD : \
    (X == CHN_STD) ? CHN_STANDARD : \
                     0
#endif