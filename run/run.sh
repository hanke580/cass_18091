#!/bin/bash

rm res.log

# 1. Pull Image
docker pull hanke580/cassandra-18091:latest

# 2. Start up cluster (docker-compose)
test () {
        echo "hh"

        for i in {0..2}
        do
                echo "export CASSANDRA_HOME=\"/cassandra/apache-cassandra-4.0.7\"" > ./persistent/node_${i}/env.sh
                echo "export CASSANDRA_CONF=\"/etc/apache-cassandra-4.0.7\"" >> ./persistent/node_${i}/env.sh
                echo "export PYTHON=python3" >> ./persistent/node_${i}/env.sh
        done

        docker-compose up &

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
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "CREATE KEYSPACE  uuid5f86250110a247d48c481c5579cb2ea1 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "CREATE TABLE  uuid5f86250110a247d48c481c5579cb2ea1.kattmG (kattmG TEXT,VldG TEXT,Ajqm TEXT,lTQSQ INT,EVzlSKrbkUGyhJshH TEXT, PRIMARY KEY (lTQSQ ));"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "DELETE FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG WHERE lTQSQ = 2;"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP kattmG ;"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (Ajqm, EVzlSKrbkUGyhJshH, lTQSQ) VALUES ('nZJzNjYnXOwPLpVoFSVwxcvznsDFBYqmlprrVXYJQLzYvYkrmfEsiuAcCtggypnxIkIevRHyPQGOWrIZNObJ','RaAhbVKUQzgJaupaupKPVnNLLYDaZEaMyFteVwhLePqZwikuBEsVDxTuTqBfkFYmeMMsOFXjVkObZduPfAFsLzuYlrgpYsPPxDNQCRzzPaEdWHARnnWbAFAUUnbYnvEESeHDRHSkEhSnoREprrHWasYLMSocIYiMGQXjzsaKptqbtPgrztIdpQLgDAZOPfhJIblmwTFAWiFbzrbTkFwJGP',1693380861);"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "DELETE FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG WHERE lTQSQ = 1693380861;"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (lTQSQ) VALUES (2);"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP VldG ;"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (lTQSQ) VALUES (1693380861);"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "INSERT INTO uuid5f86250110a247d48c481c5579cb2ea1.kattmG (Ajqm, lTQSQ) VALUES ('ldrsHa',1693380861);"
        docker exec cassandra-test_N0 ${CQLSH} --request-timeout=40 -e "ALTER TABLE uuid5f86250110a247d48c481c5579cb2ea1.kattmG DROP Ajqm ;"
        

        read_res1=$(docker exec cassandra-test_N0 ${CQLSH} -e "SELECT lTQSQ FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG;")

        
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
        CQLSH="/cassandra/apache-cassandra-4.1.0/bin/cqlsh"

        for i in {0..2}
        do
                docker exec cassandra-test_N${i} /bin/bash -c "supervisorctl restart upfuzz_cassandra:"
                while true; do
                docker exec cassandra-test_N${i} ${CQLSH} -e "describe cluster"
                if [[ "$?" -eq 0 ]]; then
                        break
                fi
                sleep 5
                done
        done

        read_res2=$(docker exec cassandra-test_N0 ${CQLSH} -e "SELECT lTQSQ FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG;")
        
        if [[ $read_res1 == *"2 rows"* && $read_res2 != *"2 rows"* ]]; then
                printf "Inconsistent results, keep the containers"
                printf "old read = \n${read_res1}\n" >> res.log
                printf "new read = \n${read_res2}\n" >> res.log
                printf "\n" >> res.log
                return 10
        fi

        docker rm -f $(docker ps -a -q -f ancestor=hanke580/cassandra-18091)
        docker container prune -f
        docker network prune -f
}


for i in {0..10}
do
        test
        res=$?
        if [[ $res == 10 ]];
        then
                break
        fi
done
