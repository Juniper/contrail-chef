#
# Cookbook Name:: contrail
# Recipe:: contrail-neutron
#
# Copyright 2014, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

%w{ openstack-neutron
    neutron-plugin-contrail
    python-simplejson
    python-lxml
}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

service "neutron-server" do
    action [:enable, :start]
end

template "/etc/neutron/plugin.ini" do
    source "contrail-neutron-plugin.ini.erb"
    owner "root"
    group "root"
    mode 00644
    notifies :restart, "service[neutron-server]", :immediately
end

openstack_controller_node_ip = get_openstack_controller_node_ip

bash "neutron-server-setup" do
    user  "root"
    if node['contrail']['haproxy'] then
        quantum_port=9697
    else
        quantum_port=9696
    end
    code <<-EOC
        echo "SERVICE_TOKEN=#{node['contrail']['neutron_token']}" > /etc/contrail/ctrl-details
        echo "SERVICE_TENANT=service" >> /etc/contrail/ctrl-details
        echo "AUTH_PROTOCOL=#{node['contrail']['protocol']['keystone']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PROTOCOL=http" >> /etc/contrail/ctrl-details
        echo "ADMIN_TOKEN=#{node['contrail']['admin_token']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER=#{openstack_controller_node_ip}" >> /etc/contrail/ctrl-details
        echo "AMQP_SERVER=#{node['ipaddress']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM=#{node['ipaddress']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PORT=#{quantum_port}" >> /etc/contrail/ctrl-details
        echo "COMPUTE=#{node['contrail']['compute']['ip']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER_MGMT=#{node['ipaddress']}" >> /etc/contrail/ctrl-details
        /usr/bin/quantum-server-setup.sh
    EOC
#    not_if { ::File.exists?("/etc/contrail/ctrl-details") }
end

# setup neutron endpoint in keystone if manage_neutron flag is enabled
if node['contrail']['manage_neutron'] then
    bash "neutron-endpoint-setup" do
        user  "root"
        region=node['contrail']['region_name']
        ks_server_ip=openstack_controller_node_ip
        region=node['contrail']['region_name']
        quant_server_ip=node['ipaddress']
        admin_user=node['contrail']['admin_user']
        admin_password=node['contrail']['admin_password']
        admin_tenant_name=node['contrail']['admin_tenant_name']
        service_token=node['contrail']['service_token']
        openstack_root_pw=node['contrail']['openstack_root_pw']
        code <<-EOC
            /usr/bin/setup-quantum-in-keystone --ks_server_ip #{ks_server_ip} --quant_server_ip #{quant_server_ip} --tenant #{admin_tenant_name} --user #{admin_user} --password #{admin_password} --svc_password #{service_token} --root_password #{openstack_root_pw} --region_name #{region}
        EOC
    end
end
