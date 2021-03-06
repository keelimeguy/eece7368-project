#include "defs.h"

behavior Translator(i_receiver char_stream,
                    i_sender chord_stream,
                    event error,
                    in bool stop,
                    out bool stop_stream,
                    out int final_chord_num) {

    char c; int i;
    bool in_chord = false, note_valid = false;
    int chord_idx = 0;
    chord_t chord = INVALID_CHORD;
    chord_t repeat_chord = REPEAT_CHORD;
    int num_chords = 0;

    void trigger_error(void) {
        notify error;

        in_chord = false;
        note_valid = false;
        for (i = 0; i < MAX_CHORD_SIZE; i++) {
            chord[i] = INVALID_NOTE;
        }
        chord_idx = 0;
    }

    note_t convert_char_to_note(char ch) {
        switch (ch) {
            case 'C': return NOTE_C;
            case 'D': return NOTE_D;
            case 'E': return NOTE_E;
            case 'F': return NOTE_F;
            case 'G': return NOTE_G;
            case 'A': return NOTE_A;
            case 'B': return NOTE_B;

            default:
                return INVALID_NOTE;
        }
    }

    void main(void) {
        while (1) {
            char_stream.receive(&c, 1);
            // printf("<- %c\n", c);

            switch (c) {
                case '.': // pause
                    if (in_chord || note_valid)
                        trigger_error();

                    chord_stream.send(chord, MAX_CHORD_SIZE);
                    num_chords++;
                    break;

                case '-': // repeat chord
                    if (in_chord || note_valid)
                        trigger_error();

                    chord_stream.send(repeat_chord, MAX_CHORD_SIZE);
                    num_chords++;
                    break;

                case '(': // begin chord
                    if (chord_idx != 0 || in_chord)
                        trigger_error();

                    in_chord = true;
                    break;

                case ')': // end chord
                    if (!in_chord)
                        trigger_error();

                    chord_stream.send(chord, MAX_CHORD_SIZE);
                    num_chords++;

                    in_chord = false;
                    for (i = 0; i < MAX_CHORD_SIZE; i++) {
                        chord[i] = INVALID_NOTE;
                    }
                    chord_idx = 0;
                    break;

                case 'b': // flat
                    if (!note_valid)
                        trigger_error();

                    chord[chord_idx - 1]--;

                    if (chord[chord_idx - 1] < MIN_NOTE)
                        trigger_error();
                    break;

                case '#': // sharp
                    if (!note_valid)
                        trigger_error();

                    chord[chord_idx - 1]++;

                    if (chord[chord_idx - 1] > MAX_NOTE)
                        trigger_error();
                    break;

                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    if (!note_valid)
                        trigger_error();

                    chord[chord_idx - 1] += 12 * (int)(c - '0');
                    note_valid = false;

                    if (!in_chord) {
                        // printf("-> ");
                        // for (i = 0; i < MAX_CHORD_SIZE; i++)
                        //     printf("%d,", chord[i]);
                        // printf("\n");

                        chord_stream.send(chord, MAX_CHORD_SIZE);
                        num_chords++;

                        for (i = 0; i < MAX_CHORD_SIZE; i++) {
                            chord[i] = INVALID_NOTE;
                        }
                        chord_idx = 0;
                    }

                    break;

                default:
                    if (note_valid || chord_idx >= MAX_CHORD_SIZE)
                        trigger_error();

                    chord[chord_idx] = convert_char_to_note(c);

                    if (chord[chord_idx] == INVALID_NOTE)
                        trigger_error();

                    note_valid = true;
                    chord_idx++;

            }

            if (stop) break;
        }
        stop_stream = true;
        final_chord_num = num_chords;
        printf("stop_stream: %d\n", num_chords);
    }
};
