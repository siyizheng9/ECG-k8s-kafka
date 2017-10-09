#!/bin/bash
# set -x

gather(){

LOG_FILE=$1

repeat_count=$(grep -m 1 'REPEAT' $LOG_FILE|grep -o '[0-9.]*')
time_interval=$(grep -m 1 'INTERVAL' $LOG_FILE|grep -o '[0-9.]*')
elapsed_time=$(grep 'time' $LOG_FILE|grep -o '[0-9.]*'| tr '\n' ' ')
message_sent=$(grep 'message' $LOG_FILE|grep -o '[0-9.]*'| tr '\n' ' ')
subscribe_received=$(grep 'subscriber' $LOG_FILE|grep -o '[0-9.]*'| tr '\n' ' ')
kafka_offset=$(grep 'kafka' $LOG_FILE|grep -o '[0-9]*'| tr '\n' ' ')
mongo_docs=$(grep 'mongo' $LOG_FILE|grep -o '[0-9]*'| tr '\n' ' ')
broker_received=$(grep 'broker' $LOG_FILE| grep -o '[0-9]*'| tr '\n' ' ')

elapsed_time=($elapsed_time)
message_sent=($message_sent)
subscribe_received=($subscribe_received)
kafka_offset=($kafka_offset)
mongo_docs=($mongo_docs)
broker_received=($broker_received)

echo 'log file:' $LOG_FILE
echo 'Repeat:' $repeat_count 'Interval': $time_interval
echo 'Time' 'Message_sent' 'broker_received' 'sub_received' 'kafka_offset' 'mongo_docs'

for index in "${!mongo_docs[@]}"
do
    echo -n "${elapsed_time[$index]} "
    echo -n "${message_sent[$index]} "
    echo -n "${broker_received[$index]} "
    echo -n "${subscribe_received[$index]} "
    echo -n "${kafka_offset[$index]} "
    echo -n "${mongo_docs[$index]} "
    echo ' '
done

echo -n $( get_average "${elapsed_time[@]}" ) ' ' 
echo -n $( get_average "${message_sent[@]}" ) ' '
echo -n $( get_average "${broker_received[@]}" ) ' '
echo -n $( get_average "${subscribe_received[@]}" ) ' '
echo -n $( get_average "${kafka_offset[@]}" ) ' '
echo $( get_average "${mongo_docs[@]}" ) '<-average'

echo ' '
}

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

log_files=$(ls *log|grep -o '\br_.*.log')

for file in $log_files
do
    echo 'log file:' $file
    gather $file >> gather.log
done


