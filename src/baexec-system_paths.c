#include "baexec-system_paths.h"
const char *sysupdate_paths[SYSTEM_UPDATE_COUNT] = {
    /// JAP updates
    "BIEXEC-SYSTEM/osdsys.elf",  /// JAP, chassis A     ROM v1.00 (early SCPH-10000)
    "BIEXEC-SYSTEM/osd110.elf",  /// JAP, chassis A     ROM v1.01 (late SCPH-10000 & SCPH-15000)
    "BIEXEC-SYSTEM/osd130.elf",  /// JAP, chassis A+/AB ROM v1.20 (SCPH-18000)
    "BIEXEC-SYSTEM/osdmain.elf", /// any JAP model without PCMCIA, chassis D or newer

    /// USA updates
    "BAEXEC-SYSTEM/osd120.elf",  /// USA, ROM v1.10, 'B' Chassis (release model SCPH-30001)
    "BAEXEC-SYSTEM/osd130.elf",  /// USA, ROM v1.20, 'C' Chassis (release model SCPH-30001)
    "BAEXEC-SYSTEM/osdmain.elf", /// any USA model with chassis D or newer

    /// EUR updates
    "BEEXEC-SYSTEM/osd130.elf",  /// EUR, ROM v1.20, 'C' Chassis (release model SCPH-3000[2-4])
    "BEEXEC-SYSTEM/osdmain.elf", /// any EUR model with chassis D or newer

    /// standard CHINA updates
    "BCEXEC-SYSTEM/osdmain.elf", /// no known chinese models use sub-standard paths, covering a whole region with one file is so cool isn't it?

};
