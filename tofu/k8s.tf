module "talos" {
  depends_on = [module.k8s_network]
  source = "../lib/tofu/talos"
  providers = {
    proxmox  = proxmox
    routeros = routeros
    talos    = talos
  }
  talos_version   = "v1.8.4"
  k8s_version     = "1.31.4"
  cluster_name    = "talos"
  control_node_ip = "10.0.30.11"
  description     = "Primary K8s Cluster"
  dns_domain      = "pve.ddole.net"
  gateway_ip      = "10.0.30.1"
  nameservers = ["10.0.30.1"]
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

module "cilium" {
  depends_on = [module.talos]
  source = "../lib/tofu/cilium"
  providers = {
    kubernetes = kubernetes
  }
}
