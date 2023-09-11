data "aws_autoscaling_group" "autoscaling_group" {
  name = "autoscaling_group"
}

data "aws_autoscaling_group" "autoscaling_group_2" {
  name = "autoscaling_group_2"
  provider = aws.peer
}

variable "main_email" {}

##########################################################################
# SNS Region 1
##########################################################################

resource "aws_sns_topic" "alarm" {
  name              = "alarm-topic"
}

resource "aws_sns_topic_subscription" "alarm-ubscription" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.main_email
}

resource "aws_autoscaling_notification" "scaling_notifications" {
  group_names = [data.aws_autoscaling_group.autoscaling_group.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.alarm.arn
}

##########################################################################
# SNS Region 2
##########################################################################

resource "aws_sns_topic" "alarm2" {
  name              = "alarm-topic"
  provider = aws.peer
}

resource "aws_sns_topic_subscription" "alarm-ubscription2" {
  topic_arn = aws_sns_topic.alarm2.arn
  protocol  = "email"
  endpoint  = var.main_email
  provider = aws.peer
}

resource "aws_autoscaling_notification" "scaling_notifications2" {
  group_names = [data.aws_autoscaling_group.autoscaling_group_2.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.alarm2.arn
  provider = aws.peer
}