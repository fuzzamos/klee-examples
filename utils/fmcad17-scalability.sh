#!/usr/bin/env bash
# Scalability experiments for FMCAD '17 submission
#
# Copyright 2017 National University of Singapore

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCALABILITY_DIR=$SCRIPT_DIR/../scalability

source $SCRIPT_DIR/../environ.sh

unset C_INCLUDE_PATH
unset CPLUS_INCLUDE_PATH

( \
    cd $SCALABILITY_DIR ; \
    export EXPERIMENT_SET="malloc9 malloc18 malloc27 bubble_assert6 bubble_assert7 bubble_assert8 Regexp-6-4 Regexp-7-4 Regexp-8-4 insertsort7 insertsort9 insertsort11 statemate nsichneu" ; \
    export EXPERIMENT_TYPE_SET=".klee1 .tx1 .tx2" ; \
    make experiment.csv ; \
    make llbmc-experiment.csv ; \
)

