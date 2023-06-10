---
sort: 1
---

# Configuration

## Custom updates

To add your own updates, you will need to [Convert an ELF file into a Memory Card KELF](./creating_KELFs.md).

After that, just replace the appropiate file on the following path of KELFBinder package:

```
SYSTEM/KELF/
```

Here you will find the following files files:

- `SYSTEM.XLF`: System Update for Common PS2 (via Memory card)
- `HSYSTEM.XLF`: System Update for Common PS2 (via Internal HDD)
- `XSYSTEM.XLF`: System update for PSX DESR (via Memory card)
- `DVDPLAYER.XLF`: DVDPlayer update (via Memory card)
- `OSDSYS.KERNEL`: Kernel Patch for early SCPH-10000. __DON'T TOUCH THIS__
- `OSD110.KERNEL`: Kernel Patch for Late SCPH-10000 and SCPH-15000  __DON'T TOUCH THIS__

## Custom extra files

Under the `INSTALL` folder you will find a file called `EXINST.lua`

This is the file that calculates the installation tables
inside you will find the functions involved on the table creation

example:
```lua
Update_InstTable("INSTALL/ASSETS/PS2BBL", "PS2BBL", MC_INST_TABLE.source, MC_INST_TABLE.target, MC_INST_TABLE.dirs)
```
this function defined that all files contained inside `INSTALL/ASSETS/PS2BBL` will be copied to `mc?:/PS2BBL`
all that you see after that should not be changed, unless you know what youre doing

For defining an extra folder for Memory card install:
```lua
Update_InstTable("SOURCE FROM USB" "DESTINATION FOLDER", MC_INST_TABLE.source, MC_INST_TABLE.target, MC_INST_TABLE.dirs)
```

For defining an extra folder for HDD install:
```lua
Update_InstTable("SOURCE FROM USB" "DESTINATION FULL HDD QUALIFIED PATH", HDD_INST_TABLE.source, HDD_INST_TABLE.target, HDD_INST_TABLE.dirs)
```
A full HDD Qualified path looks like this:
```bash
hdd0:PARTITION:pfs:/PATH_INSIDE_PARTITION
```

Under the dault script, these are the folders transferred on install.

### Memory card Default
- `INSTALL/ASSETS/PS2BBL` > `mc?:/PS2BBL`
- `INSTALL/ASSETS/APPS` > `mc?:/APPS`  
- `INSTALL/ASSETS/BOOT` > `mc?:/BOOT` 

### HDD Default
- `INSTALL/ASSETS/PS2BBL-HDD` > `hdd0:__sysconf:pfs:/PS2BBL`
- `INSTALL/ASSETS/APPS-HDD` > `hdd0:__common:pfs:/APPS`
- `INSTALL/ASSETS/BOOT-HDD` > `hdd0:__sysconf:pfs:/BOOT`
- `INSTALL/ASSETS/FSCK` > `hdd0:__system:pfs:/fsck/lang`
DONT TOUCH THE FSCK RELATED FILES. THEY CORRESPOND TO THE HDD DIAGNOSIS TOOL
