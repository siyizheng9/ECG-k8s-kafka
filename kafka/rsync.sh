#!/bin/bash

# fswatch -o . | while read f; do ./rsync.sh; done > /dev/null &
rsync -ruv *.py debian-pod:/home/zheng/development/kafka