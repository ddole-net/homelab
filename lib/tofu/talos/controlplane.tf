resource "proxmox_virtual_environment_vm" "controlplane" {
  lifecycle {
    prevent_destroy = false
  }
  name        = local.fqdn
  description = "ControlPlane"
  # tags        = ["taloslinux", "k8s", "managed", "dev"]
  node_name = "pve-01"
  vm_id     = 201
  agent {
    enabled = true
    timeout = "2m"
    trim    = true
  }
  acpi = true
  cpu {
    cores = 4
    type  = "host"
    units = 100
  }
  memory {
    dedicated = 16384
    floating  = 16384
  }
  scsi_hardware = "virtio-scsi-single"

  disk {
    interface    = "scsi0"
    iothread     = true
    size         = 32
    file_id      = proxmox_virtual_environment_download_file.controlplane-img.id
    cache        = "none"
    datastore_id = "local-lvm"
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    model        = "virtio"
    vlan_id      = 30
  }
  on_boot = false
  startup {
    order = 200
  }
  started         = true
  stop_on_destroy = true

  migrate = false
  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_download_file.controlplane-img.id
    interface = "ide3"
  }
  boot_order = ["scsi0", "ide3"]
  bios       = "ovmf"
  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = false
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
        address = "${var.control_node_ip}/24"
        gateway = var.gateway_ip
      }
    }
    dns {
      servers = var.nameservers
      domain  = var.dns_domain
    }
    # user_data_file_id = proxmox_virtual_environment_file.controlplane-userdata.id
  }
}

resource "routeros_ip_dns_record" "this" {
  depends_on = [proxmox_virtual_environment_vm.controlplane]
  name       = local.fqdn
  address    = var.control_node_ip
  type       = "A"
  comment    = var.description
  ttl        = "30"
}
