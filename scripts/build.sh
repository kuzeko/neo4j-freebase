#!/bin/bash
# set an initial value for the flag
BUILD_NEO=1

# read the options
TEMP=`getopt -o n --long neo4j -n 'run.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -n|--neo4j)
           BUILD_NEO=1
           shift ;;
        --) shift ; break ;;
        *) echo "Command error!" ; exit 1 ;;
    esac
done

if [[ ${BUILD_NEO}  -eq 1 ]]; then
  docker build -t lissandrini/neo4j-server -f neo4j-server.dockerfile .
fi

