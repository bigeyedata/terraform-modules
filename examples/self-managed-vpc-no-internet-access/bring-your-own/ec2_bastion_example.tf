# The EC2 bastion can be used as an SSH tunnel for no internet access installs.  This is here for demonstration
# purposes, a VPN is recommended instead for production.

# Run ssh-keygen -t rsa -b 4096 to create a key pair first if you have not already
resource "aws_key_pair" "bastion" {
  count      = var.bastion_enabled ? 1 : 0
  key_name   = "${local.name}-bastion-ssh"
  public_key = file(var.bastion_ssh_public_key_file)
}

resource "aws_cloudformation_stack" "bastioniam" {
  name = "${local.name}-bastion-iam"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM"
  ]
  template_body = jsonencode({
    Outputs = {
      InstanceProfile = {
        Value = {
          "Ref" = "InstanceProfile"
        }
      }
    }
    Resources = {
      BastionRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${local.name}-bastion"
          ManagedPolicyArns = [
            "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          ]
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Sid    = ""
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                  Service = "ec2.amazonaws.com"
                }
              }
            ]
          }
        }
      }
      InstanceProfile = {
        Type = "AWS::IAM::InstanceProfile",
        Properties = {
          InstanceProfileName = "${local.name}-bastion"
          Roles = [{
            "Ref" = "BastionRole"
          }]
        }
      }
    }
  })
}
resource "aws_security_group" "bastion" {
  count = var.bastion_enabled ? 1 : 0

  name        = "${local.name}-bastion"
  description = "Allows traffic to Bastion"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-bastion"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count             = var.bastion_enabled && var.bastion_public ? 1 : 0
  security_group_id = aws_security_group.bastion[0].id
  cidr_ipv4         = var.bastion_ingress_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "TCP"
}
resource "aws_vpc_security_group_egress_rule" "egress" {
  count             = var.bastion_enabled ? 1 : 0
  security_group_id = aws_security_group.bastion[0].id
  description       = "allow internal communication"
  cidr_ipv4         = var.cidr_block
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "TCP"
}

resource "aws_instance" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  # Amazon Linux 2023
  ami                         = "ami-01cd4de4363ab6ee8"
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.bastion[0].key_name
  subnet_id                   = var.bastion_public ? module.vpc.public_subnets[0] : module.vpc.private_subnets[0]
  associate_public_ip_address = var.bastion_public
  vpc_security_group_ids      = [aws_security_group.bastion[0].id]
  iam_instance_profile        = aws_cloudformation_stack.bastioniam.outputs["InstanceProfile"]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 10
    tags = {
      Name = "Bigeye bastion"
    }
  }

  tags = {
    Name  = "Bigeye bastion"
    stack = local.name
  }
}
