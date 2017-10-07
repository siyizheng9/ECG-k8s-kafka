#!/bin/bash

# kubectl delete -f .
# kubectl create -f .
check_kafka_offset(){
# check kafka offset
# in debian-pod: python3 consumer.py
kubectl exec debian -- /home/zheng/development/latest_kafka_offset.sh
}


check_db(){
# check mongodb document count
# in mongod pod: db.kafkatopic.find().count({_id:-1})
echo -n 'mongoDB docs count:'
kubectl exec mongo-deployment-1281015340-k22ld --  mongo kafkaconnect --eval 'db.kafkatopic.find().count()'|tail -n1
}

check_kafka_offset
check_db
