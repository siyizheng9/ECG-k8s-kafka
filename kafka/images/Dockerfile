FROM openshine/kafka:0.11.0.0

WORKDIR /opt/kafka

COPY kafka-connect-mqtt-1.0.jar ./libs/
COPY org.eclipse.paho.client.mqttv3-1.0.2.jar ./libs/
COPY mqtt.properties ./config/
COPY connect-standalone.properties ./config/

CMD ["connect-standalone.sh", "config/connect-standalone.properties", "config/mqtt.properties"]

# ./bin/connect-standalone.sh config/connect-standalone.properties config/mqtt.properties
