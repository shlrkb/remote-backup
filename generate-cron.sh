#!/bin/bash

# Generate cronjob

HOUR=$(( $RANDOM % 6 + 3 ))
MINUTE=$(( $RANDOM % 59 + 1 ))

echo "$MINUTE $HOUR * * * /bin/bash $HOME/remote-backup/rsync-hetzner.sh &>/dev/null"
