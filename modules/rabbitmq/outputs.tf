output "arn" {
  description = "ARN of the RabbitMQ broker"
  value       = aws_mq_broker.queue.arn
}

output "id" {
  description = "ID of the RabbitMQ broker"
  value       = aws_mq_broker.queue.id
}

output "name" {
  description = "Name of the RabbitMQ broker"
  value       = aws_mq_broker.queue.broker_name
}

output "endpoint" {
  description = "The amqps endpoint for the broker"
  value       = aws_mq_broker.queue.instances[0].endpoints[0]
}

output "rabbitmq_security_group" {
  description = "The security group ID that was created for the RabbitMQ broker"
  value       = var.create_security_groups ? aws_security_group.this[0].id : ""
}

output "client_security_group_id" {
  description = "The security group ID that was created for the RabbitMQ clients"
  value       = var.create_security_groups ? aws_security_group.client[0].id : ""
}
