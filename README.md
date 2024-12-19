# Homelab IaC

This repository is the primary monorepo for my selfhosted systems.
It uses ansible to apply initial configuration to a proxmox cluster and then uses
openTofu to deploy a k8s cluster on TalosLinux.

## Ansible

### Proxmox

- create_svc_acct.yaml
- delete_svc_acct.yaml
- pci_passthrough.yaml
- update_nodes.yaml

## OpenTofu

1. Deploy Virtual Networks
2. Deploy TalosLinux VMs on Proxmox
3. Bootstrap K8s
4. Install Cilium CNI
5. Bootstrap FluxCD

## K8s

- Deployed via FluxCD
- Cluster infra and apps are separated.
- Individual application stacks should be isolated from each other using namespaces and network policies

### Infra Components

- [x] Cilium CNI
- [ ] democratic-csi
- [ ] cert-manager
- [ ] bitwarden secrets manager operator
- [ ] external-dns
- [ ] kube-prometheus-stack
- [ ] postfix-smtp
- [ ] velero

## Secrets Management

- All secrets are stored in Bitwarden Secrets Manager and accessed via
  [maxlaverse/terraform-provider-bitwarden](https://search.opentofu.org/provider/maxlaverse/bitwarden/latest)
  and the [Secrets Manager Kubernetes Operator](https://bitwarden.com/help/secrets-manager-kubernetes-operator/)

## Lib

Holds templates for use in tofu and ansible, tofu modules, and various prewritten config files
for systems and apps.
