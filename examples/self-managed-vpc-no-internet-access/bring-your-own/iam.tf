locals {
  bigeye_log_group_arn_pattern      = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:${local.name}:log-stream:*"
  temporal_log_group_arn_pattern    = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:${local.name}-temporal:log-stream:*"
  models_bucket_arn_pattern         = "arn:aws:s3:::${local.name}-models-*"
  large_payloads_bucket_arn_pattern = "arn:aws:s3:::${local.name}-large-payload-*"
}

resource "aws_cloudformation_stack" "iam" {
  name = "${local.name}-iam-roles"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM"
  ]
  template_body = jsonencode({
    Outputs = {
      ECSRoleArn = {
        Value = {
          "Fn::GetAtt" = ["ECSServiceRole", "Arn"]
        }
      }
      MonocleRoleArn = {
        Value = {
          "Fn::GetAtt" = ["MonocleRole", "Arn"]
        }
      }
      DatawatchRoleArn = {
        Value = {
          "Fn::GetAtt" = ["DatawatchRole", "Arn"]
        }
      }
      AdminContainerRoleArn = {
        Value = {
          "Fn::GetAtt" = ["AdminContainerRole", "Arn"]
        }
      }
    }
    Resources = {
      ECSServiceRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${local.name}-service-role"
          AssumeRolePolicyDocument = {
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
          }
        }
      }
      ECSServiceRoleExecutionPolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "ECSServiceRole"
          }
          PolicyName = "ECSTaskExecution"
          PolicyDocument = {
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
                  local.bigeye_log_group_arn_pattern,
                  local.temporal_log_group_arn_pattern
                ]
              }
            ]
          }
        }
      }
      ECSServiceRoleSecretsPolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "ECSServiceRole"
          }
          PolicyName = "AllowAccessSecrets"
          PolicyDocument = {
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
          }
        }
      }
      MonocleRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${local.name}-monocle"
          AssumeRolePolicyDocument = {
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

          }
        }
      }
      MonocleRolePolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "MonocleRole"
          }
          PolicyName = "AllowAccessModelsBucket"
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Sid    = "AllowListBucket"
                Effect = "Allow"
                Action = [
                  "s3:ListBucket",
                ]
                Resource = local.models_bucket_arn_pattern
              },
              {
                Sid    = "AllowGetPutObjects"
                Effect = "Allow"
                Action = [
                  "s3:GetObject",
                  "s3:PutObject"
                ]
                Resource = format("%s/*", local.models_bucket_arn_pattern)
              }
            ]
          }
        }
      }
      DatawatchRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${local.name}-datawatch"
          AssumeRolePolicyDocument = {
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
          }
        }
      }
      DatawatchRoleS3Policy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "DatawatchRole"
          }
          PolicyName = "AllowAccessLargePayloadBucket"
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Sid      = "AllowListBucket"
                Effect   = "Allow"
                Action   = "s3:ListBucket"
                Resource = local.large_payloads_bucket_arn_pattern
              },
              {
                Sid    = "AllowGetPutObjects"
                Effect = "Allow"
                Action = [
                  "s3:GetObject",
                  "s3:PutObject"
                ]
                Resource = format("%s/*", local.large_payloads_bucket_arn_pattern)
              }
            ]
          }
        }
      }
      DatawatchRoleTemporalSecretsPolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "DatawatchRole"
          }
          PolicyName = "AllowTemporalSecretsAccess"
          PolicyDocument = {
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
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*"
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
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*",
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/temporal/*/*",
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/datawatch-temporal/*"
                ]
              }
            ]
          }
        }
      }
      DatawatchRoleListSecretsPolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "DatawatchRole"
          }
          PolicyName = "AllowListSecrets"
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Sid      = "AllowListSecrets"
                Effect   = "Allow"
                Action   = ["secretsmanager:ListSecrets"]
                Resource = "*"
              }
            ]
          }
        }
      }
      DatawatchRoleSecretManagePolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "DatawatchRole"
          }
          PolicyName = "AllowSecretsAccess"
          PolicyDocument = {
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
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/agent/*",
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
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
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/agent/*",
                  "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
                ]
              }
            ]
          }
        }
      }
      AdminContainerRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${local.name}-admin"
          AssumeRolePolicyDocument = {
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
          }
        }
      }
      AdminContainerRolePolicy = {
        Type = "AWS::IAM::RolePolicy"
        Properties = {
          RoleName = {
            "Ref" = "AdminContainerRole"
          }
          PolicyName = "AdminContainerPolicy"
          PolicyDocument = {
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
                "Resource" : local.bigeye_log_group_arn_pattern
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
                  "arn:aws:rds:${var.aws_region}:${var.aws_account_id}:db:${local.name}*",
                  "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${local.name}/*",
                  "arn:aws:elasticache:${var.aws_region}:${var.aws_account_id}:replicationgroup:${local.name}",
                  "arn:aws:elasticache:${var.aws_region}:${var.aws_account_id}:cluster:${local.name}*",
                ]
              }
            ]
          }
        }
      }
    }
  })
}
