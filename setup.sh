#!/bin/bash

sudo dnf upgrade --releasever=2023.1.20230809 -y
sudo dnf install python3-pip -y
sudo pip3 install ansible
aws s3 cp s3://apache-bucket-07/setup-play.yaml /home/ec2-user/setup-play.yaml
aws s3 cp s3://apache-bucket-07/index.html /home/ec2-user/index.html
aws s3 cp s3://apache-bucket-07/config.json /home/ec2-user/config.json

sudo rpm -i https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ec2-user/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
sudo systemctl enable amazon-cloudwatch-agent

sudo ansible-playbook /home/ec2-user/setup-play.yaml