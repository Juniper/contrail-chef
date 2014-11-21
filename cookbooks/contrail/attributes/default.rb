###########################################
#
#  Configuration for this cluster
#
###########################################
default['contrail']['openstack_release'] = "icehouse"
default['contrail']['multi_tenancy'] = false
default['contrail']['manage_neutron'] = false
default['contrail']['manage_nova_compute'] = true
default['contrail']['router_asn'] = 64512
default['contrail']['service_token'] = "contrail123"
default['contrail']['admin_token'] = "contrail123"
default['contrail']['haproxy'] = false
default['contrail']['management']['vip'] = "10.84.13.36"
# Keystone
default['contrail']['keystone_ip'] = "10.84.13.36"
default['contrail']['protocol']['keystone'] = "http"
# Compute
default['contrail']['compute']['interface'] = "eth1"
default['contrail']['compute']['ip'] = "10.84.13.36"
default['contrail']['compute']['netmask'] = "255.255.255.0"
default['contrail']['compute']['gateway'] = "10.84.13.254"
default['contrail']['compute']['dns1'] = "10.84.9.17"
default['contrail']['compute']['dns2'] = "10.84.5.100"
default['contrail']['compute']['dns3'] = "172.24.16.115"
default['contrail']['compute']['domain'] = "contrail.juniper.net"
