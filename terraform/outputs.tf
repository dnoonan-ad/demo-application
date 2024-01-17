output "app_address" {
  value = aws_lb.ecs_alb.dns_name
}