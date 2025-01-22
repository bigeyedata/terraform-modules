terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

data "aws_caller_identity" "this" {}

data "aws_region" "current" {}

resource "aws_launch_template" "solr" {
  name     = var.resource_name
  image_id = data.aws_ssm_parameter.ecs_optimized_ami.value

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  instance_type = var.instance_type
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [module.ecs-solr-sg.security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
    yamlencode({
      write_files : [
        {
          path : "/root/variables.sh",
          content : join("\n", [
            "VAR_VOLUME_ID=${aws_ebs_volume.ebs_volume.id}",
            "VAR_ECS_CLUSTER=${data.aws_ecs_cluster.this.cluster_name}",
          ]),
          permissions : "0660",
        },
        {
          path : "/root/runonce.sh",
          content : file("${path.module}/runonce.sh"),
          permissions : "0750",
        },
      ],
      runcmd : ["/root/runonce.sh"]
    })
  ]))

  metadata_options {
    http_tokens = "required"
  }
}

resource "aws_autoscaling_group" "solr" {
  name                = var.resource_name
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [var.subnet]

  launch_template {
    id      = aws_launch_template.solr.id
    version = var.refresh_instance_on_launch_template_change ? aws_launch_template.solr.latest_version : "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = false
  wait_for_capacity_timeout = "0"

  instance_maintenance_policy {
    max_healthy_percentage = 100
    min_healthy_percentage = 0
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      # this ensures that old instance is stopped before new one is started. Needed to release an EBS volume.
      min_healthy_percentage = 0
      max_healthy_percentage = 100
    }
  }

  tag {
    key                 = "Name"
    value               = var.resource_name
    propagate_at_launch = true
  }

  # This tag is needed for ECS to work properly, do not delete
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}


# Find the latest ECS-optimized AMI for the region
data "aws_ssm_parameter" "ecs_optimized_ami" {
  # name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

module "ecs-solr-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name            = var.resource_name
  use_name_prefix = false
  vpc_id          = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks" = "${data.aws_vpc.this.cidr_block}"
      "rule"        = "solr-tcp"
      "description" = "Solr service"
    },
    {
      "cidr_blocks" = "${data.aws_vpc.this.cidr_block}"
      "rule"        = "ssh-tcp"
      "description" = "SSH"
    },
  ]

  egress_rules = [
    "all-tcp",
  ]
}

resource "aws_iam_role" "solr-ecs-instance-role" {
  name = var.resource_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "solr-instance-role-policy" {
  name   = "inline-policy"
  role   = aws_iam_role.solr-ecs-instance-role.id
  policy = data.aws_iam_policy_document.solr-instance-role-inline-policy.json
}

data "aws_iam_policy_document" "solr-instance-role-inline-policy" {
  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeInstances",
      "ec2:AttachVolume",
    ]
    sid = "AllowAttachingEBSVolume"
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:instance/*",
      aws_ebs_volume.ebs_volume.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"
      values   = [var.resource_name]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ])
  role       = aws_iam_role.solr-ecs-instance-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = var.resource_name
  role = aws_iam_role.solr-ecs-instance-role.name
}

resource "aws_cloudwatch_log_group" "solr" {
  name              = var.resource_name
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "solr" {
  family = var.resource_name
  cpu    = 1 * 1024
  memory = 1 * 1024
  container_definitions = jsonencode([
    {
      name      = var.resource_name
      image     = "solr:9.7.0"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8983
          hostPort      = 8983
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.solr.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.resource_name
        }
      }
      mountPoints = [
        {
          sourceVolume  = var.resource_name
          containerPath = "/var/solr"
          readOnly      = false
        }
      ]
      ulimits = [ # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-resource-limits
        {
          name      = "nofile"
          softLimit = 1048576
          hardLimit = 1048576
        }
      ]
    }
  ])
  # network_mode = "awsvpc"
  network_mode = "host"
  requires_compatibilities = [
    "EC2",
  ]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/ecsTaskExecutionRole"

  volume {
    configure_at_launch = false
    name                = var.resource_name
    host_path           = "/mnt/solr-data" # Path on the EC2 instance to bind mount.
  }

}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

# ECS Capacity Provider (linked to ASG)
resource "aws_ecs_capacity_provider" "this" {
  name = var.resource_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.solr.arn

    managed_draining = "DISABLED"
    managed_scaling {
      status = "DISABLED"
    }
  }
}

resource "aws_ecs_service" "solr" {
  name                              = var.resource_name
  cluster                           = data.aws_ecs_cluster.this.id
  task_definition                   = "${aws_ecs_task_definition.solr.id}:${aws_ecs_task_definition.solr.revision}"
  desired_count                     = 1
  scheduling_strategy               = "REPLICA"
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 60
  # uncomment after provider >=5.62.0
  # force_delete                      = true


  # network_configuration only works with awsvpc network
  # network_configuration {
  #   # assign_public_ip = true
  #   security_groups = [
  #     module.ecs-solr-sg.security_group_id
  #   ]
  #   subnets = [var.subnet]
  # }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  # in provider 5.77.0, this needs to be disabled to allow stopping old task before staring a new one
  # availability_zone_rebalancing      = "DISABLED"

  deployment_maximum_percent         = 100 # This allows ECS to run up to 100% of the desired count of tasks during a deployment
  deployment_minimum_healthy_percent = 0   # This allows ECS to stop old tasks first before starting new ones


  # deployment_circuit_breaker {
  #   enable   = true
  #   rollback = true
  # }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  tags = {
    Name = var.resource_name
  }
}