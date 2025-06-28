define HEADER


  _  _______ _     _____ ____  _           _
 | |/ / ____| |   |  ___| __ )(_)_ __   __| | ___ _ __
 | ' /|  _| | |   | |_  |  _ \| | '_ \ / _` |/ _ \ '__|
 | . \| |___| |___|  _| | |_) | | | | | (_| |  __/ |
 |_|\_\_____|_____|_|   |____/|_|_| |_|\__,_|\___|_|


                           		KELFBinder
                    			Based on Enceladus project

endef
export HEADER
REVISION = 0
REVISION = $(shell expr $(shell git rev-list --count HEAD))

#---------------------{ Configuration flags }---------------------#
#------------------------{ Reset the IOP }------------------------#
RESET_IOP ?= 1
#--------------------{ Serial port debugging }--------------------#
EE_SIO ?= 0
#-----------------------{ printf over UDP }-----------------------#
UDPTTY ?= 0
#---------------------{ printf to local file }--------------------#
LOG2FILE ?= 1
#--------------------{ enable DEBUGGING MODE }--------------------#
DEBUG ?= 0
#---------------------{ Set IP for PS2Client }--------------------#
PS2LINK_IP ?= 192.168.1.10
#-------{ add checks/behaviour intended for release build }-------#
RELEASE ?= 1
#-----------------------------------------------------------------#
ifeq ($(DEBUG), 0)
.SILENT:
endif

EE_BIN_BASENAME ?= KELFBinder
EE_BIN_DIR = bin/
EE_BIN = $(EE_BIN_DIR)$(EE_BIN_BASENAME).elf
EE_BIN_PKD = $(EE_BIN_DIR)$(EE_BIN_BASENAME)_pkd.elf
EE_LIBS = -L$(PS2SDK)/ports/lib -L$(PS2DEV)/gsKit/lib/ \
		-Lmodules/ds34bt/ee/ -Lmodules/ds34usb/ee/ \
		-lpatches -lfileXio -lpad -ldebug -llua -lmath3d \
		-ljpeg -lfreetype -lgskit_toolkit -lgskit -ldmakit \
		-lpng -lz -lmc -lelf-loader -lds34bt -lds34usb -lhdd \
        -liopreboot -lpoweroff -L.

EE_INCS += -Isrc/include -I$(PS2DEV)/gsKit/include -I$(PS2SDK)/ports/include -I$(PS2SDK)/ports/include/freetype2 -I$(PS2SDK)/ports/include/zlib
EE_INCS += -Imodules/ds34bt/ee -Imodules/ds34usb/ee

GLOBFLAGS += -Wno-sign-compare -fno-strict-aliasing -fno-exceptions -DLUA_USE_PS2 #flags passed to both C/C++ compiler

ifeq ($(RESET_IOP),1)
GLOBFLAGS += -DRESET_IOP
endif

ifneq ($(DEBUG),0)
GLOBFLAGS += -DDEBUG=$(DEBUG)
EE_CFLAGS += -O0 -g
else
  EE_CFLAGS += -Os
  EE_LDFLAGS += -s
endif
ifneq ($(RELEASE),0)
  GLOBFLAGS += -DRELEASE
endif
ifneq ($(LOG2FILE),0)
  GLOBFLAGS += -DDPRINTF_LOG_TO_FILE
endif
BIN2S = $(PS2SDK)/bin/bin2c

EE_CXXFLAGS += $(GLOBFLAGS)
EE_CFLAGS += $(GLOBFLAGS)
#-------------------------- App Content ---------------------------#
EXT_LIBS = modules/ds34usb/ee/libds34usb.a modules/ds34bt/ee/libds34bt.a

APP_CORE = main.o libcdvd_add.o modelname.o system.o pad.o graphics.o render.o \
		   calc_3d.o gsKit3d_sup.o atlas.o fntsys.o md5.o \
		   libsecr.o baexec-system_paths.o strUtils.o # sound.o

LUA_LIBS =	luaplayer.o luacontrols.o \
			luatimer.o luaScreen.o luagraphics.o \
			luasystem.o luaRender.o luasecrman.o luaKELFBinder.o luaHDD.o # luasound.o

IOP_MODULES = iomanx.o filexio.o \
			  sio2man.o mcman.o mcserv.o padman.o libsd.o \
			  usbd.o bdm.o bdmfs_fatfs.o \
			  usbmass_bd.o cdfs.o ds34bt.o ds34usb.o \
			  secrsif.o IOPRP.o secrman.o poweroff.o \
			  ps2dev9_irx.o ps2atad_irx.o ps2hdd_irx.o ps2fs_irx.o

EMBEDDED_RSC = boot.o \
    background.o background_error.o background_success.o checkbox_empty.o \
    checkbox_filled.o circle.o cross.o firefly.o firefly_error.o firefly_success.o \
    logo.o mc_empty.o mc_ps1.o mc_ps2.o square.o triangle.o

#---------------- Conditions wich affectApp Content ---------------#
ifeq ($(UDPTTY), 1)
  EE_BIN_BASENAME = KELFBinder_udptty
  GLOBFLAGS += -DUDPTTY
  EE_CFLAGS += -DUDPTTY
  IOP_MODULES += udptty_irx.o ps2ip_irx.o netman_irx.o smap_irx.o
  ifeq ($(EE_SIO), 0) # only enable common printf if EE_SIO is disabled. this allows separating EE and IOP printf
    GLOBFLAGS += -DCOMMON_PRINTF
    EE_CFLAGS += -DCOMMON_PRINTF
  endif
endif

ifeq ($(EE_SIO), 1)
  $(info --- EE_SIO enabled...)
  GLOBFLAGS += -DSIO_PRINTF
  EE_CFLAGS += -DSIO_PRINTF
  APP_CORE += sioprintf.o
  EE_LIBS += -lsiocookie
endif

EE_OBJS_DIR = obj/
EE_SRC_DIR = src/
EE_ASM_DIR = asm/
EE_OBJS = $(APP_CORE) $(LUA_LIBS) $(IOP_MODULES) $(EMBEDDED_RSC)
EE_OBJS := $(EE_OBJS:%=$(EE_OBJS_DIR)%) # remap all EE_OBJ to obj subdir

#------------------------------------------------------------------#
all: $(EXT_LIBS) $(EE_BIN)
	@echo EE_SIO=$(EE_SIO)
	@echo UDPTTY=$(UDPTTY)
	@echo RESET_IOP=$(RESET_IOP)

	echo "Building $(EE_BIN)..."
	$(EE_STRIP) $(EE_BIN)
ifneq ($(DEBUG), 0)
	echo "Compressing $(EE_BIN_PKD)...\n"
ifeq ($(DEBUG),1)
	ps2-packer -v $(EE_BIN) $(EE_BIN_PKD)
else
	ps2-packer $(EE_BIN) $(EE_BIN_PKD) > /dev/null
endif
endif
	@echo "$$HEADER"
	@echo  rev$(REVISION)
#--------------------- Embedded ressources ------------------------#

$(EE_ASM_DIR)boot.c: etc/boot.lua | $(EE_ASM_DIR)
	$(BIN2S) $< $@ bootString

# Images
$(EE_ASM_DIR)%.c: EMBED/%.png
	$(BIN2S) $< $@ $(shell basename $< .png)
#------------------------------------------------------------------#

$(EE_OBJS_DIR):
	@mkdir -p $@

$(EE_ASM_DIR):
	@mkdir -p $@

debug: $(EE_BIN)
	echo "Building $(EE_BIN) with debug symbols..."

clean:
	@echo "\nCleaning..."
	@echo "rm - $(EE_BIN)"
	rm -f $(EE_BIN)

	@echo "rm - $(EE_BIN_PKD)"
	rm -f $(EE_BIN_PKD)

	@echo "rm - obj dir"
	@rm -rf $(EE_OBJS_DIR)

	$(MAKE) -C modules/ds34usb clean
	$(MAKE) -C modules/ds34bt clean

cleansrc:
	@rm -f $(APP_CORE:%=$(EE_OBJS_DIR)%) $(LUA_LIBS:%=$(EE_OBJS_DIR)%)

cleanasm:
	@echo "rm - asm dir"
	@rm -rf $(EE_ASM_DIR)

rclean: clean cleanasm
rebuild: clean all

run:
	ps2client -h $(PS2LINK_IP) -t 1 execee host:$(EE_BIN)

reset:
	ps2client -h $(PS2LINK_IP) reset

update_deps:
	wget -q https://github.com/israpps/wLaunchELF_ISR/releases/download/latest/BOOT-EXFAT.ELF -O bin/INSTALL/CORE/BACKDOOR.ELF
	cp bin/INSTALL/CORE/BACKDOOR.ELF bin/INSTALL/ASSETS/BOOT/BOOT.ELF

intellisense:
	etc/update_lua_globals.sh

.PHONY: reset run rclean debug

changelog:
	@echo generating full changelog...
	@git --no-pager log --name-only --oneline --pretty=format:"%n---------- commit %h: %B%n- Author: %an%n- date: %cd %n-- Changed files:"> bin/FULL_CHANGELOG.TXT
	@sed -e "s/\[skip actions\]//g" -i bin/FULL_CHANGELOG.TXT

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.c | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@printf "\033[1m CC  - $@\033[0m\n"
endif
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_OBJS_DIR)%.o: $(EE_ASM_DIR)%.c | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@printf "\033[1m ASM - $@\033[0m\n"
endif
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.cpp | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@printf "\033[1m CXX - $@\033[0m\n"
endif
	$(EE_CXX) $(EE_CXXFLAGS) $(EE_INCS) -c $< -o $@

include embed.make
include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
