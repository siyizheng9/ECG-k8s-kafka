#!/bin/env python3

import paho.mqtt.client as mqtt
import time
import csv
from Config import Config


# The callback for when the client recieves a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))


client = mqtt.Client()
client.on_connect = on_connect

client.connect(Config.mqtt_server, Config.mqtt_port, 60)

client.loop_start()

csvfile = open(Config.path_sample_data, 'r')

datareader = csv.reader(csvfile)

for i in range(Config.repeat_test):
    print('Publishing to topic:', Config.mqtt_topic, 'round:', i)
    for data in datareader:
        msg = data[0] + ',' + data[1]
        client.publish(Config.mqtt_topic, msg)
        print(msg)
        time.sleep(Config.time_interval)
    csvfile.seek(0)

csvfile.close()
