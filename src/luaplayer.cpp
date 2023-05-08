#include <kernel.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

#include "include/luaplayer.h"
#include "include/dbgprintf.h"

static lua_State *L;

const char * runScript(const char* script, bool isStringBuffer )
{
    DPRINTF("Creating luaVM... \n");

  	L = luaL_newstate();
	
	  // Init Standard libraries
	  luaL_openlibs(L);

    DPRINTF("Loading libs... ");

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

		
	if (s == 0) s = lua_pcall(L, 0, LUA_MULTRET, 0);

	if (s) {
		sprintf((char*)errMsg, "%s\n", lua_tostring(L, -1));
    DPRINTF("%s\n", lua_tostring(L, -1));
		lua_pop(L, 1); // remove error message
	}
	lua_close(L);
	
	return errMsg;
}
