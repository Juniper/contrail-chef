#
# Cookbook Name:: contrail
# Recipe:: contrail-heat
#
# Copyright 2014, Juniper Networks
#

include_recipe "contrail::common"

%w{contrail-openstack}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

%w{ heat-api
    heat-engine
}.each do |svc|
    service svc do
        action [:enable, :start]
    end
end

bash "heat-server-setup" do
    user  "root"
    code <<-EOC
        echo "SERVICE_TOKEN=#{node['contrail']['service_token']}" > /etc/contrail/ctrl-details
        echo "SERVICE_TENANT=service" >> /etc/contrail/ctrl-details
        echo "AUTH_PROTOCOL=#{node['contrail']['protocol']['keystone']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PROTOCOL=http" >> /etc/contrail/ctrl-details
        echo "ADMIN_TOKEN=#{node['contrail']['admin_token']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER=#{node['contrail']['keystone']['ip']}" >> /etc/contrail/ctrl-details
        echo "AMQP_SERVER=#{openstack_controller_node_ip}" >> /etc/contrail/ctrl-details
        echo "QUANTUM=#{node['contrail']['cfgm']['ip']}" >> /etc/contrail/ctrl-details
        echo "QUANTUM_PORT=9696" >> /etc/contrail/ctrl-details
        echo "OPENSTACK_INDEX=1" >> /etc/contrail/ctrl-details
        echo "COMPUTE=#{node['contrail']['compute']['ip']}" >> /etc/contrail/ctrl-details
        echo "CONTROLLER_MGMT=#{node['contrail']['cfgm']['ip']}" >> /etc/contrail/ctrl-details
        /usr/bin/heat-server-setup.sh
    EOC
end
