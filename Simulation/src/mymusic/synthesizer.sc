#include "defs.h"
#include "AudioPort.sc"

behavior ParseChord(i_receiver synth_stream, ChordWriter out_stream,
                    out bool valid[MAX_CHORD_SIZE],
                    out uint16_t freq_values[MAX_CHORD_SIZE],
                    out bool playing,
                    out uint8_t volume ) {

    chord_t chord = INVALID_CHORD;
    uint8_t msg;

    int i, chord_number = 0;

    // For debugging purposes
    bool _playing;
    uint8_t _volume;
    uint16_t _freq_values[MAX_CHORD_SIZE];

    void main(void) {
        while (1) {
            synth_stream.receive(&msg, 1ul);
            printf("msg: %d \t", msg);

            if ((msg & 0xF0) == 0x80) {
                playing = _playing = (msg & 0x1);

            } else if ((msg & 0xF0) == 0xA0) {
                volume = _volume = (msg & 0xf);

            } else {
                chord[chord_number] = msg;
                if (msg <= MAX_NOTE) {
                    freq_values[chord_number] = _freq_values[chord_number] = FREQ(msg);
                    valid[chord_number] = true;
                } else {
                    freq_values[chord_number] = _freq_values[chord_number] = 0;
                    valid[chord_number] = false;
                }

                if (chord_number == MAX_CHORD_SIZE - 1) {

                    out_stream.write_chord(chord);
                    chord_number = 0;
                } else {
                    chord_number++;
                }
            }

            // Debug printing
            printf("%d  %d  ", _playing, _volume);
            for (i = 0; i < MAX_CHORD_SIZE; i++) {
                printf("%d,", chord[i]);
            }
            printf("\t");
            PRINT_TIME_S();

            if (_playing) {
                printf("Playing: ");
                for (i = 0; i < MAX_CHORD_SIZE; i++) {
                    printf("%d,", _freq_values[i]);
                }
                printf("\t");
                PRINT_TIME_S();
            }
        }
    }
};

behavior GenWaveform(in bool valid[MAX_CHORD_SIZE],
                     in uint16_t freq_values[MAX_CHORD_SIZE],
                     in bool playing,
                     in uint8_t volume,
                     AudioWriter audio,
                     event error,
                     in bool stop ) {

    uint8_t duty_count = 0, num_valid;
    uint32_t squarewave_count[MAX_CHORD_SIZE];
    int i, count_on = 0, count = 0;

    bool squarewave[MAX_CHORD_SIZE];
    bool pwm[MAX_CHORD_SIZE], combined_pwm;

    uint16_t last_freq_values[MAX_CHORD_SIZE];

    void main() {
        for (i = 0; i < MAX_CHORD_SIZE; i++) {
            squarewave_count[i] = 0;
            squarewave[i] = false;
            pwm[i] = false;
        }

        while (1) {
            if (duty_count < 14) duty_count++;
            else duty_count = 0;

            num_valid = 0;
            count_on = 0;

            for (i = 0; i < MAX_CHORD_SIZE; i++) {
                if (last_freq_values[i] != freq_values[i]) {
                    for (i = 0; i < MAX_CHORD_SIZE; i++) {
                        squarewave_count[i] = 0;
                        squarewave[i] = false;
                        pwm[i] = 0;
                    }
                }
            }

            // Generate waveforms for individual chord components
            for (i = 0; i < MAX_CHORD_SIZE; i++) {
                if (valid[i]) {
                    num_valid++;
                    if (squarewave_count[i] < WAVE_TICKS(freq_values[i])) {
                        squarewave_count[i]++;

                    } else {
                        squarewave_count[i] = 0;
                        squarewave[i] = !squarewave[i];
                    }

                    pwm[i] = (squarewave[i] && volume > duty_count);
                    if (pwm[i]) count_on++;
                }
            }

            if (count < num_valid - 1) count++;
            else count = 0;

            // Generate combined waveform

            combined_pwm = ((count_on > count) && playing);
            audio.write_audio(combined_pwm);

            for (i = 0; i < MAX_CHORD_SIZE; i++) {
                last_freq_values[i] = freq_values[i];
            }

            waitfor(FPGA_TICK);
            if (stop) break;
        }
    }
};

behavior Synthesizer(i_receiver synth_stream, ChordWriter out_stream, event error,
                     in bool stop) {
    uint16_t freq_values[MAX_CHORD_SIZE];

    bool playing = false, valid[MAX_CHORD_SIZE];
    uint8_t volume = 0xf;

    DebugAudioPort audio;

    ParseChord parse_chord(synth_stream, out_stream, valid, freq_values, playing, volume);
    GenWaveform gen_waveform(valid, freq_values, playing, volume, audio, error, stop);

    void main(void) {
        while (1) {
            if (!audio.open_audio()) {
                notify error;
            }
            par {
                parse_chord;
                gen_waveform;
            }
            audio.close_audio();
        }
    }
};
