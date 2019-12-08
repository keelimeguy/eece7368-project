import logging
import threading
import traceback

logger = logging.getLogger(__name__)


class Translator(threading.Thread):
    note_lookup = {
        'C': 12,
        'D': 14,
        'E': 16,
        'F': 17,
        'G': 19,
        'A': 21,
        'B': 23,
    }

    def __init__(self, max_chord_size, get_next_char, chord_callback, transpose=0):
        logger.debug('new {}'.format(type(self).__name__))
        super(Translator, self).__init__()

        self.max_chord_size = max_chord_size
        self.get_next_char = get_next_char

        self._chord_callback = chord_callback
        self.transpose = transpose

        self.idx = 0
        self.in_chord = False
        self.note_valid = False
        self.chord = self.max_chord_size*[-1]
        self.last_chord = self.max_chord_size*[-1]

        self.running = False
        self.done = False
        self.stop_program = False

    def chord_callback(self, chord):
        logger.debug('sending: {}'.format(chord))
        self._chord_callback(chord)

    def send(self, chord):
        self.last_chord = chord
        self.chord_callback(chord)

        self.idx = 0
        self.in_chord = False
        self.note_valid = False
        self.chord = self.max_chord_size*[-1]

    def convert_char_to_note(self, c):
        return self.note_lookup[c] + self.transpose

    def start(self):
        self.running = True
        super(Translator, self).start()

    def run(self):
        try:
            logger.debug('{} started..'.format(type(self).__name__))

            while self.running:
                self.translate()

        except:
            self.running = False
            traceback.print_exc()

    def stop(self):
        logger.debug('{} stopping..'.format(type(self).__name__))
        self.running = False

    def translate(self):
        try:
            c = self.get_next_char()
            if c is None:
                self.done = True
                self.stop()
                return
        except:
            self.stop_program = True
            self.stop()
            return

        if c == '.':
            assert(not self.in_chord and not self.note_valid)
            self.send(self.max_chord_size*[-1])

        elif c == '-':
            assert(not self.in_chord and not self.note_valid)
            self.send(self.last_chord)

        elif c == '(':
            assert(not self.in_chord and self.idx == 0)
            self.in_chord = True

        elif c == ')':
            assert(self.in_chord)
            self.send(self.chord)

        elif c == 'b':
            assert(self.note_valid)
            self.chord[self.idx - 1] -= 1
            assert(self.chord[self.idx-1] >= 0)

        elif c == '#':
            assert(self.note_valid)
            self.chord[self.idx - 1] += 1
            assert(self.chord[self.idx-1] <= 127)

        elif '0' <= c <= '9':
            assert(self.note_valid)
            self.chord[self.idx - 1] += 12 * int(c)
            self.note_valid = False

            if not self.in_chord:
                self.send(self.chord)

        else:
            assert(not self.note_valid and self.idx < self.max_chord_size)
            self.chord[self.idx] = self.convert_char_to_note(c)
            self.note_valid = True
            self.idx += 1


class KeyboardTranslator(Translator):
    def __init__(self, max_chord_size, get_next_char, chord_callback, transpose=0):
        super(KeyboardTranslator, self).__init__(max_chord_size, get_next_char, chord_callback, transpose=transpose)
        self.octave = 3

        self.key_lookup = {
            'a': self.note_lookup['C'],
            'w': self.note_lookup['C']+1,
            's': self.note_lookup['D'],
            'e': self.note_lookup['D']+1,
            'd': self.note_lookup['E'],
            'f': self.note_lookup['F'],
            't': self.note_lookup['F']+1,
            'g': self.note_lookup['G'],
            'y': self.note_lookup['G']+1,
            'h': self.note_lookup['A'],
            'u': self.note_lookup['A']+1,
            'j': self.note_lookup['B'],
            'k': self.note_lookup['C']+12,
            'o': self.note_lookup['C']+13,
            'l': self.note_lookup['D']+12,
            'p': self.note_lookup['D']+13,
            ';': self.note_lookup['E']+12,
            '\'': self.note_lookup['F']+12,
            ']': self.note_lookup['F']+13,
        }

    def convert_char_to_note(self, c):
        return self.key_lookup[c] + self.transpose

    def translate(self):
        try:
            c = self.get_next_char()
            if c is None:
                self.done = True
                self.stop()
                return
        except:
            self.stop_program = True
            self.stop()
            return

        if c == ' ':
            self.chord_callback(self.max_chord_size*[-1])

        elif '0' <= c <= '9':
            self.octave = int(c)

        else:
            note = self.convert_char_to_note(c) + 12 * self.octave
            if 0 <= note <= 127:
                self.chord = self.max_chord_size*[-1]
                self.chord[0] = note
                self.chord_callback(self.chord)
