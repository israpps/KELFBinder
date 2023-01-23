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

- `SYSTEM.XLF`: System Update for Common PS2
- `XSYSTEM.XLF`: System update for PSX DESR
- `DVDPLAYER.XLF`: DVDPlayer update
- `OSDSYS.KERNEL`: Kernel Patch for early SCPH-10000. __DON'T TOUCH THIS__
- `OSD110.KERNEL`: Kernel Patch for Late SCPH-10000 and SCPH-15000  __DON'T TOUCH THIS__

## Custom extra files

Under the `INSTALL` folder you will find a file called `EXINST.lua`

This is the file that holds the extra files installation tables

There are 3 tables and 2 variables:

the two variables are:

```note
to disable the installation of extra files press L1 on main menu (R1 enables again).

To forcibly disable it change the value of the following variables to 0, dont comment the install tables or leave them empty, or installer will crash...
```

- `EXTRA_INST_COUNT`: the ammount of items inside the `EXTRA_INST_SRC` table
- `EXTRA_INST_FOLDE`: the ammount of items inside the `EXTRA_INST_MKD` table

the three tables are:
- `EXTRA_INST_SRC`: location of files to install, paths must be written as relative paths (relative to installer location)
- `EXTRA_INST_MKD`: names of the folders to create inside memory card before proceeding to installation of files
- `EXTRA_INST_DST`: destination paths for the files declared on `EXTRA_INST_SRC`, it must be in this form: `FOLDER/FILE` the memory card port is added to the string by the program. also, remember that subfolders are forbidden on $ony documentation! adding a subfolder will make it impossible to fully delete from OSDSYS/HDDOSD

### obvious things that are worth mentioning

- `EXTRA_INST_SRC` and `EXTRA_INST_DST` must have the same ammount of strings, and that ammount must be reflected on `EXTRA_INST_COUNT`
- make sure to put into `EXTRA_INST_MKD` the needed folders to avoid issues when copying the extra files to card
