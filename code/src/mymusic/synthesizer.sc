#include "defs.h"

behavior Synthesizer(i_receiver synth_stream, ChordWriter out_stream) {
    uint16_t freq_values[MAX_CHORD_SIZE];
    chord_t chord;
    uint8_t msg;
    int i;

    bool playing = false;
    uint8_t volume = 8;
    int chord_number = 0;

    void parse_chord(void) {
        synth_stream.receive(&msg, 1ul);
        printf("msg: %d \t", msg);

        if ((msg & 0xF0) == 0x80) {
            playing = (msg & 0x1);

        } else if ((msg & 0xF0) == 0xA0) {
            volume = (msg & 0xf);

        } else {
            chord[chord_number] = msg;
            if (msg <= MAX_NOTE) {
                freq_values[chord_number] = FREQ(msg);
            } else {
                freq_values[chord_number] = 0;
            }

            if (chord_number == MAX_CHORD_SIZE - 1) {

                out_stream.write_chord(chord);
                chord_number = 0;
            } else {
                chord_number++;
            }
        }

        printf("%d  %d  ", playing, volume);
        for (i = 0; i < MAX_CHORD_SIZE; i++) {
            printf("%d,", chord[i]);
        }
        printf("\t");
        PRINT_TIME_S();
    }

    void main(void) {
        while (1) {
            parse_chord();
            if (playing) {
                printf("Playing: ");
                for (i = 0; i < MAX_CHORD_SIZE; i++) {
                    printf("%d,", freq_values[i]);
                }
                printf("\t");
                PRINT_TIME_S();
            }
        }
    }
};
