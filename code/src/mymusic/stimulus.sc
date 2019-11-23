#include <stdio.h>
#include "defs.h"

behavior Stimulus(i_sender char_stream) {
    char sequence[] = "G3{}A3{}B3{}C4{}D4{}E4{}F#4{}{B3D4G4}--{}";
    int i;

    void main(void) {
        printf("\nTX: ");
        for (i = 0; sequence[i] != 0; i++)
            printf("%c", sequence[i]);
        printf("\n\n");

        for (i = 0; sequence[i] != 0; i++) {
            char_stream.send(&sequence[i], 1);
        }
    }
};
