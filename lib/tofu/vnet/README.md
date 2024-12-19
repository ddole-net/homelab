# vnet
This module creates a virtual network with the following attributes:
- name
- VLAN
- subnet
- gateway
- dns-servers
- dhcp-enabled
- dhcp-options


## autoselect vlan and subnet
- use mastercard restapi_object to get list of vlan ids within range and select one.
- Do the same for subnet: on module instantiation, check that no subnets on the router overlap.


```
GET http://10.0.10.1/rest/interface/vlan
Authorization: Basic user password
```
