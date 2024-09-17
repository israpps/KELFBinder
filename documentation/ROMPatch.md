---
sort: 7
---

# RomPatch Update installation

the RomPatch Update install is feature intended to make use of the ROM patch updates sony made for later PS2.

starting with bios v1.50 (somewhere near `SCPH-3xxxx R`) sony normalized the system update paths. since all models began to look for `osdmain.elf` on their respective region folder

however, a new update path was provided. wich followed the same naming convention than the models prior to bios v1.50 had  
this special "ROM Patch update" is intended to execute an update ONLY for specific console versions and regions.

the math is pretty simple: it rounds up the BIOS version number to the next multiple of `10` and the resulting number is used on the update filename.

## Example

so lets say you have japanese 2.20 bios... it will look for:
```
mc?:/BIEXEC-SYSTEM/osd230.elf
```
before even trying to look for:
```
mc?:/BIEXEC-SYSTEM/osdmain.elf
```


## Notes:
### Chinese Models Issue
This feature is almost useless on chinese models because only one chinese PS2 exists (the `SCPH-50009`).  
This fact makes it useless to put anything else beyond `osdmain.elf` on the chinese folder
