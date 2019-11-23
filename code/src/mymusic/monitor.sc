#include <stdio.h>
#include "defs.h"

behavior Monitor(i_receiver synth_stream) {
    chord_t chord;
    int i;

    void main(void) {
        while (1) {
            synth_stream.receive(chord, MAX_CHORD_SIZE);
            printf("RX: ");
            for (i = 0; i < MAX_CHORD_SIZE; i++)
                printf("%d,", chord[i]);
            printf("\t");
            PRINT_TIME_S();
        }
    }
};
