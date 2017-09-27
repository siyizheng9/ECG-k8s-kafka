# ECG-k8s-kafka

A kafka and mqtt based ECG data collection system, the whole system is dockerized and deployed in a kubernetes cluster.

The ecg data collection process:

android client -> mqtt broker -> mqtt-kafka-connector ->
kafka broker -> mongodb-kafka-connector -> mongodb

This repository is a collection of shell scipts for setting up the whole system.

The setup process includes:

* deploy kubernetes system on three host machines
* deploy kafka cluster on kubernetes
* deploy mqtt broker server and mongodb server
* set up mqtt-kafka-connector and mongodb-kafka-connector
* deploy a flask web server

Building up a kubernetes system on top of three host machines

There is an [ansible project](https://version.aalto.fi/gitlab/zhengs2/ansible-k8s) for automating deployment process.

## Related repository

* [ansible-k8s](https://version.aalto.fi/gitlab/zhengs2/ansible-k8s)
* [MQTT-android-client](https://version.aalto.fi/gitlab/zhengs2/MQTT-android-client)
* [kafka-connect-mqtt](https://version.aalto.fi/gitlab/zhengs2/kafka-connect-mqtt)
* [kafka-connect-mongodb](https://version.aalto.fi/gitlab/zhengs2/kafka-connect-mongodb)
* [ECG-Flask](https://version.aalto.fi/gitlab/zhengs2/ECG-Flask)

## Reference

* [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
* [Kafka on Kubernetes](https://github.com/Yolean/kubernetes-kafka)
* [Eclipse Paho Android Service](https://github.com/eclipse/paho.mqtt.android)
* [Mqtt to Apache Kafka Connect](https://github.com/evokly/kafka-connect-mqtt)
* [Kafka Connect MongoDB](https://github.com/hpgrahsl/kafka-connect-mongodb)