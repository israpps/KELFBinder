#ifndef LIBSECR_H
#define LIBSECR_H

#include <libsecr-common.h>


int SecrInit(void);
void SecrDeinit(void);
void GetLastKbitNKc(unsigned char Kbit[16], unsigned char kcontent[16]);


#endif
