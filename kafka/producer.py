#!/bin/env python3

from kafka import KafkaProducer

topic = 'test'
server = 'kafka-0.broker.kafka.svc.cluster.local'

producer = KafkaProducer(bootstrap_servers=server)

for n in range(100):
    metadata = producer.send(topic, bytes(n))
