#include <kernel.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

#include "include/luaplayer.h"
#include "include/dbgprintf.h"

static lua_State *L;
#define DUAL_PRINTF(x...) scr_printf(x); printf(x)
int test_error(lua_State * L) {
    int n = lua_gettop(L);
    int i;

        scr_setfontcolor(0x0000ff);
        scr_setCursor(0);
        scr_clear();
    printf("ERROR.\n");

    if (n == 0) {
        DUAL_PRINTF("Stack is empty.\n");
    }

    for (i = 1; i <= n; i++) {
        printf("%i: ", i);
        switch(lua_type(L, i)) {
        case LUA_TNONE:
            DUAL_PRINTF("Invalid");
            break;
        case LUA_TNIL:
            DUAL_PRINTF("(Nil)");
            break;
        case LUA_TNUMBER:
            DUAL_PRINTF("(Number) %f", lua_tonumber(L, i));
            break;
        case LUA_TBOOLEAN:
            DUAL_PRINTF("(Bool)   %s", (lua_toboolean(L, i) ? "true" : "false"));
            break;
        case LUA_TSTRING:
            DUAL_PRINTF(" %s", lua_tostring(L, i));
            break;
        case LUA_TTABLE:
            DUAL_PRINTF("(Table)");
            break;
        case LUA_TFUNCTION:
            DUAL_PRINTF("(Function)");
            break;
        default:
            DUAL_PRINTF("<UNKNOWN>");
        }

        DUAL_PRINTF("\n");
    }

    SleepThread();
}
const char * runScript(const char* script, bool isStringBuffer )
{
    DPRINTF("Creating luaVM... \n");

  	L = luaL_newstate();
	
	  // Init Standard libraries
	  luaL_openlibs(L);

    DPRINTF("Loading libs... ");
    lua_atpanic(L, test_error);
	  // init graphics
    luaGraphics_init(L);
    DPRINTF("luaGraphics_init done !\n");
    luaControls_init(L);
    DPRINTF("luaControls_init done !\n");
	  luaScreen_init(L);
    DPRINTF("luaScreen_init done !\n");
    luaTimer_init(L);
    DPRINTF("luaTimer_init done !\n");
    luaSystem_init(L);
    DPRINTF("luaSystem_init done !\n");
    //luaSound_init(L);
    //DPRINTF("luaSound_init done !\n");
    luaRender_init(L);
    DPRINTF("luaRender_init done !\n");
    luaSecrMan_init(L);
    DPRINTF("luaSecrMan_init done !\n");
	  luaKELFBinder_init(L);
    DPRINTF("luaKELFBinder_init done !\n");
    luaHDD_init(L);
    DPRINTF("luaHDD_init done !\n");
    DPRINTF("done !\n");
     
	if(!isStringBuffer){
        DPRINTF("Loading script : `%s'\n", script);
	}

	int s = 0;
	const char * errMsg =(const char*)malloc(sizeof(char)*512);

	if(!isStringBuffer) s = luaL_loadfile(L, script);
	else {
    s = luaL_loadbuffer(L, script, strlen(script), NULL);
  }

		
	if (s == LUA_OK) s = lua_pcall(L, 0, LUA_MULTRET, 0);

	if (s != LUA_OK) {
		snprintf((char*)errMsg, sizeof(char)*512, "%s\n", lua_tostring(L, -1));
    //DPRINTF("%s\n", lua_tostring(L, -1));
		lua_pop(L, 1); // remove error message
	}
	lua_close(L);
	
	return errMsg;
}
