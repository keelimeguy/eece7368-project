import logging
import time
import sys
from .translator import Translator
from .input_streamer import InputStreamer, SongStreamer
from .streaming_element import StreamingElement

logger = logging.getLogger(__name__)


class MyMusic:

    def __init__(self, serial_writer, max_chord_size, volume=10, song=None, bpm=None, repeat=1):
        logger.debug('new {} with max_chord_size={}'.format(type(self).__name__, max_chord_size))

        if song is None:
            self.exit_streamer = None
            self.input_streamer = InputStreamer()
        else:
            self.exit_streamer = InputStreamer(blocking=False)
            self.input_streamer = SongStreamer(song, repeat)

        self.streaming_element = StreamingElement(serial_writer, max_chord_size, bpm=bpm, volume=volume)
        self.translator = Translator(max_chord_size, self.input_streamer.get_next_char, self.streaming_element.write_chord)
        self.running = False

    def start(self):
        logger.debug('{} started..'.format(type(self).__name__))
        self.running = True

        self.streaming_element.start()
        self.translator.start()

        while self.running and self.translator.running and self.streaming_element.running:
            if self.exit_streamer:
                try:
                    self.exit_streamer.get_next_char()
                except:
                    self.stop()
                    sys.exit(0)

            time.sleep(.01)

        if not self.running:
            sys.exit(0)

        if self.translator.stop_program:
            self.stop()
            sys.exit(0)

        elif self.translator.done:
            while not self.streaming_element.empty:
                time.sleep(.01)
            self.stop()
            sys.exit(0)

    def stop(self):
        logger.debug('{} stopping..'.format(type(self).__name__))

        if self.translator is not None:
            self.translator.stop()
            self.translator.join()
            logger.debug('{} stopped.'.format(type(self.translator).__name__))
            self.translator = None

        if self.streaming_element is not None:
            self.streaming_element.stop()
            self.streaming_element.join()
            logger.debug('{} stopped.'.format(type(self.streaming_element).__name__))
            self.streaming_element = None

        logger.debug('{} stopped.'.format(type(self).__name__))
        self.running = False
