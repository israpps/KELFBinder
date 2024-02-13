#-------------------- Embedded IOP Modules ------------------------#
IRXTAG = $(notdir $(addsuffix _irx, $(basename $<)))
vpath %.irx iop/
vpath %.irx irx_debug/
vpath %.irx $(PS2SDK)/iop/irx/

$(EE_ASM_DIR)iomanx.c: iomanX.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)poweroff.c: poweroff.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)filexio.c: fileXio.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)sio2man.c: sio2man.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcman.c: mcman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcserv.c: mcserv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)padman.c: padman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)
	
$(EE_ASM_DIR)libsd.c: libsd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)usbd.c: usbd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)audsrv.c: audsrv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdm.c: bdm.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdmfs_fatfs.c: bdmfs_fatfs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ bdmfs_fatfs_irx

$(EE_ASM_DIR)usbmass_bd.c: usbmass_bd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)IOPRP.c: iop/IOPRP_LTS.IMG | $(EE_ASM_DIR)
	$(BIN2S) $< $@ IOPRP

$(EE_ASM_DIR)secrsif.c: secrsif_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)secrman.c: secrman_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ secrman_irx

$(EE_ASM_DIR)cdfs.c: cdfs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

modules/ds34bt/ee/libds34bt.a: modules/ds34bt/ee
	$(MAKE) -C $<

modules/ds34bt/iop/ds34bt.irx: modules/ds34bt/iop
	$(MAKE) -C $<

$(EE_ASM_DIR)ds34bt.c: modules/ds34bt/iop/ds34bt.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

modules/ds34usb/ee/libds34usb.a: modules/ds34usb/ee
	$(MAKE) -C $<

modules/ds34usb/iop/ds34usb.irx: modules/ds34usb/iop
	$(MAKE) -C $<

$(EE_ASM_DIR)ds34usb.c: modules/ds34usb/iop/ds34usb.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)


#HDD
$(EE_ASM_DIR)ps2dev9_irx.c: ps2dev9.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)ps2atad_irx.c: ps2atad.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)ps2hdd_irx.c: ps2hdd-osd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ ps2hdd_irx

$(EE_ASM_DIR)ps2fs_irx.c: ps2fs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)
#HDD

$(EE_ASM_DIR)ps2ip_irx.c: ps2ip-nm.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ ps2ip_irx

$(EE_ASM_DIR)udptty_irx.c: udptty.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)netman_irx.c: netman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)smap_irx.c: smap.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

#------------------------------------------------------------------#
