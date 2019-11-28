#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
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

    void receive(void* chord, unsigned long i) {
        queue.receive(chord, i);
    }
};

channel SerialChordWriter implements ChordWriter {
    int fd;
    char c;
    struct termios SerialPortSettings;
    int bytes_written;

    int write_chord(chord_t chord) {
        // https://github.com/xanthium-enterprises/Serial-Port-Programming-on-Linux/blob/master/USB2SERIAL_Write/Transmitter%20(PC%20Side)/SerialPort_write.c

        fd = open("/dev/ttyUSB0", O_RDWR | O_NOCTTY | O_NDELAY);

        if (fd == -1) {
            return 1;
        }

        tcgetattr(fd, &SerialPortSettings); // Get the current attributes of the Serial port

        cfsetispeed(&SerialPortSettings, B9600); // Set Read  Speed as 9600
        cfsetospeed(&SerialPortSettings, B9600); // Set Write Speed as 9600

        // Disables the Parity Enable bit(PARENB),So No Parity
        SerialPortSettings.c_cflag &= ~PARENB;
        // CSTOPB = 2 Stop bits,here it is cleared so 1 Stop bit
        SerialPortSettings.c_cflag &= ~CSTOPB;
        // Clears the mask for setting the data size
        SerialPortSettings.c_cflag &= ~CSIZE;
        // Set the data bits = 8
        SerialPortSettings.c_cflag |= CS8;

        // No Hardware flow Control
        SerialPortSettings.c_cflag &= ~CRTSCTS;
        // Enable receiver,Ignore Modem Control lines
        SerialPortSettings.c_cflag |= CREAD | CLOCAL;

        // Disable XON/XOFF flow control both i/p and o/p
        SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);
        // Non Cannonical mode
        SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);

        //No Output Processing
        SerialPortSettings.c_oflag &= ~OPOST;

        // Set the attributes to the termios structure
        if ((tcsetattr(fd, TCSANOW, &SerialPortSettings)) != 0) {
            close(fd);
            return 1;
        }

        /*------------------------------- Write data to serial port -----------------------------*/

        // use write() to send data to port
        c = START_CHORD_CODE; bytes_written = write(fd, &c, 1);
        bytes_written = write(fd, chord, MAX_CHORD_SIZE);
        c = END_CHORD_CODE; bytes_written = write(fd, &c, 1);

        // Close the Serial port
        close(fd);
        return 0;
    }
};
