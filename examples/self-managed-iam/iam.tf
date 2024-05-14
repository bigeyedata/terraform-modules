resource "aws_iam_role" "ecs" {
  name = "${local.name}-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution" {
  role = aws_iam_role.ecs.id
  name = "ECSTaskExecution"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${module.bigeye.cloudwatch_bigeye_log_group_arn}:log-stream:*",
          "${module.bigeye.cloudwatch_temporal_log_group_arn}:log-stream:*",
        ]
      }
    ]
  })

}

resource "aws_iam_role_policy" "ecs_secrets" {
  role = aws_iam_role.ecs.id
  name = "AllowAccessSecrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowGetSecrets"
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/stack" = local.name
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "monocle" {
  name = "${local.name}-monocle"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "monocle" {
  role = aws_iam_role.monocle.id
  name = "AllowAccessModelsBucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = module.bigeye.models_bucket_arn
      },
      {
        Sid    = "AllowGetPutObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = format("%s/*", module.bigeye.models_bucket_arn)
      }
    ]
  })
}

resource "aws_iam_role" "datawatch" {
  name = "${local.name}-datawatch"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_s3" {
  role = aws_iam_role.datawatch.id
  name = "AllowAccessLargePayloadBucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = module.bigeye.large_payload_bucket_arn
      },
      {
        Sid    = "AllowGetPutObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = format("%s/*", module.bigeye.large_payload_bucket_arn)
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_temporalsecrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowTemporalSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteNewSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*"
        ]
      },
      {
        Sid    = "AllowReadSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/*/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/datawatch-temporal/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_listsecrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowListSecrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:ListSecrets"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_secrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteNewSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/agent/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
        ]
      },
      {
        Sid    = "AllowReadSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/agent/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "admin_container" {
  name = "${local.name}-admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "admin_container" {
  role = aws_iam_role.admin_container.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:${module.bigeye.cloudwatch_log_group_name}:*"
      },
      {
        "Sid" : "GrantGlobalAccess",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSecurityGroups",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "GrantSpecificAccess",
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "ecs:DescribeServices",
          "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheClusters",
        ],
        "Resource" : [
          "arn:aws:rds:${local.aws_region}:${local.aws_account_id}:db:${local.name}*",
          "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:service/${local.name}/*",
          "arn:aws:elasticache:${local.aws_region}:${local.aws_account_id}:replicationgroup:${local.name}",
          "arn:aws:elasticache:${local.aws_region}:${local.aws_account_id}:cluster:${local.name}*",
        ]
      }
    ]
  })
}
