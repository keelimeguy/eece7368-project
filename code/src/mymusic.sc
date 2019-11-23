import "c_queue";

#include "mymusic/stimulus.sc"
#include "mymusic/dut.sc"
#include "mymusic/monitor.sc"

behavior Start(event error) {
    c_queue char_stream(1ul);
    c_queue synth_stream(3ul);

    Stimulus stimulus(char_stream);
    DUT dut(char_stream, synth_stream, error);
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
