#!/bin/bash

kubectl -n kafka expose pod zoo-0 --port=2181 --type=NodePort --name=zookeeper-nodeport
kubectl -n kafka expose pod kafka-0 --port=9092 --type=NodePort --name=broker-nodeport

# bin/kafka-topics.sh --create --zookeeper 192.168.1.103:32418 --replication-factor 1 --partitions 1 --topic test
# bin/kafka-topics.sh --list --zookeeper 192.168.1.103:32418

# bin/kafka-console-producer.sh --broker-list 192.168.1.103:32618 --topic test
# bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.103:32618 --topic test --from-beginning

# refer:https://kafka.apache.org/quickstart