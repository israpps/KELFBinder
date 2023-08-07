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
- The exact color is: ![purple](https://img.shields.io/badge/%20-%20-800080?style=for-the-badge)
- meaning: KELFBinder could not find the installation table manifest.

The expected location of this script is `INSTALL/EXTINST.lua`

### White
- The exact color is: ![white](https://img.shields.io/badge/%20%20%20-FFFFFF?style=for-the-badge)
- meaning: KELFBinder could not find the main script file

The expected location of this script is `INSTALL/KELFBinder.lua`

### Black (with red bar on screen center)
- meaning: the program could not load the special security manager driver needed to encrypt and install the update into the card


<a href="https://github.com/israpps/KELFBinder/issues" class="link-mktg arrow-target-mktg link-emphasis-mktg text-semibold f3-mktg">REPORT TO THE DEVELOPER</a>


### Black (with green bar on screen center)
- meaning: the program crashed when loading the extra files installation table.

<div class="flash mt-3 flash-warn">
  <!-- <%= octicon "alert" %> -->
  <svg class="octicon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16"><path fill-rule="evenodd" d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z"></path></svg>
  since extra installation table is an external file wich every user can customize. issue reports related to this will not be accepted if they can't be reproduced with the original copy of that script
</div>

### Yellow
- the exact color is: ![yellow](https://img.shields.io/badge/%20%20%20%20%20%20-%20%20%20%20%20-ffff00?style=for-the-badge)
- meaning: KELFBinder could not open a resource file of importance

## Crashes

### Program freezes while installing
Could be a lot of things there, please [contact the developer](https://github.com/israpps/KELFBinder/issues) for deeper troubleshooting
