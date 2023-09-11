variable "vpn_ip" {}

##########################################################################
# Load balancer 2 - SG
##########################################################################

resource "aws_security_group" "load_balancer_sg_2" {
  name        = "allow_http_2"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.secondary_vpc.vpc_id 

  ingress {
    description      = "SSH from VPN"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.vpn_ip
  }

  ingress {
    description      = "HTTP from LB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from LB"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_2"
  }
}

##########################################################################
# Load balancer 2 - Target group
##########################################################################

resource "aws_lb" "lb_2" {
  name               = "lb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.load_balancer_sg_2.id]
  subnets            = [aws_subnet.secondary_vpc-subnet_1.id,aws_subnet.secondary_vpc-subnet_2.id] 
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "lb_listener_2" {
  load_balancer_arn = aws_lb.lb_2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group_2.arn
  }
}

resource "aws_lb_target_group" "lb_target_group_2" {
  name     = "lbtg-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.secondary_vpc.vpc_id 
}