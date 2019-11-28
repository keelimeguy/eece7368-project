#include "defs.h"
#include <stdio.h>

interface AudioWriter {
    bool open_audio();
    void close_audio();
    void write_audio(bool pwm);
};

channel DebugAudioPort implements AudioWriter {
    FILE *fptr = 0;
    uint8_t val;

    bool open_audio() {
        if (fptr == 0) {
            fptr = fopen(AUDIO_FILE, "wb");
            if (fptr == 0) return false;
        }
        return true;
    }

    void close_audio() {
        if (fptr != 0) {
            fclose(fptr);
        }
    }

    void write_audio(bool pwm) {
        if (fptr != 0) {
            val = pwm ? 1 : 0;
            fwrite(&val, 1, 1, fptr);
        }
    }
};
