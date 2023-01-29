#include <string.h>
#include <kernel.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#include "include/sound.h"
#include "include/dbgprintf.h"

static bool adpcm_started = false;
static bool audsrv_started = false;

void sound_setvolume(int volume) {
    if(!audsrv_started) {
        audsrv_init();
        audsrv_started = true;
    }

	audsrv_set_volume(volume);
}

void sound_setformat(int bits, int freq, int channels){
    if(!audsrv_started) {
        audsrv_init();
        audsrv_started = true;
    }

	struct audsrv_fmt_t format;

    format.bits = bits;
	format.freq = freq;
	format.channels = channels;
	
	audsrv_set_format(&format);
}

void sound_setadpcmvolume(int slot, int volume) {
    if(!adpcm_started) {
        audsrv_adpcm_init();
        adpcm_started = true;
    }

	audsrv_adpcm_set_volume(slot, volume);
}

audsrv_adpcm_t* sound_loadadpcm(const char* path){
    if(!adpcm_started) {
        audsrv_adpcm_init();
        adpcm_started = true;
    }

	FILE* adpcm;
	audsrv_adpcm_t *sample = (audsrv_adpcm_t *)malloc(sizeof(audsrv_adpcm_t));
	int size;
	u8* buffer;

	adpcm = fopen(path, "rb");

	fseek(adpcm, 0, SEEK_END);
	size = ftell(adpcm);
	fseek(adpcm, 0, SEEK_SET);

	buffer = (u8*)malloc(size);

	fread(buffer, 1, size, adpcm);
	fclose(adpcm);

	audsrv_load_adpcm(sample, buffer, size);

	//free(buffer); this fucks ADPCM files larger than 180kb. as an alternative, use sound_freeadpcm() directly on lua code

	return sample;
}

void sound_freeadpcm(audsrv_adpcm_t *sample) {
	free(sample->buffer);
	sample->buffer = NULL;
	free(sample);
	sample = NULL;
}

void sound_playadpcm(int slot, audsrv_adpcm_t *sample) {
    if(!adpcm_started) {
        audsrv_adpcm_init();
        adpcm_started = true;
    }

	audsrv_ch_play_adpcm(slot, sample);
}