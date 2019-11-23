#include <unistd.h>
#include "defs.h"

behavior StreamingElement(i_receiver chord_stream, i_sender synth_stream, in int bpm) {

    chord_t chord;
    uint32_t sim_iteration = 0;

    void main(void) {
        while (1) {
            chord_stream.receive(chord, MAX_CHORD_SIZE);

            synth_stream.send(chord, MAX_CHORD_SIZE);

            usleep(SIM_WAIT_TIME(bpm, sim_iteration) / (1 MICRO_SEC));
            waitfor(SIM_WAIT_TIME(bpm, sim_iteration));
            sim_iteration++;
        }
    }
};
