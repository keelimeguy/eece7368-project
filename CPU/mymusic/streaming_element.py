import logging
import threading
import traceback
import queue
import time

logger = logging.getLogger(__name__)


class StreamingElement(threading.Thread):
    def __init__(self, serial_writer, max_chord_size, bpm=None, volume=10):
        logger.debug('new {} with bpm={}'.format(type(self).__name__, bpm))
        super(StreamingElement, self).__init__()

        serial_writer.set_volume(volume)
        self.first = True

        self.max_chord_size = max_chord_size
        self.serial_writer = serial_writer
        self.bpm = bpm

        self.last_chord = None
        self.stream = queue.Queue(100)

        self.running = False
        self.empty = True

    def start(self):
        self.running = True
        super(StreamingElement, self).start()

    def run(self):
        try:
            logger.debug('{} started..'.format(type(self).__name__))

            wait = 60.0 / self.bpm if self.bpm else 0

            while self.running:
                start = time.time()

                try:
                    chord = self.stream.get(block=False)
                    logger.debug('next: {}'.format(chord))
                    self.empty = False

                    if chord != self.last_chord:
                        self.last_chord = chord
                        self.serial_writer.write(chord)
                        if self.first:
                            self.serial_writer.set_playback(True)
                            self.first = False

                    self.stream.task_done()

                except queue.Empty:
                    self.empty = True

                end = time.time()
                next_wait = wait - (start-end)
                if next_wait > 0:
                    time.sleep(next_wait)

        except:
            self.running = False
            traceback.print_exc()

    def stop(self):
        logger.debug('{} stopping..'.format(type(self).__name__))
        self.running = False

    def write_chord(self, chord):
        self.empty = False
        logger.debug('adding: {}'.format(chord))
        self.stream.put(chord)
