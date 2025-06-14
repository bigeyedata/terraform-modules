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

resource "aws_launch_template" "solr" {
  name     = var.name
  image_id = data.aws_ssm_parameter.ecs_optimized_ami.value

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  instance_type = var.instance_type
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [module.ecs-solr-ec2-instance-sg.security_group_id]
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
          path : "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
          content : file("${path.module}/amazon-cloudwatch-agent.json"),
          permissions : "0644",
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

  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = "true"
      volume_size = var.ebs_volume_size_os
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.solr_tags, {
      Name = "${var.name}-os"
    })
  }
}

resource "aws_autoscaling_group" "solr" {
  name                = var.name
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = [var.subnet_id]

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
    value               = var.name
    propagate_at_launch = true
  }

  # This tag is needed for ECS to work properly, do not delete
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "app"
    value               = var.app
    propagate_at_launch = true
  }

  tag {
    key                 = "component"
    value               = "solr"
    propagate_at_launch = true
  }

  tag {
    key                 = "instance"
    value               = var.instance
    propagate_at_launch = true
  }

  tag {
    key                 = "stack"
    value               = var.stack
    propagate_at_launch = true
  }
}


# Find the latest ECS-optimized AMI for the region
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

module "ecs-solr-service-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name            = "${var.name}-ecs-svc"
  use_name_prefix = false
  vpc_id          = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      cidr_blocks = "${data.aws_vpc.this.cidr_block}"
      description = "Solr service"
      protocol    = "tcp"
      from_port   = var.solr_traffic_port
      to_port     = var.solr_traffic_port
    },
  ]

  egress_rules = [
    "all-tcp",
  ]

  tags = local.solr_tags
}

module "ecs-solr-ec2-instance-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name            = "${var.name}-ec2-instance"
  use_name_prefix = false
  vpc_id          = var.vpc_id

  egress_rules = [
    "all-tcp",
  ]

  tags = local.solr_tags
}

resource "aws_iam_role" "solr-ecs-instance-role" {
  name = var.name
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

  tags = local.solr_tags
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
      values   = [var.name]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ])
  role       = aws_iam_role.solr-ecs-instance-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = var.name
  role = aws_iam_role.solr-ecs-instance-role.name
}

resource "aws_cloudwatch_log_group" "solr" {
  name              = var.name
  retention_in_days = 14

  tags = local.solr_tags
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

locals {
  solr_default_opts = [
    "-Dfile.encoding=UTF-8",
  ]
  solr_tags = merge(var.tags, {
    app       = var.app
    component = "solr"
  })
}

resource "aws_ecs_task_definition" "solr" {
  family = var.name
  # While cpu is optional, pinning it allows our CPU graphs to read as 100% showing full utilization,
  # vs without where util could be 300%, 700% etc
  cpu = local.ec2_cpu_units
  # Setting mem here is technically optional, but I was able to eek out another 256 of container mem by setting this.
  memory                = local.ec2_mem_usable
  container_definitions = jsonencode(local.container_definitions)
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "EC2",
  ]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  execution_role_arn = var.execution_role_arn

  volume {
    configure_at_launch = false
    name                = "${var.name}-data"
    host_path           = "/mnt/solr-data/data" # Path on the EC2 instance to bind mount.
  }

  tags = local.solr_tags

}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

# ECS Capacity Provider (linked to ASG)
resource "aws_ecs_capacity_provider" "this" {
  name = var.name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.solr.arn

    managed_draining = "DISABLED"
    managed_scaling {
      status = "DISABLED"
    }
  }
}

resource "aws_ecs_service" "solr" {
  name                              = var.name
  cluster                           = data.aws_ecs_cluster.this.id
  task_definition                   = "${aws_ecs_task_definition.solr.id}:${aws_ecs_task_definition.solr.revision}"
  desired_count                     = var.desired_count
  scheduling_strategy               = "REPLICA"
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 60

  network_configuration {
    security_groups = [
      module.ecs-solr-service-sg.security_group_id
    ]
    subnets = [var.subnet_id]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  # in provider 5.77.0, this needs to be disabled to allow stopping old task before staring a new one
  # availability_zone_rebalancing      = "DISABLED"

  deployment_maximum_percent         = 100 # This allows ECS to run up to 100% of the desired count of tasks during a deployment
  deployment_minimum_healthy_percent = 0   # This allows ECS to stop old tasks first before starting new ones

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.solr_traffic_port
    target_group_arn = module.alb.target_groups["solr"].arn
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  propagate_tags = "SERVICE"
  tags           = local.solr_tags

}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  iops              = var.ebs_volume_iops
  throughput        = var.ebs_volume_throughput
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.solr_tags, {
    Name = var.name
  })
}

resource "aws_service_discovery_service" "this" {
  name = "solr"

  dns_config {
    namespace_id = var.service_discovery_private_dns_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.10.0"

  name    = var.name
  vpc_id  = var.vpc_id
  subnets = var.lb_subnet_ids

  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = data.aws_vpc.this.cidr_block
    }
  }
  security_group_tags = merge(local.solr_tags, {
    Name = "${var.name}-lb"
  })

  access_logs = var.lb_access_logs_enabled ? {
    enabled = var.lb_access_logs_enabled
    bucket  = var.lb_access_logs_bucket_name
    prefix  = var.lb_access_logs_bucket_prefix
  } : {}

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.acm_certificate_arn

      forward = {
        target_group_key = "solr"
      }
    }
  }

  target_groups = {
    solr = {
      # name_prefix can only be 6 chars long
      name_prefix          = substr(var.name, 0, 6)
      create_attachment    = false
      protocol             = "HTTP"
      port                 = var.solr_traffic_port
      target_type          = "ip"
      deregistration_delay = 0
      vpc_id               = var.vpc_id
      health_check = {
        enabled = true
        path    = "/solr/#/login"
      }
      tags = merge(local.solr_tags, {
        Name = var.name
      })
    }
  }

  tags = local.solr_tags
}

resource "aws_route53_record" "solr" {
  count   = var.dns_name != "" && var.route53_zone_id != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.dns_name
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "solr_cname" {
  count   = var.dns_name != "" && var.route53_zone_id != "" && length(var.solr_cnames) > 0 ? length(var.solr_cnames) : 0
  zone_id = var.route53_zone_id
  name    = var.solr_cnames[count.index]
  type    = "CNAME"
  ttl     = 300
  records = [var.dns_name]
}
