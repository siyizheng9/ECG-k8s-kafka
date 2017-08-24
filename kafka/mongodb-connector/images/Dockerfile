FROM openshine/kafka:0.11.0.0

WORKDIR /opt/kafka

COPY kafka-connect-mongodb-1.0-SNAPSHOT-jar-with-dependencies.jar ./libs/

RUN mkdir ./config/mongodb
COPY MongoDbSinkConnector.properties ./config/mongodb
COPY connect-standalone.properties ./config/mongodb

CMD ["connect-standalone.sh", "config/mongodb/connect-standalone.properties", "config/mongodb/MongoDbSinkConnector.properties"]

# ./bin/connect-standalone.sh config/connect-standalone.properties config/mqtt.properties
