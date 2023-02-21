#-------------------- Embedded IOP Modules ------------------------#
IRXTAG = $(notdir $(addsuffix _irx, $(basename $<)))

$(EE_ASM_DIR)iomanx.s: $(PS2SDK)/iop/irx/iomanX.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)poweroff.s: $(PS2SDK)/iop/irx/poweroff.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)filexio.s: $(PS2SDK)/iop/irx/fileXio.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)sio2man.s: $(PS2SDK)/iop/irx/sio2man.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcman.s: $(PS2SDK)/iop/irx/mcman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)mcserv.s: $(PS2SDK)/iop/irx/mcserv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)padman.s: $(PS2SDK)/iop/irx/padman.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)
	
$(EE_ASM_DIR)libsd.s: $(PS2SDK)/iop/irx/libsd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)usbd.s: $(PS2SDK)/iop/irx/usbd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)audsrv.s: $(PS2SDK)/iop/irx/audsrv.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdm.s: $(PS2SDK)/iop/irx/bdm.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)bdmfs_fatfs.s: $(PS2SDK)/iop/irx/bdmfs_fatfs.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ bdmfs_fatfs_irx

$(EE_ASM_DIR)usbmass_bd.s: $(PS2SDK)/iop/irx/usbmass_bd.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)IOPRP.s: iop/IOPRP_LTS.IMG | $(EE_ASM_DIR)
	$(BIN2S) $< $@ IOPRP

$(EE_ASM_DIR)secrsif.s: iop/secrsif_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)secrman.s: iop/secrman_debug.irx | $(EE_ASM_DIR)
	$(BIN2S) $< $@ $(IRXTAG)

$(EE_ASM_DIR)cdfs.s: $(PS2SDK)/iop/irx/cdfs.irx | $(EE_ASM_DIR)
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
	
#------------------------------------------------------------------#
