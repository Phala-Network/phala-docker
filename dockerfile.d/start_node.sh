#!/bin/bash

NODE_NAME="${NODE_NAME:-"phala-node"}"
NODE_ROLE="${NODE_ROLE:-"FULL"}"

case ${NODE_ROLE} in
  "LIGHT")
    NODE_ROLE_ARGS=""
    ;;
  "FULL")
    NODE_ROLE_ARGS="--pruning archive --rpc-methods Unsafe"
    ;;
  "VALIDATOR")
    NODE_ROLE_ARGS="--validator --rpc-methods Unsafe"
    ;;
  *)
    echo "Unknown NODE_ROLE ${NODE_ROLE}"
    echo "accept values: LIGHT | FULL | VALIDATOR"
    exit 1
    ;;
esac

echo "Starting PhalaNode as role '${NODE_ROLE}' with extra opts '${EXTRA_OPTS}'"

./phala-node \
  --chain "phala" \
  --base-path "$HOME/data" \
  --name $NODE_NAME \
  --rpc-port 9933 \
  --ws-port 9944 \
  --ws-external \
  --prometheus-external \
  --rpc-external \
  --rpc-cors all \
  $NODE_ROLE_ARGS \
  $EXTRA_OPTS
