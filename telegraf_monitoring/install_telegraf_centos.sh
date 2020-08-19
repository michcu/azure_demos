#!/bin/bash

# Add repo and install telegraf
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

sudo yum -y install telegraf

# Create config and change settings to have proc input and Azure output
telegraf --input-filter procstat --output-filter azure_monitor config > proc-telegraf.conf
  
# Set config to capture all pids
sed -i 's/pid_file/#pid_file/' proc-telegraf.conf
sed -i 's/# pattern = "nginx"/pattern = ".*"/' proc-telegraf.conf

# Replace updated config and restart the service
sudo cp proc-telegraf.conf /etc/telegraf/telegraf.conf
  
sudo systemctl start telegraf