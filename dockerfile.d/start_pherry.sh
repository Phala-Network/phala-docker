#!/usr/bin/env bash

SLEEP_BEFORE_START=${SLEEP_BEFORE_START:-"0"}
if [ ! "$SLEEP_BEFORE_START" == "0" ]
then
  echo "Sleep ${SLEEP_BEFORE_START}s"

  sleep "$SLEEP_BEFORE_START"
fi

echo "Starting Pherry with extra opts '${EXTRA_OPTS}'"

./pherry \
  --pruntime-endpoint "$PRUNTIME_ENDPOINT" \
  --substrate-ws-endpoint "$PHALA_NODE_WS_ENDPOINT" \
  --mnemonic "$MNEMONIC" \
  $EXTRA_OPTS
