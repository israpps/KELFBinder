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

#------------------------------------------------------------------#
#----------------------- Configuration flags ----------------------#
#------------------------------------------------------------------#
#-------------------------- Reset the IOP -------------------------#
RESET_IOP ?= 1
#---------------------- enable DEBUGGING MODE ---------------------#
DEBUG ?= 0
SIOR ?= 0 # load IRX that pipes all printf into EE_SIO
EE_SIO ?= 0
#----------------------- Set IP for PS2Client ---------------------#
PS2LINK_IP ?= 192.168.1.10
#------------------------------------------------------------------#
ifeq ($(DEBUG),0)
.SILENT:
endif
EE_BIN = KELFBinder.elf
EE_BIN_PKD = KELFBinder_pkd.elf

EE_LIBS = -L$(PS2SDK)/ports/lib -L$(PS2DEV)/gsKit/lib/ -Lmodules/ds34bt/ee/ -Lmodules/ds34usb/ee/ -lpatches -lfileXio -lpad -ldebug -llua -lmath3d -ljpeg -lfreetype -lgskit_toolkit -lgskit -ldmakit -lpng -lz -lmc -lelf-loader -lds34bt -lds34usb
EE_LIBS += -liopreboot -lpoweroff

EE_INCS += -Isrc/include -I$(PS2DEV)/gsKit/include -I$(PS2SDK)/ports/include -I$(PS2SDK)/ports/include/freetype2 -I$(PS2SDK)/ports/include/zlib

EE_INCS += -Imodules/ds34bt/ee -Imodules/ds34usb/ee -I.

EE_CFLAGS   += -Wno-sign-compare -fno-strict-aliasing -fno-exceptions -DLUA_USE_PS2
EE_CXXFLAGS += -Wno-sign-compare -fno-strict-aliasing -fno-exceptions -DLUA_USE_PS2

ifeq ($(RESET_IOP),1)
  EE_CXXFLAGS += -DRESET_IOP
endif

ifeq ($(DEBUG),1)
  EE_CXXFLAGS += -DDEBUG
  EE_CFLAGS += -DDEBUG
  EE_CFLAGS += -O0 -g
else
  EE_CFLAGS += -Os
  EE_LDFLAGS += -s
endif



BIN2S = $(PS2SDK)/bin/bin2s

#-------------------------- App Content ---------------------------#
EXT_LIBS = modules/ds34usb/ee/libds34usb.a modules/ds34bt/ee/libds34bt.a

APP_CORE = main.o sioprintf.o libcdvd_add.o modelname.o system.o pad.o graphics.o render.o \
		   calc_3d.o gsKit3d_sup.o atlas.o fntsys.o md5.o \
		   libsecr.o baexec-system_paths.o # sound.o 

LUA_LIBS =	luaplayer.o luacontrols.o \
			luatimer.o luaScreen.o luagraphics.o \
			luasystem.o luaRender.o luasecrman.o luaKELFBinder.o # luasound.o

IOP_MODULES = iomanx.o filexio.o \
			  sio2man.o mcman.o mcserv.o padman.o libsd.o \
			  usbd.o bdm.o bdmfs_fatfs.o \
			  usbmass_bd.o cdfs.o ds34bt.o ds34usb.o \
			  secrsif.o IOPRP.o secrman.o poweroff.o

EMBEDDED_RSC = boot.o \
    background.o background_error.o background_success.o checkbox_empty.o \
    checkbox_filled.o circle.o cross.o firefly.o firefly_error.o firefly_success.o \
    logo.o mc_empty.o mc_ps1.o mc_ps2.o square.o triangle.o


ifeq ($(EE_SIO),1)
  EE_CXXFLAGS += -DSIO_PRINTF
  EE_CFLAGS += -DSIO_PRINTF
  ifeq ($(SIOR), 1)
    EE_CXXFLAGS += -DSIOR
    EE_CFLAGS += -DSIOR
    EE_LIBS += libisra_sior.a
    IOP_MODULES += tty2sior.o
  endif
#  EE_OBJS += SIOCookie.o
endif


EE_OBJS = $(IOP_MODULES) $(EMBEDDED_RSC) $(APP_CORE) $(LUA_LIBS)

EE_OBJS_DIR = obj/
EE_SRC_DIR = src/
EE_ASM_DIR = asm/
EE_OBJS := $(EE_OBJS:%=$(EE_OBJS_DIR)%) # remap all EE_OBJ to obj subdir

#------------------------------------------------------------------#
all: $(EXT_LIBS) $(EE_BIN)
	@echo EE_SIO=$(EE_SIO)
	@echo "$$HEADER"

	echo "Building $(EE_BIN)..."
	$(EE_STRIP) $(EE_BIN)

	echo "Compressing $(EE_BIN_PKD)...\n"
ifeq ($(DEBUG),1)
	ps2-packer -v $(EE_BIN) $(EE_BIN_PKD)
else
	ps2-packer $(EE_BIN) $(EE_BIN_PKD) > /dev/null
endif
	
	mv $(EE_BIN) bin/
	mv $(EE_BIN_PKD) bin/
#--------------------- Embedded ressources ------------------------#

$(EE_ASM_DIR)boot.s: etc/boot.lua | $(EE_ASM_DIR)
	echo "Embedding boot script..."
	$(BIN2S) $< $@ bootString

# Images
$(EE_ASM_DIR)%.s: EMBED/%.png
	$(BIN2S) $< $@ $(shell basename $< .png)
#------------------------------------------------------------------#

$(EE_OBJS_DIR):
	@mkdir -p $@

$(EE_ASM_DIR):
	@mkdir -p $@

debug: $(EE_BIN)
	echo "Building $(EE_BIN) with debug symbols..."

clean:

	@echo "\nCleaning $(EE_BIN)..."
	rm -f bin/$(EE_BIN)

	@echo "\nCleaning $(EE_BIN_PKD)..."
	rm -f bin/$(EE_BIN_PKD)

	@echo "Cleaning obj dir"
	@rm -rf $(EE_OBJS_DIR)
	@echo "Cleaning asm dir"
	@rm -rf $(EE_ASM_DIR)
	
	$(MAKE) -C modules/ds34usb clean
	$(MAKE) -C modules/ds34bt clean
	
	
	echo "Cleaning embedded Resources..."
	rm -f $(EMBEDDED_RSC)

rebuild: clean all

run:
	cd bin; ps2client.exe -h $(PS2LINK_IP) execee host:$(EE_BIN)
       
reset:
	ps2client -h $(PS2LINK_IP) reset   

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.c | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@echo " CC  - $@"
endif
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_OBJS_DIR)%.o: $(EE_ASM_DIR)%.s | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@echo " ASM - $@"
endif
	$(EE_AS) $(EE_ASFLAGS) $< -o $@

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.cpp | $(EE_OBJS_DIR)
ifeq ($(DEBUG),0)
	@echo " CXX - $@"
endif
	$(EE_CXX) $(EE_CXXFLAGS) $(EE_INCS) -c $< -o $@

include embed.make
include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
