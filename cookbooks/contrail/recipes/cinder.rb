#
# Cookbook Name:: contrail
# Recipe:: contrail-cinder
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

bash "cinder-params-setup" do
    user  "root"
    code <<-EOC
        sudo sed -i 's/auth_host = /;auth_host = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/auth_port = /;auth_port = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/auth_protocol = /;auth_protocol = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/admin_tenant_name = /;admin_tenant_name = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/admin_user = /;admin_user = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/admin_password = /;admin_password = /' /etc/cinder/api-paste.ini
        sudo sed -i 's/rpc_backend = cinder.openstack.common.rpc.impl_qpid/#rpc_backend = cinder.openstack.common.rpc.impl_qpid/g' /etc/cinder/cinder.conf
    EOC
end

%w{ cinder-api
    cinder-scheduler
}.each do |svc|
    service svc do
        action [:enable, :start]
    end
end

openstack_controller_node_ip = get_openstack_controller_node_ip

bash "cinder-server-setup" do
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
        /usr/bin/cinder-server-setup.sh
    EOC
end
