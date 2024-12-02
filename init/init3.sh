#!/usr/bin/env bash
set +e
set -x

cd /opt
sudo wget -r -p -e robots=off -U mozilla http://10.217.35.1/node_exporter-1.8.1.linux-amd64.tar.gz
cd 10.217.35.1/
sudo tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64/
sudo ./node_exporter --collector.wifi &
