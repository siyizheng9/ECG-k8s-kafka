#!/bin/env python3

import paho.mqtt.subscribe as subscribe

msg = subscribe.simple("paho/test/simple", hostname="mqtt-svc")
print("%s %s" % (msg.topic, msg.payload))
