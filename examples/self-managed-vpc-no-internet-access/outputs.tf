output "bigeye_address" {
  value = module.bigeye.vanity_dns_name
}

output "bigeye_url" {
  value = "https://${module.bigeye.vanity_dns_name}"
}

output "bastion_ip" {
  value = module.bringyourown.bastion_ip
}

output "bastion_user" {
  value = module.bringyourown.bastion_user
}

