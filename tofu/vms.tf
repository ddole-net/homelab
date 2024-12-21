# module "fedora" {
#   source = "../lib/tofu/img"
#
#   checksum     = "6205ae0c524b4d1816dbd3573ce29b5c44ed26c9fbc874fbe48c41c89dd0bac2"
#   checksum_alg = "sha256"
#   name         = "fedora-cloud-41.img"
#   source_url   = "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
# }

# module "temp_network" {
#   source = "../lib/tofu/vnet"
#
#   cidr    = "10.0.70.0/24"
#   comment = "temp net"
#   id      = 70
#   name    = "temp"
# }

# module "subnet_router" {
#   source = "../lib/tofu/vm"
#
#   cloud_img_id = module.fedora.id
#   comment      = "subnet router"
#   cpus         = 2
#   disk_size    = 32
#   domain_name  = "lab.ddole.net"
#   name         = "rtr-03"
#   pve_node     = "pve-02"
#   ram          = 4096
#   ssh_user = {
#     name = "dhruv"
#     pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALfHGRizET7lwnfnIZIKuO/9w11dqFKzqzizwWmO/Jw svc_automaton@pve"
#   }
#   started      = true
#   vmid         = 200
#   vnet_id      = module.temp_network.id
#   vnet_name    = module.temp_network.name
# }
