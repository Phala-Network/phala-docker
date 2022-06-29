#!/usr/bin/env bash

set -e

GRAMINE_SGX_BIN=${GRAMINE_BIN:-"/usr/bin/gramine-sgx"}
GRAMINE_SGX_GET_TOKEN_BIN=${GRAMINE_SGX_GET_TOKEN_BIN:-"/usr/bin/gramine-sgx-get-token"}

if [ "$SGX" -eq 1 ]; then
  echo "Starting AESMD"

  /bin/mkdir -p /var/run/aesmd/
  /bin/chown -R aesmd:aesmd /var/run/aesmd/
  /bin/chmod 0755 /var/run/aesmd/
  /bin/chown -R aesmd:aesmd /var/opt/aesmd/
  /bin/chmod 0750 /var/opt/aesmd/

  LD_LIBRARY_PATH=/opt/intel/sgx-aesm-service/aesm /opt/intel/sgx-aesm-service/aesm/aesm_service --no-daemon &

  if [ ! "${SLEEP_BEFORE_START:=0}" -eq 0 ]
  then
    echo "Waiting for device. Sleep ${SLEEP_BEFORE_START}s"

    sleep "${SLEEP_BEFORE_START}"
  fi
fi

WORK_DIR=$(dirname $(readlink -f "$0"))
DATA_DIR=${DATA_DIR:-"${WORK_DIR}/data"}

echo "Work dir '${WORK_DIR}'"
echo "Data dir '${DATA_DIR}'"

mkdir -p "${DATA_DIR}/protected_files"
mkdir -p "${DATA_DIR}/storage_files"

echo "Starting PRuntime with extra opts '${EXTRA_OPTS}'"

if [ "$SGX" -eq 0 ]; then
  echo "PRuntime will running in software mode"

  cd $WORK_DIR && $WORK_DIR/pruntime --allow-cors $EXTRA_OPTS
else
  if [[ ! -f "$WORK_DIR/pruntime.token" ]]; then
    echo "Generating token"
    $GRAMINE_SGX_GET_TOKEN_BIN --sig "$WORK_DIR/pruntime.sig" --output "$WORK_DIR/pruntime.token"
  fi

  echo "PRuntime will running in hardware mode"

  cd $WORK_DIR && $GRAMINE_SGX_BIN $WORK_DIR/pruntime --allow-cors $EXTRA_OPTS
fi
