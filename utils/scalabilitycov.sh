#!/usr/bin/env bash
#
# Script to compute coverage, with a feature to compute coverage from
# some point in time after KLEE started executing.
#
# Copyright 2017 National University of Singapore
#
# Environment variables that can be set externally include:
#
# EXTRA_CFLAGS    - Extra CFLAGS options
# EXTRA_LDFLAGS   - Extra LDFLAGS options

PROGRAM=$1
OUTPUT_DIR=$2
TIME_SINCE=$3

if [ -z "$OUTPUT_DIR" ] ; then
    echo "Please specify program and extension"
    exit 1
fi
if [ ! -e "$OUTPUT_DIR/test000001.ktest" ] ; then
    echo "Specified output directory does not contain tests"
    exit 1
fi

export CLANG=`which clang | tr -d '\n'`
if [ -z "$CLANG" ] ; then
    echo "clang not found"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPT_DIR/../environ.sh

export CFLAGS="-g -I$KLEE_HOME/include $EXTRA_CFLAGS"

export LDFLAGS="-L$KLEE_HOME/lib $EXTRA_LDFLAGS -lkleeRuntest"

START_TIME=`stat --format="%Z" $OUTPUT_DIR/test000001.ktest | tr -d '\n'`
if [ -z "$TIME_SINCE" ] ; then
    MIN_TIME=$START_TIME
else
    MIN_TIME=`expr $START_TIME + $TIME_SINCE`
fi

for TEST in $OUTPUT_DIR/*.ktest ; do
    TIME=`stat --format="%Z" $TEST | tr -d '\n'`
    if [ $MIN_TIME -ge $TIME ] ; then
	rm -rf $PROGRAM $PROGRAM.gcno $PROGRAM.gcda
	$CLANG $CFLAGS -fprofile-arcs -ftest-coverage $LDFLAGS $PROGRAM.c -o $PROGRAM
	for KTEST in $OUTPUT_DIR/*.ktest ; do
		( LD_LIBRARY_PATH=$KLEE_HOME/lib KTEST_FILE=$KTEST KLEE_REPLAY_TIMEOUT=$KLEE_REPLAY_TIMEOUT $KLEE_REPLAY $PROGRAM $KTEST )
	done
	touch $OUTPUT_DIR/$PROGRAM.cov
	LOC_TOTAL=0
	LINE_COVERAGE=0
	if [ -e $PROGRAM.gcda ] ; then
		echo Saving llvm-cov output in $OUTPUT_DIR/$PROGRAM.cov
		llvm-cov -gcno=$PROGRAM.gcno -gcda=$PROGRAM.gcda >> $OUTPUT_DIR/$PROGRAM.cov
		LINE_COVERAGE=`grep '^[[:space:]]*[[:digit:]]\+' $OUTPUT_DIR/$PROGRAM.cov |wc -l`
		LINE_NON_COVERAGE=`grep '^[[:space:]]*#####:' $OUTPUT_DIR/$PROGRAM.cov |wc -l`
		LOC_TOTAL=`expr $LINE_COVERAGE + $LINE_NON_COVERAGE`
	fi
	( echo -n $LINE_COVERAGE > $OUTPUT_DIR/LcovLog.txt )
	( echo -n $LOC_TOTAL >	$OUTPUT_DIR/SLocCountLog.txt )
	echo Line coverage = $LINE_COVERAGE of $LOC_TOTAL	
    fi
done

