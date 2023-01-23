---
sort: 3
---

# How to convert a PS2 program as memory card KELF

requirements:
- a PC
- m4g1cg4t3 k3y5 (find them yourself)
- [KELFTool](https://www.psx-place.com/resources/kelftool-dnasload-fork.1319/)

once you have your ELF files simply run the following command:

```sh
kelftool encrypt dnasload $ELF_FILE $OUTPUT_KELF_FILE
```

honestly, you can use `fmcb` mode, but using the custom `dnasload` mode I added (thanks krHACKen for the data to do it) is capable of crafting a mc KELF that decrypts properly on both PS2 and PSX-DESR without issues
