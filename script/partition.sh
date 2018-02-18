#! /bin/bash

SD=$1
PARTITION_MODE=$2
VIRTUAL_MACHINE="None"

source ../config/echo_config || exit 1
source ../config/env_config || exit 1

echo_start "clean ${SD}"
if ! dd if=/dev/zero of=$SD bs=1MiB count=2; then
    echo_err "clean ${SD}"
    exit 1
fi
echo_finish "clean ${SD}"

source $SCRIPT_DIR/$SUBDIR/partition || exit 1

exit 0
