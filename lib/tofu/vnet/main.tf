locals {
  comment       = "Network: ${var.name}, ${var.comment}"
  gateway_ip    = cidrhost(var.cidr, 1)
  cidr_network  = split("/", var.cidr)[0]
  cidr_bits     = split("/", var.cidr)[1]
  first_dhcp_ip = cidrhost(var.cidr, 2)
  last_dhcp_ip  = cidrhost(var.cidr, -2)
  dhcp_range    = ["${local.first_dhcp_ip}-${local.last_dhcp_ip}"]

}


resource "routeros_interface_bridge_vlan" "this" {
  bridge   = "bridge"
  vlan_ids = ["${var.id}"]
  tagged = [
    "bridge",
    "ether3",
    "ether4",
    "ether5"
  ]
  comment = local.comment
}

resource "routeros_interface_vlan" "this" {
  interface = "bridge"
  name      = var.name
  vlan_id   = var.id
  comment   = local.comment
}

resource "routeros_ip_address" "this" {
  address   = "${local.gateway_ip}/${local.cidr_bits}"
  interface = routeros_interface_vlan.this.name
  network   = local.cidr_network
  comment   = local.comment
}

resource "routeros_ip_pool" "this" {
  count = var.dhcp ? 1 : 0
  name    = var.name
  ranges  = local.dhcp_range
  comment = local.comment
}
resource "routeros_ip_dhcp_server_network" "this" {
  count = var.dhcp ? 1 : 0
  address    = var.cidr
  gateway    = local.gateway_ip
  dns_server = [local.gateway_ip]
  netmask    = local.cidr_bits
  comment    = local.comment
  ntp_server = [local.gateway_ip]
}
#
resource "routeros_ip_dhcp_server" "this" {
  count = var.dhcp ? 1 : 0
  address_pool       = routeros_ip_pool.this[0].name
  interface          = routeros_interface_vlan.this.name
  name               = var.name
  authoritative      = "yes"
  bootp_support      = "static"
  comment            = local.comment
  conflict_detection = true
  lease_time         = "6h"
}
