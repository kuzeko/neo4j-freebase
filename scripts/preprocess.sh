#!/bin/bash

mkdir -p data
if [[ ! -f data/freebase-sout.graph ]]; then
    echo "Decompressing graph file"
    tar -xzvf freebase-sout.graph.tar.gz  -C  data/
    rm -i -v freebase-sout.graph.tar.gz
fi

if [[ ! -f data/freebase-nodes-in-out-name.tsv ]]; then
    echo "Decompressing node labels file"
    tar -xzvf freebase-nodes-in-out-name.tsv.tar.gz  -C  data/
    rm -i -v freebase-nodes-in-out-name.tsv.tar.gz
fi

if [[ ! -f data/types.list ]]; then
   echo -n "Extracting types..."
   LANG=en_EN  grep  "[[:space:]]6848$" data/freebase-sout.graph | tr ' ' ',' | tee -a data/isA.csv | cut -f 2 -d',' |  sort -k 1,1  | uniq   > data/types.list
   echo  "  extracted $(wc -l data/types.list |  awk {'print $1'}) types and $(wc -l data/isA.csv |  awk {'print $1'}) type relationships"
   join -t, -1 3 data/isA.csv  <(grep -Fw 6848 data/freebase-labels.tsv | cut -f 1,3,4 | tr '\t' ',') -o 1.1,1.2,2.1,2.2,2.3 > data/types.edges.csv
   rm data/isA.csv
   #48,82698385,6848,/type/object/type,"Type"
   echo ":LONG:START_ID,:LONG:END_ID,labelId:LONG,:TYPE,name" > data/types.edges.header.csv

   echo "Extracting Relationships"
   sed -i 's/,/;/g' data/freebase-labels.tsv
   sed -i 's/\\"//g' data/freebase-labels.tsv
   LANG=en_EN  grep -v "[[:space:]]6848$" data/freebase-sout.graph | sort -k3,3 | tr ' ' ',' > data/other.csv
   join -t, -1 3 data/other.csv  <(grep -Fwv 6848 data/freebase-labels.tsv | cut -f 1,3,4 | tr '\t' ',') -o 1.1,1.2,2.1,2.2,2.3 > data/other.edges.csv
   rm data/other.csv
   #48,82698385,6848,/type/object/type,"Type"
   echo ":LONG:START_ID,:LONG:END_ID,labelId:LONG,:TYPE,name" > data/other.edges.header.csv
fi

if [[ ! -f  data/types.csv ]]; then
   echo "Generating Types and Enities lists"
   echo  "lid:LONG:ID,indegree:INT,outdegree:INT,name" > data/types.csv
   join data/types.list data/freebase-nodes-in-out-name.tsv | grep -Fwv '""' | grep -Fv 'alert(' | tr ' ' ',' | tr -d '\\'  >> data/types.csv
   echo  "lid:LONG:ID,indegree:INT,outdegree:INT,name" > data/entities.csv
   join -v2  data/types.list data/freebase-nodes-in-out-name.tsv  | grep -Fv 'alert(' | sed  -r 's/\\+"$/"/g'  | tr ' ' ',' >> data/entities.csv
fi

mkdir -p dbms
