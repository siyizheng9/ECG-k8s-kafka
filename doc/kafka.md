# Kafka

## Notes

## [Kafka protocol guide](https://kafka.apache.org/protocol)

Kafka is a partitioned system so not all servers have the complete data set. Instead recall that topics are split into a pre-defined number of partitions, P, and each partition is replicated with some replication factor, N.

All systems of this nature have the question of how a particular piece of data is assigned to a particular partition. Kafka clients directly control this assignment, the brokers themselves enforce no particular semantics of which messages should be published to a particular partition.

[partitioning](https://kafka.apache.org/protocol#protocol_partitioning)

### Producer

Producers publish data to the topics of their choice. The producer is responsible for choosing which record to assign to which partition within the topic.

[Kafka Getting Started](https://kafka.apache.org/documentation/#intro_producers)

### message ordering

**Note that message ordering for the entire topic is not guaranteed.**
[Kafka in a nutshell](https://sookocheff.com/post/kafka/kafka-in-a-nutshell/)

[How to maintain ordering of message in Kafka?](https://stackoverflow.com/questions/42000679/how-to-maintain-ordering-of-message-in-kafka)

[Apache Kafka order of messages with multiple partitions](https://stackoverflow.com/questions/29820384/apache-kafka-order-of-messages-with-multiple-partitions)

[Indefinite log retention on kafka](https://stackoverflow.com/questions/32818820/indefinite-log-retention-on-kafka)

### setting with value -1

To keep messages indefinitely set options like `log.retention.hours` and `log.retention.bytes` to `-1`

[When does the Apache Kafka client throw a “Batch Expired” exception?](https://stackoverflow.com/questions/34794260/when-does-the-apache-kafka-client-throw-a-batch-expired-exception)

### connection process between producer and broker

The connection between broker and producers seems works on a two-phase manner:

1. the producer connects to the broker through the `host:port` list provided by `--broker-list`
1. the producer retrieves broker metadata in the form of a list of`domain_name`. the consecutive connections will be issued through `domain.name:9092`

On which port the broker is listenning can be configured through `listeners` option in broker config file?

the domain name resolution issue can be solved by addding corresponding records to `/etc/hosts`.

**[Accessing kafka from outside kubernetes](https://groups.google.com/forum/#!topic/kubernetes-users/xuRkkZwvrDU)**

**[How to publish/consume messages from outside of Kubernetes Cluster](https://stackoverflow.com/questions/41868161/kafka-in-kubernetes-cluster-how-to-publish-consume-messages-from-outside-of-kub)**

**[External service for kafka not working](https://github.com/Yolean/kubernetes-kafka/issues/13)**

## Kafka connector REST Interface

[REST Interface](http://docs.confluent.io/3.0.0/connect/userguide.html#rest-interface)

`curl -s localhost:8083/connectors/mqtt/status | jq`
`curl -s localhost:8083/connectors/mqtt/tasks | jq`

## references

[Kafka on Kubernetes](https://github.com/Yolean/kubernetes-kafka)