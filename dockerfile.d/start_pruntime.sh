#!/usr/bin/env bash

STATE_FILE_PATH=${STATE_FILE_PATH:-"data"}

if [ "$SGX_MODE" == "SW" ]
then
  echo "PRuntime will running in software mode"

  source /opt/intel/sgxsdk/environment
else
  echo "PRuntime will running in hardware mode"
  
  LD_LIBRARY_PATH=/opt/intel/sgx-aesm-service/aesm /opt/intel/sgx-aesm-service/aesm/aesm_service &
fi

mkdir -p "$STATE_FILE_PATH"
STATE_FILE_PATH="$STATE_FILE_PATH" ./app