# Disaster Recovery (DR) on AWS: Warm Standby

Terraform deployment of a web application in multiple regions for DR. This setup includes a launch configuration that runs a script to pull the necessary files from an S3 bucket and execute an ansible playbook. The instances are auto-scalable, and there are always 2 running on the main VPC. The secondary VPC has also running instances in a Warm standby manner. These instances have Load balancers that follow a Failover routing policy (Route53). SNS notifications are configured on auto-scaling events. 

Reference of a similar setup:
![alt text](https://user-images.githubusercontent.com/86983374/267150536-07e84c45-16cf-4280-9fb5-956bc4f6e320.png)
