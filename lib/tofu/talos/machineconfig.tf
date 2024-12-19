locals {
  control_node = "${var.cluster_name}-01"
  fqdn         = "${local.control_node}.${var.dns_domain}"

}

resource "talos_machine_secrets" "talos_secrets" {
  talos_version = var.talos_version

}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint = "https://${local.fqdn}:6443" #"https://talos-dev.pve.ddole.net:6443"
  kubernetes_version = var.k8s_version
  talos_version      = var.talos_version
  machine_secrets    = talos_machine_secrets.talos_secrets.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  nodes = [local.control_node]
  endpoints = [local.fqdn]
}

locals {
}


resource "talos_machine_configuration_apply" "talos_machine_config" {
  timeouts = {
    create = "2m"
    delete = "2m"
    update = "2m"
    read   = "2m"
  }
  depends_on = [routeros_ip_dns_record.this]
  client_configuration        = talos_machine_secrets.talos_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.control_node
  endpoint                    = var.control_node_ip
  config_patches = [
    yamlencode({
      "cluster" : {
        "allowSchedulingOnControlPlanes" : true
      }
    }),
    yamlencode({
      "machine" : {
        "sysctls" : {
          "net.core.bpf_jit_harden" : 1
        },
        "install" : {
          "image" : data.talos_image_factory_urls.this.urls.installer
        }
      }
    }),
    yamlencode({
      "machine" : {
        "time" : {
          "disabled" : false,
          "servers" : var.nameservers
        }
      }
    }),
    yamlencode({
      "cluster" : {
        "network" : {
          "cni" : {
            "name" : "none"
          }
        },
        "proxy" : {
          "disabled" : true
        }
      }
    }),
    yamlencode({
      "machine" : {
        "nodeLabels" : {
          "bgp-policy" : "primary"
        },
        "nodeTaints" : { "node.cilium.io/agent-not-ready" : "NoSchedule" }
      }
    }),
    yamlencode({
      "cluster" : {
        "extraManifests" : [
          "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml"
        ]
      }

    })
  ]
}


resource "talos_machine_bootstrap" "this" {
  timeouts = {
    create = "4m"
    delete = "4m"
    update = "4m"
    read   = "4m"
  }
  depends_on = [proxmox_virtual_environment_vm.controlplane, talos_machine_configuration_apply.talos_machine_config]
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  node                 = var.control_node_ip
}


output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  node                 = var.control_node_ip
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
