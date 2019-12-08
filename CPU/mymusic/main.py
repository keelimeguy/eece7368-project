import signal
import logging
import argparse
import sys
from .mymusic import MyMusic
from .serial_writer import SerialWriter

LOG_LEVEL = logging.INFO

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', default='COM13', help='The serial port to write output commands to.')
    parser.add_argument('--max_chord_size', '-C', default=3, type=int)

    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument('--input', '-p', default=None, help='Provide an input via command line.')
    group.add_argument('--input_file', '-f', default=None, help='Provide an input via file.')
    group.add_argument('--keyboard', '-K', action='store_true', help='Stream input like a (single-note) piano keyboard.')

    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument('--loop', '-l', action='store_true', help='Loop the given input song.')
    group.add_argument('--repeat', '-r', default=1, type=int, help='Repeat the given input song a number of times.')

    parser.add_argument('--bpm', '-b', default=0, type=int, help='Speed of the given input song.')
    parser.add_argument('--transpose', '-t', default=0, type=int, help='How much to shift each note.')
    parser.add_argument('--volume', '-v', default=1, type=int, help='How much to scale the volume of program.')

    parser.add_argument('--verbose', '-V', action='store_true', help='Use verbose debug logging.')

    args = parser.parse_args()

    if args.verbose:
        LOG_LEVEL = logging.DEBUG

    logging.basicConfig(level=LOG_LEVEL, format='%(threadName)s.%(name)s:%(lineno)d [%(levelname)s] %(message)s')
    logger = logging.getLogger(__name__)

    repeat = args.repeat
    if args.loop:
        repeat = -1

    song = args.input
    if args.input_file:
        song = ''
        with open(args.input_file) as f:
            for line in f:
                song += line.replace(' ','').strip()
    logger.info('Input is: {}'.format(song))

    mymusic = None

    def handler(signum, frame):
        if mymusic is not None:
            mymusic.stop()

    signal.signal(signal.SIGINT, handler)

    while True:
        with SerialWriter(args.port) as serial_writer:
            mymusic = MyMusic(serial_writer, args.max_chord_size, volume=args.volume, transpose=args.transpose, song=song, bpm=args.bpm, repeat=repeat, keyboard=args.keyboard)

            mymusic.start()
            logging.error('Execution has ended unexpectedly.')
            mymusic.stop()

        logger.warning('Restarting..')
