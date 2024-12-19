terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.68.1"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }
    hex = {
      source  = "Jupiter-Inc/hex"
      version = "1.0.4"
    }
  }
}

variable "name" {
  type        = string
  description = "The short hostname of the vm(not FQDN)"
}

variable "domain_name" {
  type        = string
  description = "the domain which completes the FQDN(appended to name with '.')"
}
variable "pve_node" {
  type        = string
  description = "The PVE node to host the VM"
}
variable "cpus" {
  type        = number
  description = "the number of cpus"
}
variable "ram" {
  type        = number
  description = "the amount of ram in MiB"
}
variable "comment" {
  type        = string
  description = "A comment"
}

variable "vmid" {
  type        = number
  description = "the proxmox vmid"
}

variable "disk_size" {
  type        = number
  description = "the disk size in GB"
}

variable "vnet_id" {
  type        = string
  description = "the vnet id for the network"
}
variable "vnet_name" {
  type        = string
  description = "the name of the vnet"
}

variable "cloud_img_id" {
  type        = string
  description = "The id of the cloud image module"
}

variable "ssh_user" {
  type        = map(string)
  description = "the ssh public key for the service account"
}
variable "started" {
  type = bool
  description = "started or shutdown"
}
