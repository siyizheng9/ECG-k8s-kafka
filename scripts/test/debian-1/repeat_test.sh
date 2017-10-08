#!/bin/bash

set -x

test(){
# repeat 1 , interval 0
export MQTT_REPEAT_TEST=$1
export MQTT_PUB_TIME_INTERVAL=$2

for i in {1..10}
do
    ./mqtt_test.sh >> r_${MQTT_REPEAT_TEST}_t_${MQTT_PUB_TIME_INTERVAL}.log
done
}

test 1 0
