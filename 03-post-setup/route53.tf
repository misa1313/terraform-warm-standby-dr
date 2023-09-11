variable "domain" {}
variable "subdomain" {}

data "aws_lb" "lb_1" {
  name = "lb-1"
}

data "aws_lb" "lb_2" {
  name = "lb-2"
  provider = aws.peer
} 

##########################################################################
# Route53 with Failover Routing Policy
##########################################################################

resource "aws_route53_zone" "load_balancer_zone" {
  name    = var.domain
  comment = "Zone for ${var.domain}"
}

resource "aws_route53_health_check" "primary" {
  fqdn              = var.subdomain
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 5
  request_interval  = 30

  tags = {
    Name = "primary-healthcheck"
  }
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.subdomain
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 5
  request_interval  = 30

  tags = {
    Name = "secondary-healthcheck"
  }
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.load_balancer_zone.id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = 300
  set_identifier = "primary"
  records        = [data.aws_lb.lb_1.dns_name] 
  health_check_id = aws_route53_health_check.primary.id
  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.load_balancer_zone.id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = 300
  set_identifier = "secondary"
  records        = [data.aws_lb.lb_2.dns_name]  
  health_check_id = aws_route53_health_check.secondary.id
  failover_routing_policy {
    type = "SECONDARY"
  }
}
