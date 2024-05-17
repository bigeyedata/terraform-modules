resource "random_password" "rabbitmq_user_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rabbitmq_user_password" {
  name                    = format("bigeye/%s/datawatch/rabbitmq/password", local.name)
  recovery_window_in_days = 7
  tags = {
    stack = local.name
  }
}

resource "aws_secretsmanager_secret_version" "rabbitmq_user_password" {
  secret_id      = aws_secretsmanager_secret.rabbitmq_user_password.id
  secret_string  = random_password.rabbitmq_user_password.result
  version_stages = ["AWSCURRENT"]
}

resource "aws_cloudformation_stack" "mq" {
  name = "${local.name}-rabbit"
  template_body = jsonencode({
    Outputs = {
      Endpoints = {
        Value = {
          "Fn::Join" = [",", {
            "Fn::GetAtt" = ["Broker", "AmqpEndpoints"]
          }]
        }
      }
    }
    Resources = {
      Broker = {
        Type = "AWS::AmazonMQ::Broker"
        Properties = {
          BrokerName              = local.name
          AuthenticationStrategy  = "simple"
          AutoMinorVersionUpgrade = false
          DeploymentMode          = "SINGLE_INSTANCE"
          EngineType              = "RabbitMQ"
          EngineVersion           = "3.11.20"
          HostInstanceType        = "mq.t3.micro"
          PubliclyAccessible      = false
          StorageType             = "EBS"
          SubnetIds               = [module.vpc.elasticache_subnets[0]]
          SecurityGroups          = [aws_security_group.rabbitmq.id]
          Users = [
            {
              ConsoleAccess = true
              Username      = "bigeye"
              Password      = random_password.rabbitmq_user_password.result
            }
          ]
        }
      }
    }
  })
}

