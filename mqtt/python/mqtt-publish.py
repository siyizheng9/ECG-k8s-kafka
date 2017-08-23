#!/bin/env python3

import paho.mqtt.client as mqtt
import time


def read_msg():
    return "message"
    pass


# The callback for when the client recieves a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))


client = mqtt.Client()
client.on_connect = on_connect

client.connect("mqtt-svc", 1883, 60)

client.loop_start()

n = 1
while True:
    n += 1
    msg = read_msg()
    client.publish("paho/test/simple", msg + str(n))
    time.sleep(2)
