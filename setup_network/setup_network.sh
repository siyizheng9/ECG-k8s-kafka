#!/bin/bash

sudo ip route add 10.200.1.0/24 via 10.0.2.13
sudo ip route add 10.200.0.0/24 via 10.0.2.12