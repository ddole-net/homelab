data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "intel-ucode",
      "qemu-guest-agent",
      "fuse3",
      "iscsi-tools",
      # "tailscale",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        },
        extraKernelArgs = [
          "net.ifnames=0",
        ],
      }
    }
  )
}
data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_virtual_environment_download_file" "controlplane-img" {
  content_type = "iso"
  datastore_id = "shared"
  file_name    = "talos-controlplane.img"
  node_name    = "pve-01"
  url          = data.talos_image_factory_urls.this.urls.iso
}
