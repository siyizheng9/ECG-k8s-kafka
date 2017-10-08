#!/bin/bash

# set -x

# export MQTT_REPEAT_TEST=1
# export MQTT_PUB_TIME_INTERVAL=0


# ./check_kafka_db.sh

# start mqtt-subsribe
# cd python
# python3 ./python/mqtt-subscribe.py > ./sub.log &

check_sub_repeat(){

result=1
result2=2

while true
do
    if [[ "$result" == "$result2" ]]; then
        echo $result
        break
    else
        result=$(tail -n1 ./sub.log)
        sleep 3
        result2=$(tail -n1 ./sub.log)
    fi

done

}

check_kafka_repeat(){

result=1
result2=2

while true
do
    if [[ "$result" == "$result2" ]]; then
        echo $result
        break
    else
        result=$(./check_kafka_db.sh|awk 'NR==1 {print}')
        sleep 3
        result2=$(./check_kafka_db.sh|awk 'NR==1 {print}')
    fi

done

}

check_db_repeat(){

result=1
result2=2

while true
do
    if [[ "$result" == "$result2" ]]; then
        echo $result
        break
    else
        result=$(./check_kafka_db.sh|awk 'NR==2 {print}')
        sleep 3
        result2=$(./check_kafka_db.sh|awk 'NR==2 {print}')
    fi

done

}

origin_sub=$(check_sub_repeat | grep -o '[0-9]*')
origin_kafka=$(check_kafka_repeat | awk -F  ":" '{print $2}')
origin_db=$(check_db_repeat | awk -F  ":" '{print $2}')

echo 'start_______'
# start mqtt-publisher
(
cd python
python3 mqtt-publish.py
)

result_sub=$(check_sub_repeat | grep -o '[0-9]*')
result_kafka=$(check_kafka_repeat | awk -F  ":" '{print $2}')
result_db=$(check_db_repeat | awk -F  ":" '{print $2}')

echo 'msg recived by subscriber:' $((result_sub - origin_sub))
echo 'kafka offset added:' $((result_kafka - origin_kafka))
echo 'mongoDB docs added:' $((result_db - origin_db))

echo 'end_______'
