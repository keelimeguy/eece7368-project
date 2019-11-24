#include <unistd.h>
#include "defs.h"

behavior StreamingElement(i_receiver chord_stream, ChordWriter synth_stream, in int bpm, event error) {
    chord_t chord;
    uint32_t sim_iteration = 0;
    int err;

    void main(void) {
        while (1) {
            chord_stream.receive(chord, MAX_CHORD_SIZE);

            err = synth_stream.write_chord(chord);
            if (err) notify error;

            usleep(SIM_WAIT_TIME(bpm, sim_iteration) / (1 MICRO_SEC));
            waitfor(SIM_WAIT_TIME(bpm, sim_iteration));
            sim_iteration++;
        }
    }
};
