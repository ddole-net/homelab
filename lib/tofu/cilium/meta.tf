terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.0"
    }
  }
}
# provider "kubernetes" {
#
# }
# variable "kube_host" {
#   type = string
# }
# variable "kube_client_cert" {
#   type = string
# }
# variable "kube_client_key" {
#   type = string
# }
# variable "kube_cluster_ca_cert" {
#   type = string
# }
