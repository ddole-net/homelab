module "k8s_network" {
  source = "../lib/tofu/vnet"
  providers = {
    routeros = routeros
  }

  cidr    = "10.0.30.0/24"
  comment = "K8s Network, no dhcp"
  id      = 30
  name    = "static_net"
  dhcp    = false
}
