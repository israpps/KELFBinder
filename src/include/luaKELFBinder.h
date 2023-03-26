#ifndef LUA_KELFBINDER_H
#define LUA_KELFBINDER_H

#define UNKNOWN -1

enum CONSOLE_REGIONS
{
    JAPAN = 0,
    USA,
    ASIA, // ASIA USES THE SAME SYSTEM PATHS THAN USA!!!
    EUROPE, //EUROPE, OCEANIA, RUSSIA
    CHINA,

    CONSOLE_REGIONS_COUNT,

};

enum MACHINETYPE
{
    CEX,  // SCPH and DESR models
    DEX,  // DTL-H models
    COH,  // COH arcade namco machines
    TOOL, // DTL-T

    MACHINETYPE_COUNT,
};

const char REGION_FOLDER_CHARS[CONSOLE_REGIONS_COUNT] = {
    'I', /// JAPAN
    'A', /// USA
    'E', /// EUROPE
    'C', /// CHINA
};

#endif