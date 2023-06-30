---
sort: 2
---

# Features

KELFBinder is capable of binding PS2 KELFs and installing them as system updates or DVDPlayer Updates

The program was made to be used as PS2BBL installer
However it was also designed to be easily reusable by other projects... such as XEB+, FreeMcBoot and any other program that you might want to install.

## Memory Card System Updates

### Installation modes

The following installation modes are available:

- [Normal Install](#Normal-Install)
- [Advanced Install](#Advanced-Install)
- [Expert Install](#Expert-Install)

#### Normal Install

Simply installs the System update into the path needed by the console

#### Advanced Install

Offers the classic FreeMcBoot installation modes

##### Cross Model

Installs the update on all the paths used by all the consoles of the same region

##### Cross Region

Installs the update on all paths used by every compatible PS2 of each region

##### PSX-DESR

Installs the update for [PSX-DESR systems](https://www.google.com/search?q=PSX-DESR&sxsrf=ALiCzsbB1c-OG3a_bzTilXq-RslFRCArXg:1671631335869&source=lnms&tbm=isch&sa=X&ved=2ahUKEwiM3-D_74r8AhVCqpUCHWURAxEQ_AUoAXoECAIQAw&biw=1366&bih=629&dpr=1)

#### Expert Install

Allows the user to cherry pick wich updates will be installed into the console.

Each option includes a brief description of wich consoles will be soported by including that file

### MagicGate Test

This feature will attempt to bind a KELF file to the card without writing anything to the card.

then it just reports back if the update was encrypted properly.

In adition, the binary data of the _kbit_ and _Kc_ fields of the file are printed on screen.

very useful to test if the card supports updates without even writing a single byte to the card.

## Memory Card DVDPlayer Updates

The DVDPlayer updates are region specific, just like System Updates.

However, unlike system updates. every console looks for the same path to update the DVDPlayer

the DVDPLayer update menu will ask you to select the target region for the update

## Internal HDD System Updates
KELFBinder is also capable of loading a full bootloader setup into the internal HDD. imitating the sony design.

This includes an HDD Diagnosis tool wich is executed by the MBR program to warn you if something is not OK on the HDD...

## Encryption process

Unlike FreeMcBoot Installer, KELFBinder will always bind the KELF using the traditional method (making the console MECHACON do the dirty job), instead of trying to replicate the binding from an already installed update. this ensures no mixtures happen in case you have both DEX and CEX KELFs on the same card.
