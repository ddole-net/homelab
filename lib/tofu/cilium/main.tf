resource "kubernetes_cluster_role_binding" "cilium" {
  metadata { name = "cilium-install" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cilium-install"
    namespace = "kube-system"
  }
}

resource "kubernetes_service_account" "cilium" {
  metadata {
    name      = "cilium-install"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map" "cilium-values" {
  metadata {
    name      = "cilium-values"
    namespace = "kube-system"
  }
  data = { values = file("./${path.module}/cilium-values.yaml") }

}

resource "kubernetes_job" "cilium" {
  metadata {
    name      = "cilium-install"
    namespace = "kube-system"
  }
  spec {
    backoff_limit = 10
    template {
      metadata {
        labels = { app = "cilium-install" }
      }
      spec {
        restart_policy = "OnFailure"
        toleration {
          operator = "Exists"
        }
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
        toleration {
          effect   = "PreferNoSchedule"
          operator = "Exists"
        }
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoExecute"
        }
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "PreferNoSchedule"
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "Exists"
                }
              }
            }
          }
        }
        service_account_name = "cilium-install"
        host_network         = true
        container {
          name  = "cilium-install"
          image = "quay.io/cilium/cilium-cli-ci:latest"
          env {
            name = "KUBERNETES_SERVICE_HOST"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "status.podIP"
              }
            }
          }
          env {
            name  = "KUBERNETES_SERVICE_PORT"
            value = "6443"
          }
          volume_mount {
            mount_path = "/root/app/values.yaml"
            name       = "values"
            sub_path   = "values"
          }
          command = [
            "cilium",
            "install",
            "--version=v1.16.5",
            "--values",
            "/root/app/values.yaml"
          ]
        }
        volume {
          name = "values"
          config_map {
            name = "cilium-values"
          }
        }
      }

    }


  }
  wait_for_completion = false
  timeouts {
    create = "4m"
    update = "4m"
    delete = "2m"
  }
}
