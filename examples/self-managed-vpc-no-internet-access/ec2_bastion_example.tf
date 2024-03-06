# The EC2 bastion can be used as an SSH tunnel for no internet access installs.  This is here for demonstration
# purposes, a VPN is recommended instead for production.

# Run ssh-keygen -t rsa -b 4096 to create a key pair first if you have not already
resource "aws_key_pair" "bastion" {
  count      = local.bastion_enabled ? 1 : 0
  key_name   = "${local.name}-bastion-ssh"
  public_key = file(local.bastion_ssh_public_key_file)
}

resource "aws_security_group" "bastion" {
  count = local.bastion_enabled ? 1 : 0

  name        = "${local.name}-bastion"
  description = "Allows traffic to Bastion"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-bastion"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "Allow all traffic"
    cidr_blocks = [local.bastion_ingress_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all egress"
  }
}

resource "aws_instance" "bastion" {
  count = local.bastion_enabled ? 1 : 0
  # Ubuntu 22.04 LTS https://cloud-images.ubuntu.com/locator/ec2/
  ami                         = "ami-08116b9957a259459"
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.bastion[0].key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion[0].id]

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
