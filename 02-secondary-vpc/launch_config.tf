data "aws_iam_instance_profile" "apache-main-profile" {
  name = "apache-main-profile"
}

##########################################################################
# Launch Template for Secondary VPC - Autoscaling
##########################################################################

resource "aws_launch_template" "launch_template_2" {
  name_prefix               = "apache-public-"
  image_id                  = "ami-0f1ee917b10382dea"
  instance_type             = "t2.micro"
  key_name                  = "k-priv"
  vpc_security_group_ids    = [aws_security_group.load_balancer_sg_2.id]
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

resource "aws_autoscaling_group" "autoscaling_group_2" {
  name                      = "autoscaling_group_2"
  launch_template {
    id      = aws_launch_template.launch_template_2.id
  }
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.secondary_vpc-subnet_1.id,aws_subnet.secondary_vpc-subnet_2.id]
  target_group_arns         = [aws_lb_target_group.lb_target_group_2.arn]
}

resource "aws_autoscaling_policy" "scale_policy_2" {
  name                   = "scale_policy_2"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group_2.name

  target_tracking_configuration {
    target_value           = 80.0
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"   
    }
  }
}