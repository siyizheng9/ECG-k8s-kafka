#!/bin/bash

if [ $# -eq 0 ]; then
    rsync -ruv ./kafka/*.py debian-pod:/home/zheng/development/kafka
    rsync -ruv ./mqtt/*.py debian-pod:/home/zheng/development/mqtt
elif [ $1 == '-d' ]; then
    echo "running in background"
    fswatch -o . | while read f; do ./rsync.sh; done > /dev/null &
fi
