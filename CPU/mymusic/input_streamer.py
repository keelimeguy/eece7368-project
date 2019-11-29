import logging
import sys

try:
    # Windows OS
    from msvcrt import getche, kbhit

except:
    # Linux OS, etc.
    # WARNING: this is untested, as I personally use Windows

    # https://code.activestate.com/recipes/572182-how-to-implement-kbhit-on-linux/

    import termios
    import atexit
    from select import select

    _fd = sys.stdin.fileno()
    _new_term = termios.tcgetattr(_fd)
    _old_term = termios.tcgetattr(_fd)
    _new_term[3] = (_new_term[3] & ~termios.ICANON & ~termios.ECHO)

    # switch to normal terminal
    def _set_normal_term():
        termios.tcsetattr(_fd, termios.TCSAFLUSH, _old_term)

    # switch to unbuffered terminal
    def _set_curses_term():
        termios.tcsetattr(_fd, termios.TCSAFLUSH, _new_term)

    def getche():
        ch = sys.stdin.read(1)
        sys.stdout.write(ch)
        return ch

    def kbhit():
        dr, dw, de = select([sys.stdin], [], [], 0)
        return dr

    atexit.register(_set_normal_term)
    _set_curses_term()


logger = logging.getLogger(__name__)


class InputStreamer:
    def __init__(self, blocking=True):
        logger.debug('new {}'.format(type(self).__name__))
        self.blocking = blocking
        self.started = False

    def get_next_char(self):
        if not self.started:
            logger.info('Begin inputting sequence..')
            self.started = True

        print(end='', flush=True)

        c = None
        if self.blocking or kbhit():
            c = getche().decode()
            assert(c not in ['q', '\r', '\n'])
            logger.debug('sending: {}'.format(c))

        return c


class SongStreamer(InputStreamer):
    def __init__(self, song, repeat=-1):
        logger.debug('new {} with repeat={}'.format(type(self).__name__, repeat))

        self.song = song
        self.repeat = repeat-1
        self.idx = 0

    def get_next_char(self):
        if self.idx == len(self.song):
            if self.repeat:
                if self.repeat > 0:
                    self.repeat -= 1
                self.idx = 0
            else:
                logger.info('song has completed input stream')
                return

        c = self.song[self.idx]
        self.idx += 1

        logger.debug('sending: {}'.format(c))
        return c
