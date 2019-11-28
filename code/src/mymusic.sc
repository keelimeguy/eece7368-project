import "c_queue";

#include "mymusic/chord_writer.sc"
#include "mymusic/stimulus.sc"
#include "mymusic/dut.sc"
#include "mymusic/monitor.sc"

behavior Start(event error) {
    c_queue char_stream(1ul);
    DebugChordWriter synth_stream;
    bool stop = false;

    Stimulus stimulus(char_stream, stop);
    DUT dut(char_stream, synth_stream, error, stop);
    Monitor monitor(synth_stream);

    void main(void) {
        par {
            stimulus;
            dut;
            monitor;
        }
    }
};

behavior ErrorHandle() {
    void main(void) {
        PRINT_TIME_MS();
        printf("An ERROR occurred!\n");
    }
};

behavior Main {
    event error;
    Start start(error);

    ErrorHandle error_handle;

    int main(void) {
        try {
            start;
        } interrupt(error) {
            error_handle;
        }
        return 0;
    }
};
