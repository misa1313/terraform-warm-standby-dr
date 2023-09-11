provider "aws" {}

data "aws_iam_instance_profile" "apache-main-profile" {
  name = "apache-main-profile"
}

##########################################################################
# Launch Template for Primary VPC - Autoscaling
##########################################################################

resource "aws_launch_template" "launch_template" {
  name_prefix               = "apache-public-"
  image_id                  = "ami-08333bccc35d71140"
  instance_type             = "t2.micro"
  key_name                  = "k-priv"
  vpc_security_group_ids    = [aws_security_group.load_balancer_sg_1.id]
  user_data                 = filebase64("../setup.sh")
  iam_instance_profile {
    name = data.aws_iam_instance_profile.apache-main-profile.name
  }
  metadata_options {
    instance_metadata_tags      = "enabled"
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      environment = "dev"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "autoscaling_group"
  launch_template {
    id      = aws_launch_template.launch_template.id
  }
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.main_vpc-subnet_1.id,aws_subnet.main_vpc-subnet_2.id]
  target_group_arns         = [aws_lb_target_group.lb_target_group_1.arn]
}

resource "aws_autoscaling_policy" "scale_policy_1" {
  name                   = "scale_policy_1"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name

  target_tracking_configuration {
    target_value           = 80.0
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"   
    }
  }
}