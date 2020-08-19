#!/bin/bash

# Add repo and install telegraf
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install telegraf

# Create config and change settings to have proc input and Azure output
telegraf --input-filter procstat --output-filter azure_monitor config > proc-telegraf.conf

# Set config to capture all pids
sed -i 's/pid_file/#pid_file/' proc-telegraf.conf
sed -i 's/# pattern = "nginx"/pattern = ".*"/' proc-telegraf.conf

# Replace updated config and restart the service
sudo cp proc-telegraf.conf /etc/telegraf/telegraf.conf

sudo systemctl stop telegraf
sudo systemctl start telegraf