terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.68.1"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }
    hex = {
      source  = "Jupiter-Inc/hex"
      version = "1.0.4"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">=0.7.0-alpha.0"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = ">=2.16.1"
    # }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }

  }
}




variable "talos_version" {
  type        = string
  description = "The TalosLinux OS Version"
}
variable "k8s_version" {
  type        = string
  description = "The K8s Version"
}
variable "cluster_name" {
  type        = string
  description = "the name of the cluster"
}

variable "control_node_ip" {
  type        = string
  description = "the desired ip of the controlplane node"
}

variable "dns_domain" {
  type        = string
  description = "the dns domain appended to the cluster_name"
}

variable "description" {
  type        = string
  description = "A ui friendly comment"
}
variable "nameservers" {
  type        = list(string)
  description = "a list of nameservers"
}
variable "gateway_ip" {
  type        = string
  description = "The network gateway ip"
}

output "kube_host" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
}
output "kube_client_cert" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
}
output "kube_client_key" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
}
output "kube_ca_cert" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
}
