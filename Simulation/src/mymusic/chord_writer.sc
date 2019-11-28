#include "defs.h"

interface ChordWriter {
    int write_chord(chord_t chord);
};

interface ChordReader {
    void read_chord(chord_t chord);
};

channel DebugChordWriter implements i_receiver, ChordWriter, ChordReader {
    c_queue queue(5ul);
    uint8_t msg;

    int write_chord(chord_t chord) {
        msg = START_CHORD_CODE;
        queue.send(&msg, 1ul);

        queue.send(chord, MAX_CHORD_SIZE);

        msg = END_CHORD_CODE;
        queue.send(&msg, 1ul);

        return 0;
    }

    void read_chord(chord_t chord) {
        queue.receive(&msg, 1);
        queue.receive(chord, MAX_CHORD_SIZE);
        queue.receive(&msg, 1);
    }

    void receive(void *chord, unsigned long i) {
        queue.receive(chord, i);
    }
};
