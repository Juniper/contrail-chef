###########################################
#
#  Configuration for this cluster
#
###########################################
default['contrail']['openstack_release'] = "icehouse"
default['contrail']['multi_tenancy'] = false
default['contrail']['manage_neutron'] = true
default['contrail']['manage_nova_compute'] = true
default['contrail']['router_asn'] = 64512
default['contrail']['service_token'] = "contrail123"
default['contrail']['admin_token'] = "contrail123"
default['contrail']['admin_password'] = "contrail123"
default['contrail']['admin_user'] = "admin"
default['contrail']['admin_tenant_name'] = "admin"
default['contrail']['haproxy'] = false
default['contrail']['cfgm']['hostname'] = "a6s35"
default['contrail']['cfgm']['ip'] = "10.84.13.35"
default['contrail']['region_name'] = node.chef_environment
# Openstack
default['contrail']['openstack']['ip'] = "10.84.13.35"
default['contrail']['openstack_root_pw'] = "contrail123"
# Keystone
default['contrail']['keystone']['ip'] = "10.84.13.35"
default['contrail']['protocol']['keystone'] = "http"
#Database
default['contrail']['database']['ip'] = "10.84.13.35"
# Control
default['contrail']['control']['ip'] = "10.84.13.35"
default['contrail']['control']['hostname'] = "a6s35"
# Analytics
default['contrail']['analytics']['ip'] = "10.84.13.35"
# Compute
default['contrail']['compute']['interface'] = "eth1"
default['contrail']['compute']['hostname'] = "a6s35"
default['contrail']['compute']['ip'] = "10.84.13.35"
default['contrail']['compute']['netmask'] = "255.255.255.0"
default['contrail']['compute']['gateway'] = "10.84.13.254"
default['contrail']['compute']['cidr'] = "10.84.13.0/24"
default['contrail']['compute']['dns1'] = "10.84.9.17"
default['contrail']['compute']['dns2'] = "10.84.5.100"
default['contrail']['compute']['dns3'] = "172.24.16.115"
default['contrail']['compute']['domain'] = "contrail.juniper.net"
