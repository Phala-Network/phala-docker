#!/usr/bin/env bash

echo "pRuntime starting... It may take up to 2 minutes."

SLEEP_BEFORE_START=${SLEEP_BEFORE_START:-"0"}
if [ ! "$SLEEP_BEFORE_START" == "0" ]
then
  echo "Waiting for device. Sleep ${SLEEP_BEFORE_START}s"

  sleep "$SLEEP_BEFORE_START"
fi

echo "Starting pHost with extra opts '${EXTRA_OPTS}'"

./phost \
  --pruntime-endpoint "$PRUNTIME_ENDPOINT" \
  --substrate-ws-endpoint "$PHALA_NODE_WS_ENDPOINT" \
  --mnemonic "$MNEMONIC" \
  $EXTRA_OPTS
