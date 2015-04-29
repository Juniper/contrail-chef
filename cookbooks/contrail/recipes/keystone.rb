#
# Cookbook Name:: contrail
# Recipe:: contrail-keystone
#
# Copyright 2014, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

include_recipe "contrail::common"

%w{contrail-openstack}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

directory "/var/log/keystone" do
    owner "keystone"
    group "keystone"
    mode '0755'
    action :create
end

file "/var/log/keystone/keystone.log" do
    owner "keystone"
    group "keystone"
    mode '0755'
    action :create
end

service "keystone" do
    action [:enable, :start]
end

openstack_controller_node_ip = get_openstack_controller_node_ip

bash "keystone-server-setup" do
    user  "root"
    code <<-EOC
        echo "SERVICE_TOKEN=#{node['contrail']['service_token']}" > /etc/contrail/ctrl-details
        echo "SERVICE_TENANT=service" >> /etc/contrail/ctrl-details
        echo "AUTH_PROTOCOL=#{node['contrail']['protocol']['keystone']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PROTOCOL=http" >> /etc/contrail/ctrl-details
        echo "ADMIN_TOKEN=#{node['contrail']['admin_token']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER=#{openstack_controller_node_ip}" >> /etc/contrail/ctrl-details
        echo "AMQP_SERVER=#{openstack_controller_node_ip}" >> /etc/contrail/ctrl-details
        echo "QUANTUM=#{node['ipaddress']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PORT=9696" >> /etc/contrail/ctrl-details
        echo "OPENSTACK_INDEX=1" >> /etc/contrail/ctrl-details
        echo "COMPUTE=#{node['contrail']['compute']['ip']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER_MGMT=#{node['ipaddress']}" >> /etc/contrail/ctrl-details
        /usr/bin/keystone-server-setup.sh
    EOC
#    not_if { ::File.exists?("/etc/contrail/ctrl-details") }
end
