output "bigeye_address" {
  value = "https://${local.vanity_alias}.${local.subdomain}"
}

output "bigeye_first_time_account_creation_address" {
  value = "https://${local.vanity_alias}.${local.subdomain}/first-time"
}

output "bastion" {
  value = one(aws_instance.bastion[*].public_dns)
}

output "bastion_ssh_user" {
  value = format("ssh ubuntu@%s", one(aws_instance.bastion[*].public_dns))
}