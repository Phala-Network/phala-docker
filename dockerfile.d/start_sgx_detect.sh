#!/usr/bin/env bash

/bin/mkdir -p /var/run/aesmd/
/bin/chown -R aesmd:aesmd /var/run/aesmd/
/bin/chmod 0755 /var/run/aesmd/
/bin/chown -R aesmd:aesmd /var/opt/aesmd/
/bin/chmod 0750 /var/opt/aesmd/

LD_LIBRARY_PATH=/opt/intel/sgx-aesm-service/aesm /opt/intel/sgx-aesm-service/aesm/aesm_service &

SLEEP_BEFORE_START=${SLEEP_BEFORE_START:-"0"}
if [ ! "$SLEEP_BEFORE_START" == "0" ]
then
  echo "Sleep ${SLEEP_BEFORE_START}s"

  sleep "$SLEEP_BEFORE_START"
fi

./sgx-detect --verbose
./app