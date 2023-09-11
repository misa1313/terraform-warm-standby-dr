output "load_balancer_dns" {
  value = data.aws_lb.lb_1.dns_name
}

output "load_balancer_dns_2" {
  value = data.aws_lb.lb_2.dns_name
}