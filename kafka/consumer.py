#!/bin/env python3

from kafka import KafkaConsumer
from kafka import TopicPartition


def test():
    topics = ['test-basic-with-kafkacat', 'test']
    server = 'kafka-0.broker.kafka.svc.cluster.local'

    consumer = KafkaConsumer(bootstrap_servers=server)

    topic = topics[1]
    p = consumer.partitions_for_topic(topic)
    print('partitions for topic %s: %s' % (topic, p))

    available_topics = consumer.topics()
    print("topics:%s" % (available_topics))

    partition = TopicPartition('test', 0)
    print(type(partition))
    consumer.assign([partition])
    consumer.seek(partition, 100)

    for msg in consumer:
        print("partition:%s offset:%s value:%s" %
              (msg.partition, msg.offset, msg.value))


if __name__ == '__main__':
    test()
