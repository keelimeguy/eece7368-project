#include "translator.sc"
#include "streaming_element.sc"
#include "synthesizer.sc"

#include "stdio.h"
#include "defs.h"

behavior DUT(i_receiver char_stream, i_sender synth_stream, event error) {

    c_queue chord_stream(3ul);

    Translator translator(char_stream, chord_stream, error);
    StreamingElement streaming_element(chord_stream, synth_stream);
    Synthesizer synthesizer;

    void main(void) {
        par {
            translator;
            streaming_element;
            synthesizer;
        }
    }
};
