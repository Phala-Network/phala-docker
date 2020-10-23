#!/usr/bin/env bash

echo "Starting PHost with extra opts '${EXTRA_OPTS}'"

./phost \
  --pruntime-endpoint "$PRUNTIME_ENDPOINT" \
  --substrate-ws-endpoint "$PHALA_NODE_WS_ENDPOINT" \
  --mnemonic "$MNEMONIC" \
  $EXTRA_OPTS
