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

data github_repository "this" {
  name = local.repo
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}
resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = data.github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = false
}
resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  cluster_domain       = "cluster.local"
  components = ["source-controller", "kustomize-controller", "helm-controller", "notification-controller",]
  delete_git_manifests = true
  embedded_manifests   = true
  interval             = "1m0s"
  log_level            = "info"
  network_policy       = true
  path = "k8s/system"

}
