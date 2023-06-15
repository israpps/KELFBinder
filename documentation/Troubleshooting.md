---
sort: 3
---

# Troubleshooting
To discover why the program is not functioning properly

For deeper testing. take a look at the [debug log feature](./option_files.md#txtlogopt)

## debug colors
under certain scenarios, the program will change the screen color and freeze.

here is the list of those colors and their meaning:

### Purple
- The exact color is: ![purple](https://img.shields.io/badge/%20-%20-800080)
- meaning: KELFBinder could not find the installation table manifest.

The expected location of this script is `INSTALL/EXTINST.lua`

### White
- The exact color is: ![white](https://img.shields.io/badge/%20%20%20%20%20%20-%20%20%20%20%20-ffffff)
- meaning: KELFBinder could not find the main script file

The expected location of this script is `INSTALL/KELFBinder.lua`

### Black (with red bar on screen center)
- meaning: the program could not load the special security manager driver needed to encrypt and install the update into the card


<a href="https://github.com/israpps/KELFBinder/issues" class="link-mktg arrow-target-mktg link-emphasis-mktg text-semibold f3-mktg">
    REPORT TO THE DEVELOPER

    <svg xmlns="http://www.w3.org/2000/svg" class="octicon arrow-symbol-mktg" width="16" height="16" viewBox="0 0 16 16" fill="none">
        <path fill="currentColor" d="M7.28033 3.21967C6.98744 2.92678 6.51256 2.92678 6.21967 3.21967C5.92678 3.51256 5.92678 3.98744 6.21967 4.28033L7.28033 3.21967ZM11 8L11.5303 8.53033C11.8232 8.23744 11.8232 7.76256 11.5303 7.46967L11 8ZM6.21967 11.7197C5.92678 12.0126 5.92678 12.4874 6.21967 12.7803C6.51256 13.0732 6.98744 13.0732 7.28033 12.7803L6.21967 11.7197ZM6.21967 4.28033L10.4697 8.53033L11.5303 7.46967L7.28033 3.21967L6.21967 4.28033ZM10.4697 7.46967L6.21967 11.7197L7.28033 12.7803L11.5303 8.53033L10.4697 7.46967Z"></path>
        <path stroke="currentColor" d="M1.75 8H11" stroke-width="1.5" stroke-linecap="round"></path>
    </svg>
</a>


### Black (with green bar on screen center)
- meaning: the program crashed when loading the extra files installation table.
- __NOTE:__ since extra installation table is an external file wich every user can customize. issue reports related to this will not be accepted if they can't be reproduced with the original copy of that script

### Yellow
- the exact color is: ![yellow](https://img.shields.io/badge/%20%20%20%20%20%20-%20%20%20%20%20-ffff00)
- meaning: KELFBinder could not open a resource file of importance

## Crashes

### Program freezes while installing
Could be a lot of things there, please [contact the developer](https://github.com/israpps/KELFBinder/issues) for deeper troubleshooting
