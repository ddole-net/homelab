terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }
  }
}

variable "name" {
  type        = string
  description = "User friendly name"
}
variable "cidr" {
  type        = string
  description = "cidr block '10.0.0.0/24'"
}

variable "id" {
  type        = string
  description = "integer network id, used as vlan id"
}

variable "comment" {
  type        = string
  description = "A comment for routeros"
}

variable "dhcp" {
  type =  bool
  description = "enable dhcp server"
  default = true
}

output "name" {
  value = var.name
}
output "cidr" {
  value = var.cidr
}
output "id" {

  value = var.id
}
