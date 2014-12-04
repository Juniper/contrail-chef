#
# Cookbook Name:: contrail
# Recipe:: contrail-vrouter
#
# Copyright 2014, Juniper Networks
#

if node['contrail']['manage_nova_compute'] then
    pkgs = %w( contrail-openstack-vrouter )
else 
    if platform?("redhat", "centos", "fedora")
        pkgs = %w( contrail-nodemgr contrail-nova-vif contrail-setup contrail-vrouter contrail-vrouter-init linux-crashdump python-iniparse )
    else
        pkgs = %w( abrt contrail-nodemgr contrail-nova-vif contrail-setup contrail-vrouter contrail-vrouter-init openstack-utils python-thrift )
    end
end

if node['contrail']['haproxy'] then
    pkgs << :haproxy
end

if platform?("ubuntu") then
    File.open("/etc/init/supervisor-vrouter.override", 'a') {|f| f.write("manual") }
end

pkgs.each do |pkg|
    package pkg do
        action :upgrade
    end
end

service 'network'

template "/etc/sysconfig/network-scripts/ifcfg-vhost0" do
    source "network.vhost.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
        :interface => node['contrail']['compute']['interface'],
        :ip => node['contrail']['compute']['ip'],
        :netmask => node['contrail']['compute']['netmask'],
        :gateway => node['contrail']['compute']['gateway'],
        :dns1 => node['contrail']['compute']['dns1'],
        :dns2 => node['contrail']['compute']['dns2'],
        :dns3 => node['contrail']['compute']['dns3'],
        :domain => node['contrail']['compute']['domain']
    )
end

template "/etc/sysconfig/network-scripts/ifcfg-#{node['contrail']['compute']['interface']}" do
    source "network.eth.erb"
    variables(
        :interface => node['contrail']['compute']['interface'],
    )
end

bash "enable-vrouter" do
    user "root"
    vrouter_mod="/lib/modules/#{`uname -r`.chomp}/extra/net/vrouter/vrouter.ko"
    interface=node['contrail']['compute']['interface']
    macaddr=`cat /sys/class/net/#{interface}/address`.chomp
    code <<-EOC
        insmod #{vrouter_mod}
        sed --in-place '/^vrouter$/d' /etc/modules
        echo 'vrouter' >> /etc/modules
        vif --create vhost0 --mac #{macaddr}
        vif --add #{interface} --mac #{macaddr} --vrf 0 --vhost-phys --type physical
        vif --add vhost0 --mac #{macaddr} --vrf 0 --xconnect #{interface} --type vhost
        service network restart
    EOC
    not_if "grep -e '^vrouter$' /etc/modules"
end

template "/etc/contrail/contrail-vrouter-agent.conf" do
    source "contrail-vrouter-agent.conf.erb"
    owner "contrail"
    group "contrail"
    mode 00644
    notifies :restart, "service[contrail-vrouter-agent]", :immediately
end

%w{ contrail-vrouter-agent }.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end

%w{ supervisor-vrouter }.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end
