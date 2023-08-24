#!/bin/bash

HOME=$(pwd)

HOUR=$(( $RANDOM % 6 + 3 ))
MINUTE=$(( $RANDOM % 59 + 1 ))

echo "$MINUTE $HOUR * * * /usr/bin/bash $HOME/remote-backup/rsync-hetzner.sh &>/dev/null"
