#include "translator.sc"
#include "streaming_element.sc"
#include "synthesizer.sc"

#include "stdio.h"
#include "defs.h"

behavior DUT(i_receiver char_stream, i_sender chord_stream, event error) {

    Translator translator(char_stream, chord_stream, error);
    StreamingElement streaming_element;
    Synthesizer synthesizer;

    void main(void) {
        par {
            translator;
            streaming_element;
            synthesizer;
        }
    }
};
