#include "translator.sc"
#include "streaming_element.sc"
#include "synthesizer.sc"

#include <stdio.h>
#include "defs.h"

behavior DUT(i_receiver char_stream, ChordWriter out_stream, event error) {
    c_queue chord_stream(3ul);
    DebugChordWriter synth_stream;

    Translator translator(char_stream, chord_stream, error);
    StreamingElement streaming_element(chord_stream, synth_stream, BPM, error);
    Synthesizer synthesizer(synth_stream, out_stream);

    void main(void) {
        par {
            translator;
            streaming_element;
            synthesizer;
        }
    }
};
