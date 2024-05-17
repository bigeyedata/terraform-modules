variable "aws_region" {
  type = string
}
variable "aws_account_id" {
  type = string
}
variable "stack_name" {
  type = string
}
variable "parent_domain_zone_id" {
  type = string
}
variable "subdomain" {
  type = string
}
variable "subdomain_prefix" {
  type = string
}
variable "from_email" {
  type = string
}
variable "cidr_first_two_octets" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "bastion_enabled" {
  type = string
}
variable "bastion_public" {
  type = string
}
variable "bastion_ingress_cidr" {
  type = string
}
variable "bastion_ssh_public_key_file" {
  type = string
}
