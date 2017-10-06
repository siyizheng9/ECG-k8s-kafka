FROM python:3.6-alpine

WORKDIR /usr/src/app

RUN pip install paho-mqtt

COPY . .

ENV MQTT_HOST mqtt-svc
ENV MQTT_PORT 1883
ENV MQTT_SAMPLE_DATA sample_data.csv

CMD [ "python", "mqtt-publish.py" ]