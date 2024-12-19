terraform {
  backend "azurerm" {
    resource_group_name = "homelab-infra"
    storage_account_name = "ddoletfstate"
    container_name = "homelab"
    key = "tofu.tfstate"

  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.1"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.71.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0-alpha.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.81.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">=0.12.1"
    }
  }
}
variable "BWS_TOKEN" {
  sensitive = true
  type = string
}

provider "bitwarden" {
  access_token = var.BWS_TOKEN
  experimental {

    embedded_client = true
  }
}
provider "aws" {
  region     = "us-east-1"
  access_key = data.bitwarden_secret.AWS_ACCESS_KEY_ID.value
  secret_key = data.bitwarden_secret.AWS_SECRET_ACCESS_KEY.value
}
provider "routeros" {
  hosturl  = "http://10.0.0.1"
  username = data.bitwarden_secret.ROUTEROS_USER.value
  password = data.bitwarden_secret.ROUTEROS_PASSWORD.value
  insecure = true
}
provider "proxmox" {
  endpoint  = "https://10.0.0.3:8006/"
  api_token = data.bitwarden_secret.PVE_API_TOKEN.value
  insecure  = true
  ssh {
    agent       = false
    username    = data.bitwarden_secret.PVE_USER.value
    private_key = data.bitwarden_secret.PVE_SSH_PRIVATE_KEY.value
    node {
      name    = "pve-01"
      address = "10.0.0.3"
    }
    node {
      name    = "pve-02"
      address = "10.0.0.4"
    }
    node {
      name    = "pve-03"
      address = "10.0.0.5"
    }
  }
}
provider "kubernetes" {
  host = module.talos.kube_host
  client_certificate = base64decode(module.talos.kube_client_cert)
  client_key = base64decode(module.talos.kube_client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_ca_cert)
}
provider "helm" {
  kubernetes {
    host = module.talos.kube_host
    client_certificate = base64decode(module.talos.kube_client_cert)
    client_key = base64decode(module.talos.kube_client_key)
    cluster_ca_certificate = base64decode(module.talos.kube_ca_cert)
  }
}
