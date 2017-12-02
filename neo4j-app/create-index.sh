USE_PWD=''
if [[ "${NEO4J_AUTH:-}" == neo4j/* ]]; then
  USE_PWD="-p ${NEO4J_AUTH#neo4j/}"
fi

bin/neo4j start

end="$((SECONDS+60*15))"
while true; do
    [[ "200" = "$(curl --silent --write-out %{http_code} --output /dev/null http://localhost:7474)" ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] &&  echo "Timeout!!" && exit 1
    sleep 3
done

echo "Database is ready"

echo "Building indexes..."
cat /index.cql  | bin/cypher-shell -u neo4j ${USE_PWD} --format plain

RET=$?

if [ $RET -eq 0 ]; then
   echo "Indexes Done"
else
   echo "Error!"
fi



bin/neo4j stop

exit $RET

#./bin/neo4j-shell -path /dbms/databases/ -c < /index.cql && echo "Indexes Done" 
