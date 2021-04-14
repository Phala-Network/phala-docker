#!/bin/bash

NODE_NAME=${NODE_NAME:-"phala-node"}

echo "Starting Phala Validator with extra opts '${EXTRA_OPTS}'"

./phala-node \
  --chain "phala" \
  --base-path "$HOME/data" \
  --database paritydb-experimental \
  --name $NODE_NAME \
  --validator \
  --rpc-port 9933 \
  --ws-port 9944 \
  $EXTRA_OPTS
