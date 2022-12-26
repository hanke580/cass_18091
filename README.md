# Script to reproduce [CASSANDRA-18091](https://issues.apache.org/jira/browse/CASSANDRA-18091)


## Prerequisite
Install docker, docker compose


## Run the script
```bash
cd run.sh
./run.sh
```

This script will keep performing full-stop upgrade from Cassandra-4.0.7 to Cassandra-4.1.0 until CASSANDRA-18091 is triggered. Usually it can be triggered within 10 times, so I set the max limit to 10.

It will stop when the bug is triggered and show the logs below.
```bash
Cluster: dev_cluster
Partitioner: Murmur3Partitioner
Snitch: DynamicEndpointSnitch

Inconsistent results, keep the containers.
```

The inconsistency results are stored in `run/res.log`
```cqlsh
old read = 

 ltqsq
------------
 1693380861
          2

(2 rows)
new read = 

 ltqsq
-------

(0 rows)
```

The containers will be kept, and you can enter the docker container to check the results.

```bash
docker ps
docker exec -it --privileged $CONTAINERID /bin/bash
source /usr/bin/set_env
/cassandra/apache-cassandra-4.1.0/bin/cqlsh
# perform read
cqlsh> SELECT lTQSQ FROM uuid5f86250110a247d48c481c5579cb2ea1.kattmG;

 ltqsq
-------

(0 rows)
```
