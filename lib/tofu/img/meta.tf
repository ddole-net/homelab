terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.68.1"
    }
  }
}

variable "name" {
  type        = string
  description = "The desired name of the image"
}

variable "source_url" {
  type        = string
  description = "the file download url"
}
variable "checksum" {
  type        = string
  description = "checksum"
}
variable "checksum_alg" {
  type        = string
  description = "checkum algorithm"
}

output "id" {
  value = proxmox_virtual_environment_download_file.this.id
}
