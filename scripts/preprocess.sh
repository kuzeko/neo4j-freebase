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

if [[ ! -f data/freebase-nodes-scores.tsv ]]; then
    echo "Decompressing node scores file"
    tar -xzvf freebase-nodes-scores.tsv.tar.gz  -C  data/
    echo "Sortin node scores file"
    LANG=en_EN sort -k1,1 freebase-nodes-scores.tsv > freebase-nodes-scores.sort.tsv
    mv freebase-nodes-scores.sort.tsv freebase-nodes-scores.tsv
    rm -i -v freebase-nodes-scores.tsv.tar.gz
fi



if [[ ! -f data/types.list ]]; then
   echo -n "Extracting types..."
   LANG=en_EN  grep  "[[:space:]]6848$" data/freebase-sout.graph | tr ' ' ',' | tee -a data/isA.csv | cut -f 2 -d',' |  sort -k 1,1  | uniq   > data/types.list
   echo  "  extracted $(wc -l data/types.list |  awk {'print $1'}) types and $(wc -l data/isA.csv |  awk {'print $1'}) type relationships"
   join -t, -1 3 data/isA.csv  <(grep -Fw 6848 data/freebase-labels.tsv | cut -f 1,3,4 | tr '\t' ',') -o 1.1,1.2,2.1,2.2,2.3 > data/types.edges.csv
   rm data/isA.csv
   #48,82698385,6848,/type/object/type,"Type"
   echo ":START_ID,:END_ID,labelId:LONG,:TYPE,name" > data/types.edges.header.csv

   echo "Extracting Relationships"
   sed -i 's/,/;/g' data/freebase-labels.tsv
   sed -i 's/\\"//g' data/freebase-labels.tsv
   LANG=en_EN  grep -v "[[:space:]]6848$" data/freebase-sout.graph | sort -k3,3 | tr ' ' ',' > data/other.csv
   join -t, -1 3 data/other.csv  <(grep -Fwv 6848 data/freebase-labels.tsv | cut -f 1,3,4 | tr '\t' ',') -o 1.1,1.2,2.1,2.2,2.3 > data/other.edges.csv
   rm data/other.csv
   #48,82698385,6848,/type/object/type,"Type"
   echo ":START_ID,:END_ID,labelId:LONG,:TYPE,name" > data/other.edges.header.csv

   echo "Formatting Relationship types"
   echo "labelId:ID,frequency:INT,code,name,domain,subj,obj" > data/edge-labels.header.csv
   grep -Fvw 6848 data/freebase-labels.tsv | awk '{ split($0, quoted, "\"");split($3,tokens,"/"); $4 = quoted[2]} { print $1 "," $2 "," $3 "," "\"" $4  "\"" "," tokens[2] "," tokens[3] "," tokens[4] }' > data/edge-labels.csv

fi

if [[ ! -f  data/types.csv ]]; then
   echo "Generating Types and Enities lists"
   echo  "lid:ID,indegree:INT,outdegree:INT,name" > data/types.header.csv
   # Remove some nasty XSS tests
   LANG=en_EN join data/types.list data/freebase-nodes-in-out-name.tsv | grep -Fwv '""' | grep -Fv 'alert(' | tr -d '\\' | awk '{ split($0, quoted, "\""); $4 = quoted[2]} { print $1 "," $2 "," $3 "," "\"" $4  "\"" }'   | sort -k1,1 -t, > data/types.csv
   echo  "lid:ID,indegree:INT,outdegree:INT,name,score:FLOAT" > data/entities.header.csv
   # Remove some nasty XSS tests
   LANG=en_EN join -v2  data/types.list data/freebase-nodes-in-out-name.tsv  | grep -Fv 'alert(' | sed  -r 's/\\+"$/"/g'  | awk '{ split($0, quoted, "\""); $4 = quoted[2]} { print $1 "," $2 "," $3 "," "\"" $4  "\"" }'  | sort -k1,1 -t, > data/entities.temp.csv
   LANG=en_EN join -t, -a1 -e "" data/entities.temp.csv <( cat data/freebase-nodes-scores.tsv | tr '\t' ',' | sort -k1,1 -t, ) > data/entities.csv
   rm data/entities.temp.csv

fi

ls -l data/*

echo "Complete! You can now start importing..."

mkdir -p dbms
