# KELFBinder: UMCS Installer
FORKED FROM KELFBinder by El_isra (https://israpps.github.io/)
Unified Memory Card System (UMCS) is a structural standard collaborated and envisioned by @TnA-Plastic which unifies exploits and updates into a single correlated setup. [Learn More Here!](https://www.psx-place.com/forums/ps2-application-system.279/)
@israpps [KELFBINDER](https://github.com/israpps/KELFBinder/releases/tag/latest) modified by @NathanNeurotic

Includes:

- POWEROFF.ELF - Only needed when not choosing FMCBD 1.966 and/or OSDMENU as main landing.
- RESTART.ELF - Only needed when not choosing FMCBD 1.966 and/or OSDMENU as main landing.
- BOOT.ELF ([PS2BBL-MMCE](https://israpps.github.io/PlayStation2-Basic-BootLoader/)) by @israpps
- OSDMENU.ELF ([PS2BBL-OSDMENU](https://github.com/pcm720/PlayStation2-Basic-BootLoader) to [OSDMENU](https://github.com/pcm720/osdmenu-launcher)) by @pcm720
- BOOT2.ELF ([wLaunchELF_isr-EXFAT-MMCE](https://israpps.github.io/projects/wlaunchelf-isr)) by @israpps
- launcher.elf ([OSDMENU](https://github.com/pcm720/osdmenu-launcher) Launcher) by @pcm720
- patcher.elf ([OSDMENU](https://github.com/pcm720/osdmenu-launcher) Loader) by @pcm720
- [neutrino](https://github.com/rickgaiser/neutrino) by @rickgaiser
- [nhddl](https://github.com/pcm720/nhddl/releases/tag/nightly) by @pcm720
- Icon additions and modifications by @koraxial @NathanNeurotic
- [POPSTARTER](https://www.psx-place.com/resources/popstarter.683/) exFAT USB Drivers ([BDM Assault](https://github.com/israpps/BDMAssault)) by @israpps
- [POPSTARTER](https://www.psx-place.com/resources/popstarter.683/) SMB Modules (SMB POPSTARTER) from [POPSTARTER Wiki](https://bitbucket.org/ShaolinAssassin/popstarter-documentation-stuff/wiki/quickstart-smb) by @ShaolinAssassin
- [DKWDRV](https://github.com/DKWDRV/DKWDRV)
- [ESR Launcher](https://www.psx-place.com/resources/esr-launcher.1526/) (Manual Launch) by @HowlingWolfHWC
- [FMCB 1.953 Decrypted](https://israpps.github.io/FreeMcBoot-Installer/)
- [FMCB 1.966 Decrypted](https://israpps.github.io/FreeMcBoot-Installer/)
- [FMCB Configurator](https://israpps.github.io/FreeMcBoot-Installer/)
- [SAS](https://ps2wiki.github.io/sas-apps-archive/) Compliant Installation
- Icon additions and modifications by @koraxial @NathanNeurotic


Core Critical Folders To Maintain UMCS:
* BOOT/
* B?EXEC-SYSTEM/
* SYS-CONF/

## PLEASE READ:
- This installer includes the full spectrum of compatibility options, and they are activated based on what you do or don't delete by default. At the same time, you can edit this order or even change the applications available for launch by modifying mc?:/SYS-CONF/PS2BBL.INI , mc?:/BOOT/CONFIG.INI , mc?:/SYS-CONF/PSXBBL.INI

PS2BBL will seek an application to launch on boot in this order:
1. FMCBD-1.966
     If you find that 1.966 works, you are safe to delete FMCBD 1.953, FMCBD 1.8C, RESTART, and POWEROFF.
2. FMCBD-1.953
     If you find that 1.966 was not compatible with your console due to a modchip or similar, delete it to revert to 1.953 instead.
3. OSDMENU
     If you find both conventional FMCBD versions are unsuccessful for your PS2, delete them to automatically switch to OSDMENU.

If all 3 are not compatible with your modchip, hold start on boot to access wLaunchELF_EXFAT-MMCE (BOOT2.ELF)
     From here, you can edit this order or even change the applications available for launch by modifying mc?:/SYS-CONF/PS2BBL.INI , mc?:/BOOT/CONFIG.INI , mc?:/SYS-CONF/PSXBBL.INI with wLaunchELF's text editor. An alternative landing could be mc?:/NEUTRINO/nhddl.elf or something of your own personal choice. You still have access to wLaunchELF via Start, so you can add applications of your own choosing.

-. All of these options can be launched and accessed if not deleted - but if you want to save space, it is recommended to delete the unnecessary applications via the PS2 Browser. (Memory Card Screen with Icons and Labels)
-. If you prefer a loader, regardless of reason, you can adjust the boot order in mc?:/SYS-CONF/PS2BBL.INI
-. PSXBBL.INI is set to launch wLaunchELF since PSX-DESR does not have an OSDSYS for the other options to apply.
-. OSDMENU.CNF is a backup of unmerged OSDMENU Configurations. Not currently a used file, but perhaps an update will provide this.

If you are using a late slim model that is not compatible with System Update Exploits - you can still experience UMCS  by adding or substituting with [FreeMcTuna Installer](https://github.com/NathanNeurotic/FreeMcTuna) to your installation(s).
---------------------------------------------------------------------
DVDPlayer and System Updates Manager for SCE PlayStation2

![GitHub all releases](https://img.shields.io/github/downloads/israpps/KELFBinder/total)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/8e886d46292e4d558c1c35a3387bffd5)](https://app.codacy.com/gh/israpps/KELFBinder/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

[![](https://img.shields.io/badge/Read%20the-Documentation-0020ff?style=for-the-badge&logo=pencil&labelColor=yellow)](https://israpps.github.io/KELFBinder/)


<details>
  <summary>Preview Images</summary>
  

![IMG1](./img/img1.png)
![IMG2](./img/img2.png)
![IMG3](./img/img3.png)
![IMG4](./img/img4.png)
![IMG5](./img/img5.png)
![IMG6](./img/img6.png)
![IMG7](./img/img7.png)
![IMG8](./img/img8.png)

</details>

