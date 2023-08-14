---
sort: 10
---

# System Update documentation


## System Folders
> the directories where PS2 looks for updates and local settings


__Region__   |__System update__ | __Data folder__ [^2] | __DVD Player Update__ [^1]|
------------- | --------------- | --------------- | --------------------- |
__Japanese__  | `BIEXEC-SYSTEM` | `BIDATA-SYSTEM` |  `BIEXEC-DVDPLAYER`   |
__American__  | `BAEXEC-SYSTEM` | `BADATA-SYSTEM` |  `BAEXEC-DVDPLAYER`   |
__Asian__     | `BAEXEC-SYSTEM` | `BADATA-SYSTEM` |  `BAEXEC-DVDPLAYER`   |
__European__  | `BEEXEC-SYSTEM` | `BEDATA-SYSTEM` |  `BEEXEC-DVDPLAYER`   |
__Chinese__   | `BCEXEC-SYSTEM` | `BCDATA-SYSTEM` |  `BCEXEC-DVDPLAYER`   |

[^1]: __DVD-player__ update executable name is: `dvdplayer.elf`
[^2]: __Data Folder:__ seen on the console browser as "Your System Configuration" this folder hold the play history file (a file that holds a record of played games, used to generate the towers on the console start animation), also, `TITLE.DB` is held on this folder, a file used by the PS1 retrocompatibility systems


## System executables
> The filenames of the system updates depending on the console model


__Region__| __Model__  |__Chassis__| __ROM__|__ELF filename__|
--------- | ---------- | --------- | ------ | ------------- |
__Japan__      | `SCPH-10000` |    `A`    | `1.00 J` |   `osdsys.elf` [^3] |
__Japan__      | `SCPH-10000` |    `A`    | `1.01 J` |	`osd110.elf` [^3] |
__Japan__      | `SCPH-15000` |    `A`    | `1.01 J` |   `osd110.elf` [^3] |
__Japan__      | `SCPH-18000` |  `A+/AB`  | `1.20 J` |	`osd130.elf`  |
__America__    | `SCPH-30001` |   `B/B'`  | `1.10 A` |   `osd120.elf`  |
__America__    | `SCPH-30001` |   `C/C'`  | `1.20 A` |	`osd130.elf`	|
__Europe__     | `SCPH-30002`/`3`/`4`/`8` | `C/C'` | `1.20 E` | `osd130.elf` |
__All__        | Most models  | `D` and newer | `1.50` and newer | `osdXXX.elf`[^4] or `osdmain.elf` (in that order)
__Japan__      | PSX (`DESR`)| - |  `1.80` or `2.10` | `xosdmain.elf`

[^3]: __Protokernel system update:__ theese files are used only by Protokernel PS2, FreeMcBoot installer pastes kernel patches that also redirect the system update into the executable used by the `SCPH-18000` patching the kernel and loading FreeMcBoot at the same time. However: Only Browser 2.0 is capable of patching properly and fully this early kernel. The source code of those kernel patches can be found [here](https://github.com/ps2homebrew/OSD-Initialization-Libraries/tree/main/kpatch)

[^4]: `osdXXX.elf` is a specific ROM update. The XXX represents a 3 digit number calculated based on the ROM version of your console.
the number is calculated by rounding the ROM version to the nearest ten.  for example: if your console has ROMVER `0220` (`2.20`) the name of the specific update will be `osd230.elf`

## System Update Paths to cover all models
> Explanation of wich models use each of the 9(or 10) paths covered in an 'universal' system update setup


Path | Console
--------------------------- | ----------------------------------
`BIEXEC-SYSTEM/osdsys.elf`  | `SCPH-10000` (early ones)
`BIEXEC-SYSTEM/osd110.elf`  | Late  `SCPH-10000` & `SCPH-15000`
`BIEXEC-SYSTEM/osd120.elf`  | `SCPH-18000`
`BIEXEC-SYSTEM/osdmain.elf` | any `SCPH-xxx00` excluding the 3 previous models
`BAEXEC-SYSTEM/osd120.elf`  | Early North america release model `SCPH-30001`
`BAEXEC-SYSTEM/osd130.elf`  | Late North america release model  `SCPH-30001`
`BAEXEC-SYSTEM/osdmain.elf` | Any USA model excluding the previous two models
`BEEXEC-SYSTEM/osd130.elf`  | PAL Release models (Europe / Oceania / Russia / England) (`SCPH-3000#` `#`=`2`/`3`/`4`/`8`)
`BEEXEC-SYSTEM/osdmain.elf` | Any PAL model excluding the previous one
`BCEXEC-SYSTEM/osdmain.elf` | Any Chinese PS2 (`SCPH-xxx09`)
`BIEXEC-SYSTEM/xosdmain.elf`| Any PSX-DESR
