FROM openshine/kafka:0.11.0.0

WORKDIR /opt/kafka

COPY kafka-connect-mqtt-1.0.jar ./libs/
COPY org.eclipse.paho.client.mqttv3-1.0.2.jar ./libs/

RUN mkdir ./config/mqtt
COPY mqtt.properties ./config/mqtt
COPY connect-standalone.properties ./config/mqtt

CMD ["connect-standalone.sh", "config/mqtt/connect-standalone.properties", "config/mqtt/mqtt.properties"]

# ./bin/connect-standalone.sh config/connect-standalone.properties config/mqtt.properties
