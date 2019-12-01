#include <stdio.h>
#include "defs.h"

behavior Stimulus(i_sender char_stream, out bool stop) {
    char sequence[] = STIMULUS_SEQUENCE;
    int i;

    void main(void) {
        printf("\nTX: ");
        for (i = 0; sequence[i] != 0; i++)
            printf("%c", sequence[i]);
        printf("\n\n");

        for (i = 0; sequence[i] != 0; i++) {
            char_stream.send(&sequence[i], 1);
        }

#if MAX_CHORD_SIZE > 1
        waitfor(2 + SIM_WAIT_TIME(BPM, 0));
#endif
        stop = true;
    }
};
