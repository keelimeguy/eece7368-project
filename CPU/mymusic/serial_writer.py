import logging
import serial

logger = logging.getLogger(__name__)


class SerialWriter:
    def __init__(self, port):
        logger.debug('new {} with port={}'.format(type(self).__name__, port))
        self.port = port

    def _send(self, val):
        val = bytes([val])
        logger.debug('sending: {}'.format(val))
        self.ser.write(val)

    def write(self, chord):
        for val in chord:
            assert(-1 <= val <= 127)

            if val == -1:
                val = 0xff

            self._send(val)

    def set_volume(self, volume):
        assert(0 <= volume <= 15)
        self._send(0xA0 + volume)

    def set_playback(self, enable):
        self._send(0x80 + (1 if enable else 0))

    def open(self):
        logger.debug('opening {} at port: {}'.format(type(self).__name__, self.port))
        self.ser = serial.Serial(self.port)
        logger.debug(self.ser)

    def close(self):
        logger.debug('closing {} at port: {}'.format(type(self).__name__, self.port))
        self.ser.close()
        self.ser = None

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, type, value, traceback):
        self.set_playback(False)
        self.close()
