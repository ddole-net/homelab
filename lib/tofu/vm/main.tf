locals {
  fqdn = "${var.name}.${var.domain_name}"

}
# dhcp lease: netconf, hostname
resource "hex_string" "hex_hostname" {
  data = local.fqdn
}

# resource "routeros_ip_dhcp_server_option" "hostname" {
#   name  = var.name
#   code  = 12
#   value = "0x${hex_string.hex_hostname.result}"
#   force = true
#   comment = var.comment
# }

# resource "routeros_ip_dhcp_server_lease" "this" {
#   depends_on = [proxmox_virtual_environment_vm.this]
#   server      = var.vnet_name
#   address     = "10.0.20.100"
#   mac_address = proxmox_virtual_environment_vm.this.mac_addresses[1]
#
#   dhcp_option = routeros_ip_dhcp_server_option.hostname.name
#   lease_time  = "0s"
# }


# dns record
# Cloudinit snippet
resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "shared"
  node_name    = "pve-01"

  source_raw {
    data      = <<-EOF
    #cloud-config
    fqdn: ${local.fqdn}
    prefer_fqdn_over_hostname: true
    users:
      - name: ${var.ssh_user["name"]}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - "${var.ssh_user["pubkey"]}"
        sudo: ALL=(ALL) NOPASSWD:ALL
    keyboard:
      layout: us
    timezone: America/Chicago
    package_reboot_if_required: true
    package_update: true
    package_upgrade: true
    packages:
      - epel-release
    runcmd:
      - crb enable


    EOF
    file_name = "${var.vmid}-userdata.yaml"

  }
}


# actual vm


resource "proxmox_virtual_environment_vm" "this" {
  lifecycle {
    prevent_destroy = false
  }
  name        = var.name
  description = var.comment
  # tags        = ["taloslinux", "k8s", "managed", "dev"]
  node_name = var.pve_node
  vm_id     = var.vmid
  agent {
    enabled = true
    timeout = "2m"
    trim    = true
  }
  acpi = true
  cpu {
    cores = var.cpus
    type  = "host"
    units = 100
  }
  memory {
    dedicated = var.ram
    floating  = var.ram
    shared    = 0
  }
  scsi_hardware = "virtio-scsi-single"
  disk {
    interface    = "scsi0"
    iothread     = true
    size         = var.disk_size
    file_id      = var.cloud_img_id
    cache        = "none"
    datastore_id = "local-lvm"
    discard      = "on"
    ssd          = true
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = false
    model        = "virtio"
    # mac_address  = local.mac_addr
    vlan_id = var.vnet_id
  }
  on_boot = false
  # on_boot = true
  startup {
    order = 200
  }
  started         = var.started
  stop_on_destroy = false

  migrate = false
  # cdrom {
  #   enabled   = true
  #   file_id   = proxmox_virtual_environment_download_file.taloslinux-iso.id
  #   interface = "ide2"
  # }
  boot_order = ["scsi0"]
  bios       = "ovmf"
  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }
  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }
  machine = "q35"
  operating_system {
    type = "l26"
  }
  serial_device {
    device = "socket"
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
}
locals {
  vm_ip = proxmox_virtual_environment_vm.this.ipv4_addresses[1][0]
}
resource "routeros_ip_dns_record" "this" {
  count = var.started ? 1 : 0
  name    = local.fqdn
  address = local.vm_ip
  type    = "A"
  comment = var.comment
  ttl     = "30"
}
