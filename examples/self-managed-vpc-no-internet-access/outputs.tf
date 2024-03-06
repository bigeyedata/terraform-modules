output "bigeye_address" {
  value = "${local.vanity_alias}.${local.subdomain}"
}

output "bigeye_url" {
  value = "https://${local.vanity_alias}.${local.subdomain}"
}

output "bastion" {
  value = one(aws_instance.bastion[*].public_dns)
}

output "bastion_ssh_user" {
  value = "ubuntu"
}
