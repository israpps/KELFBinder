#-------------------- Embedded IOP Modules ------------------------#
IRXTAG = $(notdir $(addsuffix _irx, $(basename $<)))
vpath %.irx iop/
vpath %.irx $(PS2SDK)/iop/irx/

$(EE_ASM_DIR)iomanx.s: iomanX.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)poweroff.s: poweroff.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)filexio.s: fileXio.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)sio2man.s: sio2man.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcman.s: mcman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcserv.s: mcserv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)padman.s: padman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)
	
$(EE_ASM_DIR)libsd.s: libsd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)usbd.s: usbd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)audsrv.s: audsrv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdm.s: bdm.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdmfs_fatfs.s: bdmfs_fatfs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ bdmfs_fatfs_irx

$(EE_ASM_DIR)usbmass_bd.s: usbmass_bd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)IOPRP.s: iop/IOPRP_LTS.IMG | $(EE_ASM_DIR)
	$(BIN2S) $< $@ IOPRP

$(EE_ASM_DIR)secrsif.s: secrsif_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)secrman.s: secrman_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ secrman_irx

$(EE_ASM_DIR)cdfs.s: cdfs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

modules/ds34bt/ee/libds34bt.a: modules/ds34bt/ee
	$(MAKE) -C $<

modules/ds34bt/iop/ds34bt.irx: modules/ds34bt/iop
	$(MAKE) -C $<

$(EE_ASM_DIR)ds34bt.s: modules/ds34bt/iop/ds34bt.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

modules/ds34usb/ee/libds34usb.a: modules/ds34usb/ee
	$(MAKE) -C $<

modules/ds34usb/iop/ds34usb.irx: modules/ds34usb/iop
	$(MAKE) -C $<

$(EE_ASM_DIR)ds34usb.s: modules/ds34usb/iop/ds34usb.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)


#HDD
$(EE_ASM_DIR)ps2dev9_irx.s: ps2dev9.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)ps2atad_irx.s: ps2atad.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)ps2hdd_irx.s: ps2hdd-osd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ ps2hdd_irx

$(EE_ASM_DIR)ps2fs_irx.s: ps2fs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)
#HDD

$(EE_ASM_DIR)ps2ip_irx.s: ps2ip-nm.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ ps2ip_irx

$(EE_ASM_DIR)udptty_irx.s: udptty.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)netman_irx.s: netman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)smap_irx.s: smap.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

#------------------------------------------------------------------#
