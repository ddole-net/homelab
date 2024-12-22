module "talos" {
  depends_on = [module.k8s_network]
  source     = "../lib/tofu/talos"
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
  nameservers     = ["10.0.30.1"]
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

resource "time_sleep" "wait_k8s_bootstrap" {
  depends_on      = [module.talos]
  create_duration = "2m"
}

module "cilium" {
  depends_on = [time_sleep.wait_k8s_bootstrap]
  source     = "../lib/tofu/cilium"
  providers = {
    kubernetes = kubernetes
  }
}

data "github_repository" "this" {
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

resource "time_sleep" "wait_cilium_install" {
  depends_on      = [module.cilium]
  create_duration = "1m"
}

resource "kubernetes_namespace" "flux_system" {
  depends_on = [time_sleep.wait_cilium_install]
  metadata {
    name = "flux-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_secret" "FLUX_GPG_SECRET_KEY" {
  metadata {
    name      = "sops-gpg"
    namespace = kubernetes_namespace.flux_system.id
  }
  data = {
    "sops.asc" = data.bitwarden_secret.FLUX_GPG_SECRET_KEY.value
  }
}


resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, time_sleep.wait_cilium_install]

  cluster_domain       = "cluster.local"
  components           = ["source-controller", "kustomize-controller", "helm-controller", "notification-controller", ]
  delete_git_manifests = true
  embedded_manifests   = true
  interval             = "1m0s"
  log_level            = "info"
  network_policy       = true
  path                 = "k8s/clusters/prod"
  namespace            = "flux-system"
  keep_namespace       = true
}
resource "kubernetes_namespace" "bitwarden" {
  depends_on = [time_sleep.wait_cilium_install]
  metadata {
    name = "bitwarden"
  }
}
# resource "kubernetes_secret" "bws_machine_token_k8s_cert_manager" {
#   metadata {
#     name      = "bws-token-k8s-cert-manager"
#     namespace = kubernetes_namespace.bitwarden.id
#   }
#   data = {
#     token = data.bitwarden_secret.K8S_CERT_MANAGER_BWS_TOKEN.value
#   }
# }
