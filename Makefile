# ------------------ Compilation options ------------------------


WARNS = -W -Wall
INCLUDES = -Iinclude
LIBS = 

HAS_SQLITE = 1


include Makefile.platform

ifdef UNIT_TEST
	DFLAGS := ${DFLAGS} -unittest -debug 
endif

DFLAGS := ${DFLAGS}

ifeq ($(PROFILER),gprof)
	DFLAGS := ${DFLAGS} -q,-pg -K-q,-pg
endif

ifndef PROFILE
	PROFILE := release
endif
	
ifeq ($(PROFILE),debug)
#	DFLAGS := ${DFLAGS} -g -release -C-q,-msse2
	#DFLAGS := ${DFLAGS} -g -debug -C-q,-msse2
	DFLAGS := ${DFLAGS} -g -debug
else ifeq (${PROFILE},release)
#	DFLAGS := ${DFLAGS} -O -inline -release -C-q,-fno-bounds-check -C-q,-funroll-loops
	DFLAGS := ${DFLAGS} -O -inline -release -C-q,-pipe
endif

ifeq ($(HAS_SQLITE),1)
	DFLAGS := ${DFLAGS} -version=hasSqlite
	LIBS := -llsqlite3 -lldl
endif


ifndef TARGET	
	#TARGET := $(shell basename `pwd`)
	TARGET = nn
endif
# --------------------- Dirs  ----------------------------

SRC_DIR = src
LIBS_DIR = libs
BUILD_DIR = $(HOME)/tmp/${TARGET}_build/${PROFILE}
DEPS_DIR = ${BUILD_DIR}/deps
OBJ_DIR = ${BUILD_DIR}/obj
DOC_DIR = doc
RES_DIR = res
BIN_DIR = bin

MAIN_FILE=${SRC_DIR}/main.d


# ------------------------ Rules --------------------------------

.PHONY: clean all rebuild compile

all: compile
	cp ${BUILD_DIR}/${TARGET} .

clean:
	rm -rf ${BUILD_DIR}/*

rebuild: clean all

compile:
	 ${BIN_DIR}/rebuild -oq${OBJ_DIR} ${MAIN_FILE} -I${SRC_DIR} -I${LIBS_DIR} -of${BUILD_DIR}/${TARGET} ${DFLAGS} ${LIBS}

