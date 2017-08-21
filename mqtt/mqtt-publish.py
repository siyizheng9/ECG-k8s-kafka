#!/bin/env python3

import paho.mqtt.publish as publish

publish.single("paho/test/simple", "payload", hostname="mqtt-svc")