#include "translator.sc"
#include "streaming_element.sc"
#include "synthesizer.sc"

#include <stdio.h>
#include "defs.h"

behavior DUT(i_receiver char_stream, ChordWriter out_stream, event error, in bool stop) {
    c_queue chord_stream(3ul);
    DebugChordWriter synth_stream;
    bool stop_stream = false, stop_waveform = false;
    int final_chord_num = 0;

    Translator translator(char_stream, chord_stream, error, stop, stop_stream,
                          final_chord_num);
    StreamingElement streaming_element(chord_stream, synth_stream, BPM, error,
                                       final_chord_num, stop_stream, stop_waveform);
    Synthesizer synthesizer(synth_stream, out_stream, error, stop_waveform);

    void main(void) {
        par {
            translator;
            streaming_element;
            synthesizer;
        }
    }
};
