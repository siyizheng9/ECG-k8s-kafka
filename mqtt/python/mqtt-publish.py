#!/bin/env python3

import paho.mqtt.client as mqtt
import time
import csv
from Config import Config


# The callback for when the client recieves a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    # print("Connected with result code " + str(rc))
    pass


client = mqtt.Client()
client.on_connect = on_connect

client.connect(Config.mqtt_server, int(Config.mqtt_port), 60)

client.loop_start()

csvfile = open(Config.path_sample_data, 'r')

datareader = csv.reader(csvfile)

count = 0
start_time = time.time()
for i in range(int(Config.repeat_test)):
    # print('Publishing to topic:', Config.mqtt_topic, 'round:', i+1)
    for data in datareader:
        msg = data[0] + ',' + data[1]
        client.publish(Config.mqtt_topic, msg)
        # print(msg)
        count += 1
        time.sleep(float(Config.time_interval))
    csvfile.seek(0)

elapsed_time = time.time() - start_time
csvfile.close()

print('MQTT_PUB_TIME_INTERVAL:%s' % Config.time_interval,
      'MQTT_REPEAT_TEST:%s' % Config.repeat_test, sep='\n')
print('count of message sent:', count)
print('elapsed time:', elapsed_time)
