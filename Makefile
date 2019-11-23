TEST_TARGET ?= mymusic.out

SRC_DIR = ./src/
OBJ_DIR = ./obj/
BUILD_DIR = ./build/

SHELL = /bin/sh
SCC	= scc
SCCOPT ?= -vv -www -g -d

ifeq ( , $(shell which ${SCC}))
$(error "No ${SCC} in PATH, try running `source /ECEnet/Apps1/sce/latest/bin/setup.sh`")
endif

### Find all SpecC source files in SRC_DIR, do not look in subdirectories
SOURCES = $(wildcard ${SRC_DIR}/*.sc)
### Prepare object names for compilation output
OBJECTS = $(addprefix ${OBJ_DIR},$(notdir $(SOURCES:%.sc=%.sir)))
TARGETS = $(addprefix ${BUILD_DIR},$(notdir $(SOURCES:%.sc=%.out)))

### Compile the TARGETS by default
.PHONY: all
all: ${TARGETS} ${OBJECTS}

### Compile all SpecC code, placing output executables into BUILD_DIR
${BUILD_DIR}%.out: ${OBJ_DIR}%.sir
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sir2out ${SCCOPT} -i $< -o $@
# Using convention that included sources to TARGETS will be in subdirectories of the same name
# and top-level headers are included in all.
.SECONDARY: ${SCC_OBJECTS}
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc ${SRC_DIR}%/*.sc ${SRC_DIR}%/*.h ${SRC_DIR}*.h
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc ${SRC_DIR}%/*.sc ${SRC_DIR}%/*.h
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc ${SRC_DIR}%/*.sc ${SRC_DIR}*.h
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc ${SRC_DIR}%/*.sc
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc ${SRC_DIR}*.h
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@
${OBJ_DIR}%.sir: ${SRC_DIR}%.sc
	@mkdir -p $(dir $@)
	${SCC} $(basename $(notdir $<)) -sc2sir ${SCCOPT} -i $< -o $@

### Remove files created by "all" rule
.PHONY: clean
clean:
	rm -f ${TARGETS}
	rm -f ${OBJECTS}
	find ${OBJ_DIR} -type d -empty -delete | true
	find ${BUILD_DIR} -type d -empty -delete | true

### Include rules for test-running the TARGETS
TARGET = ${TEST_TARGET}
include tests.makefile
