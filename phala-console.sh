#!/bin/bash

docker-compose run --rm --entrypoint 'node index.js' -- phala-console\
  --pruntime-endpoint=http://phala-pruntime:8000 \
  --substrate-ws-endpoint=ws://phala-node:9944 \
  "$@"
