#
# Cookbook Name:: contrail
# Recipe:: contrail-neutron
#
# Copyright 2014, Juniper Networks
#

%w{openstack-neutron neutron-plugin-contrail}.each do |pkg|
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

bash "neutron-server-setup" do
    user  "root"
    code <<-EOC
        echo "SERVICE_TOKEN=#{node['contrail']['service_token']}" >> /etc/contrail/ctrl-details
        echo "SERVICE_TENANT=service" >> /etc/contrail/ctrl-details
        echo "AUTH_PROTOCOL=#{node['contrail']['protocol']['keystone']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PROTOCOL=http" >> /etc/contrail/ctrl-details
        echo "ADMIN_TOKEN=#{node['contrail']['admin_token']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER=#{node['contrail']['keystone']['ip']}" >> /etc/contrail/ctrl-details
        echo "AMQP_SERVER=#{node['contrail']['openstack']['ip']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM=#{node['contrail']['cfgm']['ip']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PORT=9696" >> /etc/contrail/ctrl-details
        echo "COMPUTE=#{node['contrail']['compute']['ip']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER_MGMT=#{node['contrail']['cfgm']['ip']}" >> /etc/contrail/ctrl-details
        /usr/bin/quantum-server-setup.sh
    EOC
#    not_if { ::File.exists?("/etc/contrail/ctrl-details") }
end

# setup neutron endpoint in keystone if manage_neutron flag is enabled
if node['contrail']['manage_neutron'] then
    bash "neutron-endpoint-setup" do
        user  "root"
        ks_server_ip=node['contrail']['keystone']['ip']
        quant_server_ip=node['contrail']['cfgm']['ip']
        admin_user=node['contrail']['admin_user']
        admin_password=node['contrail']['admin_password']
        admin_tenant_name=node['contrail']['admin_tenant_name']
        service_token=node['contrail']['service_token']
        openstack_root_pw=node['contrail']['openstack_root_pw']
        code <<-EOC
            /usr/bin/setup-quantum-in-keystone --ks_server_ip #{ks_server_ip} --quant_server_ip #{quant_server_ip} --tenant #{admin_tenant_name} --user #{admin_user} --password #{admin_password} --svc_password #{service_token} --root_password #{openstack_root_pw}
        EOC
    end
end
