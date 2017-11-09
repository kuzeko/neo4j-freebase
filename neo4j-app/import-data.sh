
bin/neo4j-admin import --mode=csv --database=graph.db  --report-file=/dbms/import-log.log --id-type=string \
                 --nodes:Entity="/data/entities.csv" \
                 --nodes:Type="/data/types.csv" \
                 --ignore-missing-nodes=true \
                 --relationships="/data/other.edges.header.csv,/data/other.edges.csv" \
                 --relationships="/data/types.edges.header.csv,/data/types.edges.csv"


if [ -f /var/lib/neo4j/graph.db/bad.log ]; then
   mv -v /var/lib/neo4j/graph.db/bad.log /dbms/graph.db_bad.log
fi

chmod -R 777 /dbms
