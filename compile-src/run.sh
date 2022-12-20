#!/bin/bash

# 1. Pull Image

# 2. Start up cluster (docker-compose)

for i in {0..2}
do
        echo "export CASSANDRA_HOME=\"/cassandra/apache-cassandra-4.0.7\"" > ./persistent/node_${i}/env.sh
        echo "export CASSANDRA_CONF=\"/etc/apache-cassandra-4.0.7\"" >> ./persistent/node_${i}/env.sh
        echo "export PYTHON=python3" >> ./persistent/node_${i}/env.sh
done

docker-compose up

CQLSH="/cassandra/apache-cassandra-4.0.7/bin/cqlsh"

# Wait for all nodes to upgrade
for i in {0..2}
do
        while true; do
            docker exec cassandra-test_N${i} ${CQLSH} -e "describe cluster"
            if [[ "$?" -eq 0 ]]; then
                break
            fi
            sleep 5
        done
done

# 3. Execute commands
docker exec cassandra-test_N0 ${CQLSH} -e "CREATE KEYSPACE  uuid5f86250110a247d48c481c5579cb2ea1 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };"
docker exec cassandra-test_N0 ${CQLSH} -e "CREATE TABLE  uuid5f86250110a247d48c481c5579cb2ea1.kattmG (kattmG TEXT,VldG TEXT,Ajqm TEXT,lTQSQ INT,EVzlSKrbkUGyhJshH TEXT, PRIMARY KEY (lTQSQ ));"
docker exec cassandra-test_N0 ${CQLSH} -e "DELETE FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG WHERE lTQSQ = 2;"
docker exec cassandra-test_N0 ${CQLSH} -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP kattmG ;"
docker exec cassandra-test_N0 ${CQLSH} -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (Ajqm, EVzlSKrbkUGyhJshH, lTQSQ) VALUES ('nZJzNjYnXOwPLpVoFSVwxcvznsDFBYqmlprrVXYJQLzYvYkrmfEsiuAcCtggypnxIkIevRHyPQGOWrIZNObJ','RaAhbVKUQzgJaupaupKPVnNLLYDaZEaMyFteVwhLePqZwikuBEsVDxTuTqBfkFYmeMMsOFXjVkObZduPfAFsLzuYlrgpYsPPxDNQCRzzPaEdWHARnnWbAFAUUnbYnvEESeHDRHSkEhSnoREprrHWasYLMSocIYiMGQXjzsaKptqbtPgrztIdpQLgDAZOPfhJIblmwTFAWiFbzrbTkFwJGP',1693380861);"
docker exec cassandra-test_N0 ${CQLSH} -e "DELETE FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG WHERE lTQSQ = 1693380861;"
docker exec cassandra-test_N0 ${CQLSH} -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (lTQSQ) VALUES (2);"
docker exec cassandra-test_N0 ${CQLSH} -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP VldG ;"
docker exec cassandra-test_N0 ${CQLSH} -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (lTQSQ) VALUES (1693380861);"
docker exec cassandra-test_N0 ${CQLSH} -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (Ajqm, lTQSQ) VALUES ('ldrsHa',1693380861);"
docker exec cassandra-test_N0 ${CQLSH} -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP Ajqm ;"
# 4. Perform full-stop upgrade

# Node shutdown
for i in {0..2}
do
        docker exec cassandra-test_N${i} /cassandra/apache-cassandra-4.0.7/bin/nodetool drain
        docker exec cassandra-test_N${i} /cassandra/apache-cassandra-4.0.7/bin/nodetool stopdaemon
done

# Upgrade

for i in {0..2}
do
        echo "export CASSANDRA_HOME=\"/cassandra/apache-cassandra-4.1.0\"" > ./persistent/node_${i}/env.sh
        echo "export CASSANDRA_CONF=\"/etc/apache-cassandra-4.1.0\"" >> ./persistent/node_${i}/env.sh
        echo "export PYTHON=python3" >> ./persistent/node_${i}/env.sh
done

# Node restart
CQLSH="/cassandra/apache-cassandra-4.0.7/bin/cqlsh"

for i in {0..2}
do
        docker exec cassandra-test_N${i} /bin/bash -c supervisorctl restart upfuzz_cassandra:
        while true; do
            docker exec cassandra-test_N${i} ${CQLSH} -e "describe cluster"
            if [[ "$?" -eq 0 ]]; then
                break
            fi
            sleep 5
        done
done

read_res = $(docker exec cassandra-test_N0 ${CQLSH} -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP Ajqm ;")
echo $read_res