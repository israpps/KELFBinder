
#define IMPORT_BIN2C(_n)       \
    extern unsigned char _n[]; \
    extern unsigned int size_##_n

IMPORT_BIN2C(background);
IMPORT_BIN2C(background_error);
IMPORT_BIN2C(background_success);
IMPORT_BIN2C(checkbox_empty);
IMPORT_BIN2C(checkbox_filled);
IMPORT_BIN2C(circle);
IMPORT_BIN2C(cross);
IMPORT_BIN2C(firefly);
IMPORT_BIN2C(firefly_error);
IMPORT_BIN2C(firefly_success);
IMPORT_BIN2C(logo);
IMPORT_BIN2C(mc_empty);
IMPORT_BIN2C(mc_ps1);
IMPORT_BIN2C(mc_ps2);
IMPORT_BIN2C(square);
IMPORT_BIN2C(triangle);

enum IMAGES
{
    BACKGROUND = 0,
    BACKGROUND_ERROR,
    BACKGROUND_SUCCESS,
    CHECKBOX_EMPTY,
    CHECKBOX_FILLED,
    CIRCLE,
    CROSS,
    FIREFLY,
    FIREFLY_ERROR,
    FIREFLY_SUCCESS,
    LOGO,
    MC_EMPTY,
    MC_PS1,
    MC_PS2,
    SQUARE,
    TRIANGLE,

    AMMOUNT
};