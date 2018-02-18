#! /bin/bash

SD=$1
PARTITION_MODE=$2

source ../config/echo_config || exit 1
source ../config/env_config || exit 1

source $SCRIPT_DIR/$SUBDIR/umount || exit 1

exit 0
