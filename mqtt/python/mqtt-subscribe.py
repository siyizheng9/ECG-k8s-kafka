#!/bin/env python3

import paho.mqtt.client as mqtt


def kafka_produce(msg):
    print("kafka_produce msg: " + msg)
    pass


# The callback for when the client recieves a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscritions will be renewed.
    client.subscribe("paho/test/simple")


# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic + " " + str(msg.payload))
    kafka_produce(str(msg.payload))


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("mqtt-svc", 1883, 60)

# Blocking call that processes network traffic, dispactches callbacks and
# handles reconnecting.
# Other loop*() functions are available that given a threaded interface and a
# manaual interface.
client.loop_forever()
