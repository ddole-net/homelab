locals {
  node = "pve-01"
}

resource "proxmox_virtual_environment_download_file" "this" {
  content_type       = "iso"
  datastore_id       = "shared"
  file_name          = "${var.name}.img"
  node_name          = local.node
  url                = var.source_url
  checksum           = var.checksum
  checksum_algorithm = var.checksum_alg
}
