#!/bin/bash

# set -x

# export MQTT_REPEAT_TEST=1
# export MQTT_PUB_TIME_INTERVAL=0


# ./check_kafka_db.sh

# start mqtt-subsribe
# cd python
# python3 ./python/mqtt-subscribe.py > ./sub.log &

get_average(){

ary=("$@")
sum=0
count=0

for i in "${ary[@]}";do
sum=$( echo "scale = 2; $sum+$i" | bc)
count=$(( count+1 ))
done

echo "scale = 2; $sum/$count" | bc

}

check_broker_repeat(){

SLEEP=$1
result=1
result2=2

while true
do
    if [[ "$result" == "$result2" ]]; then
        echo $result
        break
    else
        result=$(tail -n1 ./broker.log)
        sleep $SLEEP
        result2=$(tail -n1 ./broker.log)
    fi

done

}


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
        sleep 8
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

origin_broker=$(check_broker_repeat 0 | grep -o '[0-9]*' )
origin_sub=$(check_sub_repeat | grep -o '[0-9]*')
origin_kafka=$(check_kafka_repeat | awk -F  ":" '{print $2}')
origin_db=$(check_db_repeat | awk -F  ":" '{print $2}')

echo 'start_______'
# start mqtt publisher pod
kubectl delete -f ./publish.yml
kubectl create -f ./publish.yml

result_sub=$(check_sub_repeat | grep -o '[0-9]*')
result_kafka=$(check_kafka_repeat | awk -F  ":" '{print $2}')
result_db=$(check_db_repeat | awk -F  ":" '{print $2}')
result_broker=$(check_broker_repeat 10 | grep -o '[0-9]*' )

echo 'msg recived by subscriber:' $((result_sub - origin_sub))
echo 'kafka offset added:' $((result_kafka - origin_kafka))
echo 'mongoDB docs added:' $((result_db - origin_db))
echo 'broker msg received:' $((result_broker - origin_broker))

pods=$(kubectl get pods -a|grep -o 'mqtt-publish[a-z0-9-]*')
msg_ary=''
time_ary=''
for item in $pods; do
    msg=$(kubectl logs $item|grep 'message'|grep -o '[0-9]*')
    e_time=$(kubectl logs $item|grep 'time'|grep -o '[0-9.]*')
    msg_ary="$msg_ary $msg"
    time_ary="$time_ary $e_time"
done

echo 'msg sent:' $msg_ary
echo 'time elapsed:' $time_ary

msg_ary=($msg_ary)
time_ary=($time_ary)
echo 'average msg sent:' $( get_average "${msg_ary[@]}" )
echo 'average time elapsed:' $( get_average "${time_ary[@]}" )

echo 'end_______'

 
