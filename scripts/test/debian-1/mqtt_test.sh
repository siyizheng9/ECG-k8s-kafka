#!/bin/bash

# kubectl delete -f .
# kubectl create -f .

./check_kafka_db.sh

# start mqtt-publisher
echo 'start_______'

cd python
python3 mqtt-publish.py

echo 'end_______'