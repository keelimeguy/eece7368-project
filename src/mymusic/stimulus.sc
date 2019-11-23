#include "stdio.h"
#include "defs.h"

behavior Stimulus(i_sender char_stream) {
    char sequence[] = "C4{F#5G5}Bb3G0";
    int i;

    void main(void) {
        for (i = 0; sequence[i] != 0; i++) {
            printf("TX: %c\n", sequence[i]);
            char_stream.send(&sequence[i], 1);
        }
    }
};
