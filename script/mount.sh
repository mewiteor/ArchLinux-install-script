#! /bin/bash

SD=$1
PARTITION_MODE=$2

source ../config/echo_config || exit 1
source ../config/env_config || exit 1

if ! ./umount.sh $SD $PARTITION_MODE; then
    echo_err "umount"
    exit 1
fi

source $SCRIPT_DIR/$SUBDIR/mount || exit 1

exit 0
