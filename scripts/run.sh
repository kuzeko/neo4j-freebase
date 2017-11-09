#!/bin/bash
# set an initial value for the flag
CMD='neo4j'
NEO4J_AUTH='none'
MAX_MEM='15360m'
IS_NEO=0
DOCKER_OPT='-it'

# read the options
TEMP=`getopt -o aidx --long auth,import,dumpconf,index -n 'run.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -a|--auth) NEO4J_AUTH='neo4j/neo4jPassword'; IS_NEO=1 ; shift ;;
        -i|--import) CMD='import'; IS_NEO=1 ; shift ;;
        -x|--index) CMD='index'; IS_NEO=1 ; shift ;;
        -d|--dumpconf)
           CMD='dump-config'
           CONF_VOL="--volume=`pwd`/conf:/conf"
           IS_NEO=1
           shift ;;
        --) shift ; break ;;
        *) echo "Command error!" ; exit 1 ;;
    esac
done

if [[  $IS_NEO -eq 1 ]] && [[ $IS_GREM -eq 1 ]]; then
  echo "Illegal option, if you selct -g|--gremlin you cannot select any other option"
  exit 2
fi
if [[ $IS_NEO -eq 0 ]] && [[ $IS_GREM -eq 0 ]]; then
  IS_NEO=1
  CMD='neo4j'
fi


if [ ${CMD} == 'import' ]; then
    echo "Importing data from `pwd`/data into `pwd`/dbms"
elif [ ${CMD} == 'dump-config' ]; then
    echo "Exporting Neo4j configuration to `pwd`/conf"
elif [ ${CMD} == 'neo4j' ]; then
    DOCKER_OPT='-d'
fi


if [[ $IS_NEO -eq 1 ]]; then

  docker run  --publish=7473:7473 --publish=7474:7474 --publish=7687:7687 --publish=8080:8080  \
            --volume=`pwd`/dbms:/dbms   --volume=`pwd`/data:/data  ${CONF_VOL} \
            ${DOCKER_OPT} -e NEO4J_AUTH=${NEO4J_AUTH}  --env=NEO4J_dbms_memory_heap_maxSize=${MAX_MEM} \
            lissandrini/neo4j-server ${CMD}
  RET=$?

  if [ ${CMD} == 'import' ]; then
    if [ $RET -eq 0 ]; then
      echo "It seems all was fine, you can now build the indexes with -x"
    else
      echo "The import failed for some reason, you can check the log in `pwd`/dbms/"
    fi
  fi

  if [ ${CMD} == 'index' ]; then
    if [ $RET -eq 0 ]; then
      echo "It seems all was fine, you can now start the server"
    else
      echo "The index failed for some reason..."
    fi
  fi
fi
