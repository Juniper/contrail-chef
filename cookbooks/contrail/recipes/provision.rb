#
# Cookbook Name:: contrail
# Recipe:: provision
#
# Copyright 2015, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

if node['contrail']['provision'] == false then
  puts "Provisioning is disabled... "
  exit
end

bash "provision_metadata_services" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    admin_tenant_name=node['contrail']['admin_tenant_name']
    cfgm_ip=get_cfgm_virtual_ipaddr
    code <<-EOH
        python /opt/contrail/utils/provision_linklocal.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --ipfabric_service_ip #{cfgm_ip} \
            --ipfabric_service_port 8775 \
            --api_server_ip #{cfgm_ip} \
            --linklocal_service_name metadata \
            --linklocal_service_ip 169.254.169.254 \
            --linklocal_service_port 80 \
            --oper add
    EOH
end

bash "provision_control" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    admin_tenant_name=node['contrail']['admin_tenant_name']
    cfgm_ip=get_cfgm_virtual_ipaddr
    ctrl_ip=node['ipaddress']
    asn=node['contrail']['router_asn']
    hostname=node['hostname']
    code <<-EOH
        python /opt/contrail/utils/provision_control.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --admin_tenant_name #{admin_tenant_name} \
            --api_server_ip #{cfgm_ip} \
            --api_server_port 8082 \
            --router_asn #{asn} \
            --host_name #{hostname} \
            --host_ip #{ctrl_ip} \
            --oper add
    EOH
end

bash "provision_encap_type" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    code <<-EOH
        python /opt/contrail/utils/provision_encap.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --encap_priority MPLSoUDP,MPLSoGRE,VXLAN \
            --oper add
    EOH
end

get_compute_nodes.each do |server|
    bash "provision_vrouter" do
        user "root"
        admin_user=node['contrail']['admin_user']
        admin_password=node['contrail']['admin_password']
        admin_tenant_name=node['contrail']['admin_tenant_name']
        hostname=server['hostname']
        hostip=server['ipaddress']
        cfgm_ip=get_cfgm_virtual_ipaddr
        openstack_ip=openstack_controller_node_ip
        code <<-EOH
            python /opt/contrail/utils/provision_vrouter.py \
                --admin_user #{admin_user} \
                --admin_password #{admin_password} \
                --admin_tenant_name #{admin_tenant_name} \
                --host_name #{hostname} \
                --host_ip #{hostip} \
                --api_server_ip #{cfgm_ip} \
                --openstack_ip #{openstack_ip} \
                --oper add
        EOH
    end
end
