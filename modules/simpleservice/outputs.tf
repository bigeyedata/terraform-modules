output "ecs_service_arn" {
  description = "The ARN of the ecs service"
  value       = var.control_desired_count ? aws_ecs_service.controlled_count[0].id : aws_ecs_service.uncontrolled_count[0].id
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_full_name" {
  description = "The load balancer full name, for use with CW metrics"
  value       = aws_lb.this.arn_suffix
}

output "target_group_full_name" {
  description = "Target group full name, for use with CW metrics"
  value       = aws_lb_target_group.this.arn_suffix
}

output "zone_id" {
  description = "The zone that the load balancer DNS is controlled"
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "The created security group ID"
  value       = var.create_security_groups ? aws_security_group.this[0].id : ""
}
