#!/bin/bash

### CONFIG ####
VIVO_URL="http://127.0.0.1:8080/vivo/"
VIVO_ADMIN_USERNAME="[INSERT_HERE]"
VIVO_ADMIN_PASSWORD="[INSERT_HERE]"
PURE_REST_URL="http://127.0.0.1:8080/ws/api/59/"
PURE_API_KEY="[INSERT_HERE]"
VIVO_BASE_URI="http://fis.tu-dresden.de/vivo/"
KARMA_WS_URL="http://127.0.0.1:8080/web-services-rdf/"


### RUN ###
mkdir -p /usr/local/VIVO/data
cd /usr/local/VIVO/data
rm -f pure_new.ttl


# fetch all data
entities=(organisational-units persons research-outputs)
for entity in "${entities[@]}"
do
	curl --request POST --data 'R2rmlURI=file:/usr/local/VIVO/models/'${entity}'.xml-model.ttl&ContentType=XML&DataURL='${PURE_REST_API}${entity}'.xml?apiKey='${PURE_API_KEY}'&size=1000000&BaseURI=${VIVO_BASE_URI}' ${KARMA_WS_URL}rdf/r2rml/rdf >> pure_new.ttl
done

# create diff
[ ! -f "pure_last.ttl" ] && echo "" >> pure_last.ttl
diff --changed-group-format="%>" --unchanged-group-format="" pure_last.ttl pure_new.ttl > vivo_add.ttl

echo "update=DELETE DATA { GRAPH <http://vitro.mannlib.cornell.edu/default/vitro-kb-2> { " > vivo_remove.ttl
diff --changed-group-format="%>" --unchanged-group-format="" pure_new.ttl pure_last.ttl >> vivo_remove.ttl
echo "}}" >> vivo_remove.ttl

awk -F '[\\<\\>]' '{print $2}' vivo_add.ttl | uniq > newURIs.txt



# push updates to vivo
curl -d 'email='${VIVO_ADMIN_USERNAME} -d 'password='${VIVO_ADMIN_PASSWORD} -d 'update=LOAD <file:'$(pwd)'/vivo_add.ttl> into graph <http://vitro.mannlib.cornell.edu/default/vitro-kb-2>' ${VIVO_URL}'api/sparqlUpdate'
curl -d 'email='${VIVO_ADMIN_USERNAME} -d 'password='${VIVO_ADMIN_PASSWORD} -d '@vivo_remove.ttl' ${VIVO_URL}'api/sparqlUpdate'


# initiate index update of new entries
curl --form 'email='${VIVO_ADMIN_USERNAME} --form 'password='${VIVO_ADMIN_PASSWORD} --form 'uris=@newURIs.txt' ${VIVO_URL}'searchService/updateUrisInSearch'


# clean up
mv -f pure_new.ttl pure_last.ttl
rm vivo_add.ttl vivo_remove.ttl newURIs.txt
