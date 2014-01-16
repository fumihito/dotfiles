#!/bin/bash
##
## Makefile handy health checker
##

## First, list up variables.

TARGET=$1
QUIET="-q"

# below escaped code mean: egrep -o '\$\(\S+\)|\$\{\S+\}|\$[a-zA-Z0-9_\-]+' 
VARIABLES=`cat ${TARGET}|egrep -v '^\\s*#'  | egrep -o '\\$\\(\\S+\\)|\\$\\{\\S+\\}|\\$[a-zA-Z0-9_\\-]+'`

## Second. check variables, it it have decrararations in same files?

for i in ${VARIABLES}; do
    TOKEN=`echo $i | egrep -o '[a-zA-Z0-9_\\-]*'`
    egrep ${QUIET} "${TOKEN}.*=" ${TARGET} || \
        echo "${TOKEN} is used in ${TARGET}, but not declared in same file."
done
