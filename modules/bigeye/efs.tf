resource "aws_security_group" "efs" {
  count  = var.create_security_groups && local.efs_volume_enabled ? 1 : 0
  name   = "${local.name}-efs"
  vpc_id = local.vpc_id

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  count             = var.create_security_groups && local.efs_volume_enabled ? 1 : 0
  description       = "Allow NFS"
  security_group_id = aws_security_group.efs[0].id
  from_port         = 2049 # NFS
  to_port           = 2049 # NFS
  ip_protocol       = "TCP"
  cidr_ipv4         = var.vpc_cidr_block
}

resource "aws_efs_file_system" "this" {
  count           = local.efs_volume_enabled ? 1 : 0
  throughput_mode = "elastic"
  encrypted       = true
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_efs_file_system_policy" "this" {
  count          = local.efs_volume_enabled ? 1 : 0
  file_system_id = aws_efs_file_system.this[0].id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "allow-root-access",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [
            "elasticfilesystem:ClientRootAccess",
            "elasticfilesystem:ClientWrite",
            "elasticfilesystem:ClientMount"
          ],
          "Resource" : aws_efs_file_system.this[0].arn,
          "Condition" : {
            "Bool" : {
              "elasticfilesystem:AccessedViaMountTarget" : "true"
            }
          }
        },
        {
          "Sid" : "deny-unencrypted-transport",
          "Effect" : "Deny",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "*",
          "Resource" : aws_efs_file_system.this[0].arn,
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
    }

  )
}

resource "aws_efs_mount_target" "this" {
  for_each        = local.efs_volume_enabled ? toset(local.application_subnet_ids) : []
  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = each.value
  security_groups = concat(var.efs_volume_extra_security_group_ids, [one(aws_security_group.efs[*].id)])
}

resource "aws_efs_access_point" "bigeye_admin" {
  count          = local.efs_volume_enabled && var.enable_bigeye_admin_module ? 1 : 0
  file_system_id = aws_efs_file_system.this[0].id
  root_directory {
    path = "/"
  }
  tags = merge(local.tags, {
    Name = "${local.name}-bigeye-admin"
    app  = "bigeye-admin"
  })
}

resource "aws_efs_access_point" "this" {
  for_each       = local.efs_volume_enabled ? toset(var.efs_volume_enabled_services) : []
  file_system_id = aws_efs_file_system.this[0].id
  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
    path = "/${each.value}"
  }
  tags = merge(local.tags, {
    Name = "${local.name}-${each.value}"
    app  = each.value
  })
}
