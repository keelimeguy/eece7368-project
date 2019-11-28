#include <unistd.h>
#include "defs.h"

behavior StreamingElement(i_receiver chord_stream,
                          ChordWriter synth_stream,
                          in int bpm,
                          event error,
                          in int final_chord_num,
                          in bool stop_stream,
                          out bool stop_waveform) {

    chord_t chord;
    uint32_t sim_iteration = 0;
    int err;
    int num_chords = 0;

    bool stop;

    void main(void) {
        while (1) {
            chord_stream.receive(chord, MAX_CHORD_SIZE);
            num_chords++;

            if (chord[0] != REPEAT_CHORD_CODE) {
                err = synth_stream.write_chord(chord);
                if (err) notify error;
            }

            usleep(SIM_WAIT_TIME(bpm, sim_iteration) / (1 MICRO_SEC));
            waitfor(SIM_WAIT_TIME(bpm, sim_iteration));
            sim_iteration++;

            if (stop_stream && num_chords == final_chord_num) break;
        }
        printf("stop_waveform\n");
        stop_waveform = true;
    }
};
