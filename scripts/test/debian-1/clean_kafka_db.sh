#!/bin/bash


# kafka delete topic
kubectl -n kafka exec kafka-0 -- bin/kafka-topics.sh --zookeeper zookeeper --delete --topic mqtt-test

# kafka create topic
kubectl -n kafka exec kafka-0 -- bin/kafka-topics.sh --create --zookeeper zookeeper --replication-factor 3 --partitions 1 --topic mqtt-test

# mongodb drop collection
kubectl exec mongo-deployment-1281015340-k22ld --  mongo kafkaconnect --eval 'db.kafkatopic.drop()'
