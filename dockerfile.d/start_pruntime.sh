#!/usr/bin/env bash

echo "Starting pRuntime with extra opts '${EXTRA_OPTS}'"

GRAMINE_BIN=${GRAMINE_BIN:-"/usr/bin/gramine-sgx"}

WORK_DIR=$(dirname $(readlink -f "$0"))
DATA_DIR=${DATA_DIR:-"${WORK_DIR}/data"}

echo "Work dir '${WORK_DIR}'"
echo "Data dir '${DATA_DIR}'"

mkdir -p "${DATA_DIR}/protected_files"
mkdir -p "${DATA_DIR}/storage_files"

if [ "$SGX_MODE" == "SW" ]
then
  echo "PRuntime will running in software mode"
else
  echo "PRuntime will running in hardware mode"
  
  /bin/mkdir -p /var/run/aesmd/
  /bin/chown -R aesmd:aesmd /var/run/aesmd/
  /bin/chmod 0755 /var/run/aesmd/
  /bin/chown -R aesmd:aesmd /var/opt/aesmd/
  /bin/chmod 0750 /var/opt/aesmd/

  LD_LIBRARY_PATH=/opt/intel/sgx-aesm-service/aesm /opt/intel/sgx-aesm-service/aesm/aesm_service --no-daemon &
  
  SLEEP_BEFORE_START=${SLEEP_BEFORE_START:-"0"}
  if [ ! "${SLEEP_BEFORE_START}" == "0" ]
  then
    echo "Waiting for device. Sleep ${SLEEP_BEFORE_START}s"

    sleep "${SLEEP_BEFORE_START}"
  fi
fi

echo "pRuntime starting... It may take up to 2 minutes."

if [ "$SGX_MODE" == "SW" ]
then
  $WORK_DIR/pruntime --allow-cors $EXTRA_OPTS
else
  $GRAMINE_BIN $WORK_DIR/pruntime --allow-cors $EXTRA_OPTS
fi
