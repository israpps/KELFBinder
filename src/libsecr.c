#include <stdio.h>
#include <string.h>
#include <kernel.h>
#include <sifrpc.h>

#include "include/libsecr.h"
#include "include/secrsif.h"
#include "include/dbgprintf.h"

static SifRpcClientData_t SifRpcClient01;
static SifRpcClientData_t SifRpcClient02;
static SifRpcClientData_t SifRpcClient03;
static SifRpcClientData_t SifRpcClient04;
static SifRpcClientData_t SifRpcClient05;
static SifRpcClientData_t SifRpcClient06;
static SifRpcClientData_t SifRpcClient07;

static unsigned char RpcBuffer[0x1000] ALIGNED(64);
unsigned char Gkbit[16];
unsigned char Gkcontent[16];

int SecrInit(void)
{
    memset(Gkbit, 0x00, 16);
    memset(Gkcontent, 0x00, 16);
    DPRINTF("STARTING SECRMAN RPC BINDING\n");
    SifInitRpc(0);
    int cnt = 0;
    nopdelay();
    while (SifBindRpc(&SifRpcClient01, 0x80000A01, 0) < 0 || SifRpcClient01.server == NULL) {
        DPRINTF("libsecr: SifRpcClient01 bind failed\n");
        if (cnt++ > 500) return 1;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient02, 0x80000A02, 0) < 0 || SifRpcClient02.server == NULL) {
        DPRINTF("libsecr: SifRpcClient02 bind failed\n");
        if (cnt++ > 500) return 2;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient03, 0x80000A03, 0) < 0 || SifRpcClient03.server == NULL) {
        DPRINTF("libsecr: SifRpcClient03 bind failed\n");
        if (cnt++ > 500) return 3;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient04, 0x80000A04, 0) < 0 || SifRpcClient04.server == NULL) {
        DPRINTF("libsecr: SifRpcClient04 bind failed\n");
        if (cnt++ > 500) return 4;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient05, 0x80000A05, 0) < 0 || SifRpcClient05.server == NULL) {
        DPRINTF("libsecr: SifRpcClient05 bind failed\n");
        if (cnt++ > 500) return 5;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient06, 0x80000A06, 0) < 0 || SifRpcClient06.server == NULL) {
        DPRINTF("libsecr: SifRpcClient06 bind failed\n");
        if (cnt++ > 500) return 6;
    }

    nopdelay();
    cnt = 0;
    while (SifBindRpc(&SifRpcClient07, 0x80000A07, 0) < 0 || SifRpcClient07.server == NULL) {
        DPRINTF("libsecr: SifRpcClient07 bind failed\n");
        if (cnt++ > 500) return 7;
    }

    return 0;
}

void GetLastKbitNKc(unsigned char Kbit[16], unsigned char kcontent[16])
{
    memcpy(Kbit, Gkbit, 16);
    memcpy(kcontent, Gkcontent, 16);
}

void SecrDeinit(void)
{
    DPRINTF("%s: start\n", __func__);
    memset(&SifRpcClient01, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient02, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient03, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient04, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient05, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient06, 0, sizeof(SifRpcClientData_t));
    memset(&SifRpcClient07, 0, sizeof(SifRpcClientData_t));
}

int SecrDownloadHeader(int port, int slot, void *buffer, SecrBitTable_t *BitTable, s32 *pSize)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    ((struct SecrSifDownloadHeaderParams *)RpcBuffer)->port = port;
    ((struct SecrSifDownloadHeaderParams *)RpcBuffer)->slot = slot;
    memcpy(((struct SecrSifDownloadHeaderParams *)RpcBuffer)->buffer, buffer, sizeof(((struct SecrSifDownloadHeaderParams *)RpcBuffer)->buffer));

    if (SifCallRpc(&SifRpcClient01, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        memcpy(BitTable, &((struct SecrSifDownloadHeaderParams *)RpcBuffer)->BitTable, ((struct SecrSifDownloadHeaderParams *)RpcBuffer)->size);
        // BUG: pSize doesn't seem to be filled in within the Sony original.
        if (pSize != NULL)
            *pSize = ((struct SecrSifDownloadHeaderParams *)RpcBuffer)->size;
        result = ((struct SecrSifDownloadHeaderParams *)RpcBuffer)->result;
    }

    return result;
}

int SecrDownloadBlock(void *src, unsigned int size)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    memcpy(((struct SecrSifDownloadBlockParams *)RpcBuffer)->buffer, src, sizeof(((struct SecrSifDownloadBlockParams *)RpcBuffer)->buffer));
    ((struct SecrSifDownloadBlockParams *)RpcBuffer)->size = size;

    if (SifCallRpc(&SifRpcClient02, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        result = ((struct SecrSifDownloadBlockParams *)RpcBuffer)->result;
    }

    return result;
}

int SecrDownloadGetKbit(int port, int slot, void *kbit)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    ((struct SecrSifDownloadGetKbitParams *)RpcBuffer)->port = port;
    ((struct SecrSifDownloadGetKbitParams *)RpcBuffer)->slot = slot;

    if (SifCallRpc(&SifRpcClient03, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        memcpy(kbit, ((struct SecrSifDownloadGetKbitParams *)RpcBuffer)->kbit, sizeof(((struct SecrSifDownloadGetKbitParams *)RpcBuffer)->kbit));
        result = ((struct SecrSifDownloadGetKbitParams *)RpcBuffer)->result;
    }

    return result;
}

int SecrDownloadGetKc(int port, int slot, void *kc)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    ((struct SecrSifDownloadGetKcParams *)RpcBuffer)->port = port;
    ((struct SecrSifDownloadGetKcParams *)RpcBuffer)->slot = slot;

    if (SifCallRpc(&SifRpcClient04, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        memcpy(kc, ((struct SecrSifDownloadGetKcParams *)RpcBuffer)->kc, sizeof(((struct SecrSifDownloadGetKcParams *)RpcBuffer)->kc));
        result = ((struct SecrSifDownloadGetKcParams *)RpcBuffer)->result;
    }

    return result;
}

int SecrDownloadGetICVPS2(void *icvps2)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    if (SifCallRpc(&SifRpcClient05, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        memcpy(icvps2, ((struct SecrSifDownloadGetIcvps2Params *)RpcBuffer)->icvps2, sizeof(((struct SecrSifDownloadGetIcvps2Params *)RpcBuffer)->icvps2));
        result = ((struct SecrSifDownloadGetIcvps2Params *)RpcBuffer)->result;
    }

    return result;
}

int SecrDiskBootHeader(void *buffer, SecrBitTable_t *BitTable, s32 *pSize)
{
    int result;

    DPRINTF("%s: starts\n", __func__);
    memcpy(((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->buffer, buffer, sizeof(((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->buffer));

    if (SifCallRpc(&SifRpcClient06, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        memcpy(BitTable, &((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->BitTable, ((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->size);
        // BUG: pSize doesn't seem to be filled in within the Sony original.
        if (pSize != NULL)
            *pSize = ((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->size;
        result = ((struct SecrSifDiskBootHeaderParams *)RpcBuffer)->result;
    }

    return result;
}

int SecrDiskBootBlock(void *src, void *dst, unsigned int size)
{
    int result;
    DPRINTF("%s: starts\n", __func__);

    memcpy(((struct SecrSifDiskBootBlockParams *)RpcBuffer)->source, src, size);
    ((struct SecrSifDiskBootBlockParams *)RpcBuffer)->size = size;

    if (SifCallRpc(&SifRpcClient07, 1, 0, RpcBuffer, sizeof(RpcBuffer), RpcBuffer, sizeof(RpcBuffer), NULL, NULL) < 0) {
        DPRINTF("%s: rpc error\n", __func__);
        result = 0;
    } else {
        result = ((struct SecrSifDiskBootBlockParams *)RpcBuffer)->result;
        memcpy(dst, ((struct SecrSifDiskBootBlockParams *)RpcBuffer)->destination, size);
    }

    return result;
}

static unsigned short int GetHeaderLength(const void *buffer)
{
    return ((const SecrKELFHeader_t *)buffer)->KELF_header_size;
}

static void store_kbit(void *buffer, const void *kbit)
{
    const SecrKELFHeader_t *header = buffer;
    int offset = sizeof(SecrKELFHeader_t), kbit_offset;

    if (header->BIT_count > 0)
        offset += header->BIT_count * sizeof(SecrBitBlockData_t);
    if ((*(unsigned int *)&header->flags) & 1)
        offset += ((unsigned char *)buffer)[offset] + 1;
    if (((*(unsigned int *)&header->flags) & 0xF000) == 0)
        offset += 8;

    kbit_offset = (unsigned int)buffer + offset;
    memcpy((void *)kbit_offset, kbit, 16);
    DPRINTF("%s: kbit_offset: %d\n", __func__, kbit_offset);
}

static void store_kc(void *buffer, const void *kc)
{
    const SecrKELFHeader_t *header = buffer;
    int offset = sizeof(SecrKELFHeader_t), kc_offset;

    if (header->BIT_count > 0)
        offset += header->BIT_count * sizeof(SecrBitBlockData_t);
    if ((*(unsigned int *)&header->flags) & 1)
        offset += ((unsigned char *)buffer)[offset] + 1;
    if (((*(unsigned int *)&header->flags) & 0xF000) == 0)
        offset += 8;

    kc_offset = (unsigned int)buffer + offset + 0x10; // Goes after Kbit.
    memcpy((void *)kc_offset, kc, 16);
    DPRINTF("%s: kc_offset: %d\n", __func__, kc_offset);
}

static int Uses_ICVPS2(const void *buffer)
{
    return (((const SecrKELFHeader_t *)buffer)->flags >> 1 & 1);
}

static void store_icvps2(void *buffer, const void *icvps2)
{
    unsigned int pICVPS2;

    pICVPS2 = (unsigned int)buffer + ((SecrKELFHeader_t *)buffer)->KELF_header_size - 8;
    memcpy((void *)pICVPS2, icvps2, 8);
    DPRINTF("\ticvps2_offset %u\n", pICVPS2);
}

static unsigned int get_BitTableOffset(const void *buffer)
{
    DPRINTF("%s: starts\n", __func__);
    const SecrKELFHeader_t *header = buffer;
    int offset = sizeof(SecrKELFHeader_t);

    if (header->BIT_count > 0)
        offset += header->BIT_count * sizeof(SecrBitBlockData_t); // They used a loop for this. D:
    if ((*(unsigned int *)&header->flags) & 1)
        offset += ((const unsigned char *)buffer)[offset] + 1;
    if (((*(unsigned int *)&header->flags) & 0xF000) == 0)
        offset += 8;
    return (offset + 0x20); // Goes after Kbit and Kc.
}

void *SecrDownloadFile(int port, int slot, void *buffer)
{
    SecrBitTable_t BitTableData;
    unsigned int offset, i;
    void *result;
    unsigned char kbit[16], kcontent[16], icvps2[8];

    DPRINTF("%s: starts\n", __func__);
    if (SecrDownloadHeader(port, slot, buffer, &BitTableData, NULL) != 0) {
        if (BitTableData.header.block_count > 0) {
            offset = BitTableData.header.headersize;
            for (i = 0; i < BitTableData.header.block_count; i++) {
                if (BitTableData.blocks[i].flags & 2) {
                    if (!SecrDownloadBlock((void *)((unsigned int)buffer + offset), BitTableData.blocks[i].size)) {
                        DPRINTF("%s: failed\n", __func__);
                        return NULL;
                    }
                }
                offset += BitTableData.blocks[i].size;
            }
        }

        if (SecrDownloadGetKbit(port, slot, kbit) == 0) {
            DPRINTF("%s: Cannot get kbit\n", __func__);
            return NULL;
        } else {
            DPRINTF("kbit: { "); for (i = 0; i < 16; i++) DPRINTF("%02x ", kbit[i]); DPRINTF(" }\n");
            memcpy(Gkbit, kbit, 16);
        }
        if (SecrDownloadGetKc(port, slot, kcontent) == 0) {
            DPRINTF("%s: Cannot get kc\n", __func__);
            return NULL;
        } else {
            DPRINTF("kcontent: { "); for (i = 0; i < 16; i++) DPRINTF("%02x ", kcontent[i]); DPRINTF(" }\n");
            memcpy(Gkcontent, kcontent, 16);
        }

        store_kbit(buffer, kbit);
        store_kc(buffer, kcontent);

        if (Uses_ICVPS2(buffer) == 1) {
            if (SecrDownloadGetICVPS2(icvps2) == 0) {
                DPRINTF("%s: Cannot get icvps2\n", __func__);
                return NULL;
            } else {
                DPRINTF("icvps2: { "); for (i = 0; i < 8; i++) DPRINTF("%02x ", icvps2[i]); DPRINTF(" }\n");
            }

            store_icvps2(buffer, icvps2);
        }

        result = buffer;
    } else {
        DPRINTF("%s: Cannot encrypt header\n", __func__);
        return NULL;
    }

    DPRINTF("%s complete\n", __func__);

    return result;
}

void *SecrDiskBootFile(void *buffer)
{
    void *result;
    SecrBitTable_t *BitTableData;
    unsigned int offset, i;

    DPRINTF("%s: starts\n", __func__);
    BitTableData = (SecrBitTable_t *)((unsigned int)buffer + get_BitTableOffset(buffer));
    if (SecrDiskBootHeader(buffer, BitTableData, NULL)) {
        if (BitTableData->header.block_count > 0) {
            offset = BitTableData->header.headersize;
            for (i = 0; i < BitTableData->header.block_count; i++) {
                if (BitTableData->blocks[i].flags & 3) {
                    if (!SecrDiskBootBlock((void *)((unsigned int)buffer + offset), (void *)((unsigned int)buffer + offset), BitTableData->blocks[i].size)) {
                        DPRINTF("%s: failed\n", __func__);
                        return NULL;
                    }
                }
                offset += BitTableData->blocks[i].size;
            }
        }

        result = (void *)((unsigned int)buffer + GetHeaderLength(buffer));
    } else {
        DPRINTF("%s: Cannot decrypt header\n", __func__);
        result = NULL;
    }

    return result;
}
