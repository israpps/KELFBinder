-- EXTRA INSTALL ASSETS
-- DO NOT REMOVE!
-- IF YOU WANT TO DISABLE INSTALLATION OF EXTRA FILES press L1 on main menu (R1 Enables them back)
System.log("declaring installation tables for PS2BBL\n")
-- Installation tables. write values for fixed files, dynamic population of this list can be done with `Update_InstTable()`

--- SOURCE FILE PATHS FOR INSTALLATION, __PATHS ARE RELATIVE TO KELFBINDER LOCATION__
MC_INST_TABLE = {
  source = {},
  target = {}
}

--- FOLDERS TO BE CREATED BEFORE INSTALLATION
EXTRA_INST_MKD = {}

---HDD_INST_TABLE = {}
---HDD_INST_MKD = {}
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

Update_InstTable("INSTALL/ASSETS/PS2BBL", "PS2BBL", MC_INST_TABLE.source, MC_INST_TABLE.target, EXTRA_INST_MKD)
Update_InstTable("INSTALL/ASSETS/APPS"  , "APPS"  , MC_INST_TABLE.source, MC_INST_TABLE.target, EXTRA_INST_MKD)
Update_InstTable("INSTALL/ASSETS/BOOT"  , "BOOT"  , MC_INST_TABLE.source, MC_INST_TABLE.target, EXTRA_INST_MKD)


System.log("file installation table:\n")
for x = 1, #MC_INST_TABLE.source do
  System.log(string.format("\t[%s] --> [%s]\n", MC_INST_TABLE.source[x], MC_INST_TABLE.target[x]))
end

System.log("folder creation table:\n")
for x = 1, #EXTRA_INST_MKD do
  System.log(string.format("\t[%s]\n", EXTRA_INST_MKD[x]))
end