
Drawbar(X_MID, Y_MID, 60, Color.new(0, 255, 0)) -- THIS MUST ALWAYS BE THE FIRST LINE OF THE INSTALLATION TABLE FILE. THIS ENSURES THAT SCREEN HALTS AT A GREEN BAR IF SOMETHING FAILS


-- IF YOU WANT TO DISABLE INSTALLATION OF EXTRA FILES press L1 on main menu (R1 Enables them back)
System.log("declaring installation tables for PS2BBL\n")

--- installation table for memory card.
MC_INST_TABLE = {
  source = {}, --- holds file locations relative to KELFBinder CWD.
  target = {}, --- contains installation paths ignoring device (eg: instead of `mc0:/A/BOOT.ELF` use `A/BOOT.ELF`)
  dirs = {} --- contains a list of directory names to be created before writing files to target
}

--- installation table for HardDrive
HDD_INST_TABLE = {
  source = { --- holds file locations relative to KELFBinder CWD.
    SYSUPDATE_HDD_MAIN,
    "INSTALL/KELF/FSCK.XLF"
  },
  target = { --- contains fully qualified HDD paths, so installation routine has all the needed info (partition name, and PFS path)
    "hdd0:__system:pfs:/osd/osdmain.elf",
    "hdd0:__system:pfs:/fsck/fsck.elf"
  },
  dirs = { --- contains a list of directory names to be created before writing files to target
    "hdd0:__system:pfs:/osd/",
    "hdd0:__system:pfs:/fsck/"
  },
}

---parse directory and append paths based on files found inside `SOURCEDIR` into `SOURCE_TABLE` and `DEST_TABLE`.
---if at least 1 file is found, the value of `DESTNTDIR` is added into `MKDIR_TABLE`
---@param SOURCEDIR string
---@param DESTNTDIR string
---@param SOURCE_TABLE table
---@param DEST_TABLE table
---@param MKDIR_TABLE table
function Update_InstTable(SOURCEDIR, DESTNTDIR, SOURCE_TABLE, DEST_TABLE, MKDIR_TABLE)
  local tmp = System.listDirectory(SOURCEDIR)
  local COUNT = 0 -- Ammount of files that will be installed
  for x = 1, #tmp do
    if not tmp[x].directory and tmp[x].size > 0 then
        table.insert(SOURCE_TABLE, SOURCEDIR.."/"..tmp[x].name)
        table.insert(DEST_TABLE,   DESTNTDIR.."/"..tmp[x].name)
        COUNT = COUNT+1
    end
  end
  if COUNT > 0 then --at least one file will be installed... append to mkdir struct
    table.insert(MKDIR_TABLE, DESTNTDIR)
    System.log(string.format("Installation table: %d files listed to be moved from '%s' to target:/%s'\n", COUNT, SOURCEDIR, DESTNTDIR))
  end
  return COUNT
end

Update_InstTable("INSTALL/ASSETS/PS2BBL", "PS2BBL", MC_INST_TABLE.source, MC_INST_TABLE.target, MC_INST_TABLE.dirs)
Update_InstTable("INSTALL/ASSETS/APPS"  , "APPS"  , MC_INST_TABLE.source, MC_INST_TABLE.target, MC_INST_TABLE.dirs)
Update_InstTable("INSTALL/ASSETS/BOOT"  , "BOOT"  , MC_INST_TABLE.source, MC_INST_TABLE.target, MC_INST_TABLE.dirs)

Update_InstTable("INSTALL/ASSETS/PS2BBL-HDD", "hdd0:__sysconf:pfs:/PS2BBL", HDD_INST_TABLE.source, HDD_INST_TABLE.target, HDD_INST_TABLE.dirs)
Update_InstTable("INSTALL/ASSETS/APPS-HDD"  , "hdd0:__common:pfs:/APPS"   , HDD_INST_TABLE.source, HDD_INST_TABLE.target, HDD_INST_TABLE.dirs)
Update_InstTable("INSTALL/ASSETS/BOOT-HDD"  , "hdd0:__sysconf:pfs:/BOOT"  , HDD_INST_TABLE.source, HDD_INST_TABLE.target, HDD_INST_TABLE.dirs)

Update_InstTable("INSTALL/ASSETS/FSCK"  , "hdd0:__system:pfs:/fsck/lang"  , HDD_INST_TABLE.source, HDD_INST_TABLE.target, HDD_INST_TABLE.dirs)

System.log("file installation table:\n")
for x = 1, #MC_INST_TABLE.source do
  System.log(string.format("\t[%s] --> [%s]\n", MC_INST_TABLE.source[x], MC_INST_TABLE.target[x]))
end

System.log("folder creation table:\n")
for x = 1, #MC_INST_TABLE.dirs do
  System.log(string.format("\t[%s]\n", MC_INST_TABLE.dirs[x]))
end