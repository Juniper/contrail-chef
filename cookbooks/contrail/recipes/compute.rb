#
# Cookbook Name:: contrail
# Recipe:: contrail-compute
#
# Copyright 2014, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

include_recipe "contrail::common"
include_recipe "contrail::vrouter"

%w{contrail-openstack}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

bash "add_dev_tun_in_cgroup_device_acl" do
    user "root"
    code <<-EOC
        sudo echo "clear_emulator_capabilities = 1" >> /etc/libvirt/qemu.conf
        sudo echo 'user = "root"' >> /etc/libvirt/qemu.conf
        sudo echo 'group = "root"' >> /etc/libvirt/qemu.conf
        sudo echo 'cgroup_device_acl = [' >> /etc/libvirt/qemu.conf
        sudo echo '    "/dev/null", "/dev/full", "/dev/zero",' >> /etc/libvirt/qemu.conf
        sudo echo '    "/dev/random", "/dev/urandom",' >> /etc/libvirt/qemu.conf
        sudo echo '    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",' >> /etc/libvirt/qemu.conf
        sudo echo '    "/dev/rtc", "/dev/hpet","/dev/net/tun",' >> /etc/libvirt/qemu.conf
        sudo echo ']' >> /etc/libvirt/qemu.conf
        service libvirtd restart
    EOC
    not_if "grep -e '^cgroup_device_acl' /etc/libvirt/qemu.conf"
end

service "libvirtd" do
    action [:enable, :start]
end

service "messagebus" do
    action [:enable, :start]
end

openstack_controller_node_ip = get_openstack_controller_node_ip

bash "compute-server-setup" do
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
        /usr/bin/compute-server-setup.sh
    EOC
end

service "openstack-nova-compute" do
    action [:enable, :start]
end

