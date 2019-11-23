#ifndef DEFS_H
#define DEFS_H

#include <stdint.h>
#include <stdio.h>

#define BPM 160
#define MAX_CHORD_SIZE 3

typedef int8_t note_t;
typedef note_t chord_t[MAX_CHORD_SIZE];

#define NOTE_C 12
#define NOTE_D 14
#define NOTE_E 16
#define NOTE_F 17
#define NOTE_G 19
#define NOTE_A 21
#define NOTE_B 23

#define MIN_NOTE 0
#define MAX_NOTE 127

#define INVALID_NOTE -1
#define INVALID_CHORD {INVALID_NOTE,INVALID_NOTE,INVALID_NOTE}

#define FREQ(note) (440 * (1 << ((note - 69) / 12)))

/**** Timing ****/

#include <sim/time.sh>

#define SIM_WAIT_TIME_EXACT(BPM) (60.0 SEC / BPM)
#define SIM_WAIT_TIME_APPROX(BPM) (unsigned long long)(SIM_WAIT_TIME_EXACT(BPM))
#define SIM_WAIT_TIME_CORRECTION_BASE(BPM) ((SIM_WAIT_TIME_EXACT(BPM) - SIM_WAIT_TIME_APPROX(BPM)) ? 1.0 / (SIM_WAIT_TIME_EXACT(BPM) - SIM_WAIT_TIME_APPROX(BPM)) : 0.0)
#define SIM_WAIT_TIME_CORRECTION(BPM, iteration) (SIM_WAIT_TIME_CORRECTION_BASE(BPM) ? 1 - (int)(iteration - (int)(iteration / SIM_WAIT_TIME_CORRECTION_BASE(BPM)) * SIM_WAIT_TIME_CORRECTION_BASE(BPM)) : 0)
#define SIM_WAIT_TIME(BPM, iteration) (SIM_WAIT_TIME_APPROX(BPM) + SIM_WAIT_TIME_CORRECTION(BPM, iteration))

#define PRINT_TIME_PS() printf("Time = %llu ps\n", now())
#define PRINT_TIME_NS() printf("Time = %f ns\n", now() / (1.0 NANO_SEC))
#define PRINT_TIME_US() printf("Time = %f us\n", now() / (1.0 MICRO_SEC))
#define PRINT_TIME_MS() printf("Time = %f ms\n", now() / (1.0 MILLI_SEC))
#define PRINT_TIME_S() printf("Time = %f s\n", now() / (1.0 SEC))

#endif
