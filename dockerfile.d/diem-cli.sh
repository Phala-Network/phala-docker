#!/bin/bash

HOST=${HOST:-127.0.0.1}
PORT=${PORT:-8080}
BASE_DIR=${BASE_DIR:-/var/diem-data}

/root/cli \
    -c TESTING \
    -m "${BASE_DIR}/mint.key" \
    -u "http://${HOST}:${PORT}" \
    --waypoint $(cat "${BASE_DIR}/waypoint.txt")
