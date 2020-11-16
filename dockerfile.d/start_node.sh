#!/bin/bash

NODE_NAME=${NODE_NAME:-"phala-node"}

echo "Starting PhalaNode with extra extra opts '${EXTRA_OPTS}'"

./phala-node \
  --chain "phala" \
  --base-path "$HOME/data" \
  --database paritydb \
  --name $NODE_NAME \
  --pruning archive \
  --rpc-port 9933 \
  --ws-port 9944 \
  --ws-external \
  --rpc-external \
  --rpc-cors all \
  $EXTRA_OPTS
