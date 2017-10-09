#!/bin/bash

# set -x

test(){
# repeat 1 , interval 0
export MQTT_REPEAT_TEST=$1
export MQTT_PUB_TIME_INTERVAL=$2
export NUMBER_PODS=$3

sed -i "s/parallelism: [0-9]*/parallelism: $NUMBER_PODS/g" publish.yml
sed -i "0,/value: '[0-9.]*'/{s/value: '[0-9.]*'/value: '$MQTT_PUB_TIME_INTERVAL'/}" publish.yml

for i in {1..10}
do
    echo 'Pods:' $NUMBER_PODS ' ' 'Time Interval:' $MQTT_PUB_TIME_INTERVAL ' ' 'Round:' $i
    ./cluste_test.sh >> c_n_${NUMBER_PODS}_r_${MQTT_REPEAT_TEST}_t_${MQTT_PUB_TIME_INTERVAL}.log
done
}

# test 1 0 5

interval_ary="0 0.001 0.0005"
pods_ary="1 3 5 10"

for interval in $interval_ary; do

    for pods in $pods_ary; do

    test 1 $interval $pods

    done

done
