#!/bin/bash
#HOST='debain-pod'
HOST='r-debian-1'
DEST='~/Development/'

if [ $# -eq 0 ]; then
    rsync -ruv ./kafka/*.py $HOST:$DEST/kafka
    rsync -ruv ./mqtt/ $HOST:$DEST/mqtt/
elif [ $1 == '-d' ]; then
    echo "running in background"
    fswatch -o . | while read f; do ./rsync.sh; done > /dev/null &
fi
