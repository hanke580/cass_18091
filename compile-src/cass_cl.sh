#!/bin/bash

pgrep -f config.json | xargs sudo kill -9
docker rm -f $(docker ps -a -q -f ancestor=upfuzz_cassandra:test)

docker network prune -f
docker container prune -f
