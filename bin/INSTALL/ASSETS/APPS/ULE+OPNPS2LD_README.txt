ULE.ELF is actually "PS2BBL Application" which launches wLaunchELF from mc?:/BOOT/BOOT.ELF or defaults to mc?:/APPS/OPNPS2LD.ELF
OPNPS2LD.ELF is "FMCB Decrypted Application" which which will load FMCB on any console, utilizing dependencies in mc?:/BOOT/ and mc?:/SYS-CONF/
CONFIG.INI is mc?/APPS/ULE.ELF's PS2BBL Configuration.
esr-r9c.elf is a dependency for ESR-GUI-XMAS users.
esr-r10f.elf is a dependency for ESR-GUI-XMAS users.
APPS.icn is an icon for this folder in the PS2 Browser.
del.icn is a delete icon for this folder in the PS2 Browser.
icon.sys is icons data for this folder in the PS2 Browser.

Why are applications incorrectly named? This is to support a unified landing between
all Tuna exploits and System Update exploits.
FunTuna, FunTuna Fork, and OpenTuna will rely on APPS.psu, BOOT.psu, and SYS-CONF.psu.
Additionally, FORTUNA users will also need FORTUNA-UMCS.psu installed over current FORTUNA installations to support UMCS. (FOTUNA-UMCS.psu, APPS.psu, BOOT.psu, and SYS-CONF.psu)