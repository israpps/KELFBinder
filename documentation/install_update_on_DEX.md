---
sort: 6
---

# installing updates for `DTL-H` models

DTL-H models have a few extra rules in regards of system updates compared to retail hardware.

Please keep the following rules in mind

- any `DTL-H` model older than `DTL-H5xxxx` will only support updates if it's 3rd digit is a `1` (eg: `DTL-H30000` does not support updates but `DTL-H30100` does)
- `DTL-H` models use the developer magicgate keystore for authenticating the card updates. this means that for the update to be valid. it must have been signed on a `DTL-H` or `DTL-T` model. (dont worry, you can still use SCPH memory cards, but the update must be encrypted by developer hardware)
- FreeMcBoot seems to have a bug that makes it impossible to use on `DTL-H` models
- if your `DTL-H` model has expansion bay you can run updates from HDD (assuming console has it enabled on EEPROM)
- if your `DTL-H` model is DECKARD (`DTL-H75xxx` or newer) it may look for updates on a path different than the region identified by the console label. this is because `DTL-H` DECKARD models have a [sort-of hidden menu to change their region on the fly](https://www.youtube.com/watch?v=5I4b1VqX1k0&pp=ygUVcHMyIERUTC1IIHNlY3JldCBtZW51) with an EEPROM modification
