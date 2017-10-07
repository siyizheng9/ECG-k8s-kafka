#!/bin/bash

export PYTHONPATH=/home/zheng/.local/lib/python3.5/site-packages/

cd /home/zheng/development

echo -n 'kafka partition latest offset:'
python3 consumer.py|grep -o '[0-9]*}'|grep -o '[0-9]*'