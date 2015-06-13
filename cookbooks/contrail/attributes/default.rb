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
default['contrail']['neutron_token'] = "c0ntrail123"
default['contrail']['service_token'] = "c0ntrail123"
default['contrail']['admin_token'] = "c0ntrail123"
default['contrail']['admin_password'] = "c0ntrail123"
default['contrail']['admin_user'] = "admin"
default['contrail']['admin_tenant_name'] = "admin"
default['contrail']['region_name'] = "RegionOne"
default['contrail']['yum_repo_url'] = "file:///opt/contrail/contrail_install_repo/"
default['contrail']['provision'] = false
# ha
default['contrail']['ha'] = true
default['contrail']['cfgm']['vip'] = "10.0.33.100"
default['contrail']['cfgm']['pfxlen'] = "24"
# Openstack
default['contrail']['openstack_controller_role'] = "contrail-openstack"
default['contrail']['openstack_root_pw'] = "contrail123"
# Keystone
default['contrail']['protocol']['keystone'] = "http"
# Control
default['contrail']['controller_role'] = "contrail-config"
# rabbitmq
default['contrail']['rabbitmq'] = true
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
