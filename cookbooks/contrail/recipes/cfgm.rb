#
# Cookbook Name:: cfgm
# Recipe:: contrail-cfgm
#
# Copyright 2014, Juniper Networks
#

#if platform?("redhat", "centos", "fedora")
#    yum_package "java-1.7.0-openjdk" do
#        version "1.7.0.71-2.5.3.2.el6_6"
#        allow_downgrade true
#    end
#end

class ::Chef::Recipe
  include ::Contrail
end

if node['contrail']['ha'] == true then
  include_recipe "contrail::keepalived" 
end

config_nodes = get_config_nodes
cfgm_vip = get_cfgm_virtual_ipaddr

package "contrail-openstack-config" do
    action :upgrade
    notifies :stop, "service[supervisor-config]", :immediately
end

%w{ ifmap-server
    contrail-config
    contrail-utils
}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

if not platform?("ubuntu") then
    %w{ contrail-api
        contrail-database
        contrail-device-manager
        contrail-discovery
        contrail-schema
        contrail-svc-monitor
    }.each do |svc|
        file "/etc/init.d/#{svc}" do
            owner 'root'
            group 'root'
            mode '0755'
        end
    end
end

if node['contrail']['rabbitmq'] then
    template "/etc/rabbitmq/rabbitmq-env.conf" do
        source "rabbitmq-env.conf.erb"
        mode 0644
    end

    template "/etc/rabbitmq/rabbitmq.config" do
        source "rabbitmq.config.erb"
        variables(:servers => config_nodes)
        mode 00644
        notifies :restart, "service[supervisor-support-service]", :delayed
    end

    %w{ rabbitmq-server }.each do |pkg|
        package pkg do
            action :upgrade
        end
    end

    %w{ rabbitmq-server }.each do |pkg|
        service pkg do
            action [:enable, :start]
        end
    end
end

template "/etc/ifmap-server/ifmap.properties" do
    source "ifmap.properties.erb"
    mode 00644
    notifies :restart, "service[ifmap]", :immediately
    notifies :restart, "service[contrail-api]", :immediately
end

template "/etc/ifmap-server/basicauthusers.properties" do
    source "ifmap-basicauthusers.properties.erb"
    mode 00644
    variables(:servers => config_nodes)
    #notifies :restart, "service[ifmap]", :immediately
end

begin
  openstack_controller_node_ip = get_openstack_controller_node_ip
rescue
  openstack_controller_node_ip = node['ipaddress']
end

template "/etc/contrail/vnc_api_lib.ini" do
    source "contrail-vnc_api_lib.ini.erb"
    owner "contrail"
    group "contrail"
    mode 00644
    variables(:keystone_server_ip => openstack_controller_node_ip,
              :cfgm_vip           => cfgm_vip)
end

database_nodes = get_database_nodes
if node['contrail']['ha'] == true
  rabbit_port = 5673
else
  rabbit_port = 5672
end

%w{ contrail-discovery
    contrail-svc-monitor
    contrail-api
    contrail-device-manager
    contrail-schema
}.each do |pkg|
    template "/etc/contrail/#{pkg}.conf" do
        source "#{pkg}.conf.erb"
        owner "contrail"
        group "contrail"
        mode 00640
        variables(:servers            => database_nodes,
                  :cfgm_vip           => cfgm_vip,
                  :rabbit_port        => rabbit_port,
                  :keystone_server_ip => openstack_controller_node_ip)
        notifies :restart, "service[#{pkg}]", :immediately
    end
end

%w{ contrail-config-nodemgr
}.each do |pkg|
    template "/etc/contrail/#{pkg}.conf" do
        source "#{pkg}.conf.erb"
        owner "contrail"
        group "contrail"
        mode 00640
        variables( :cfgm_vip           => cfgm_vip)
    end
end

%w{ supervisor-support-service
    ifmap
    supervisor-config
    contrail-discovery
    contrail-svc-monitor
    contrail-api
    contrail-schema
    contrail-device-manager
}.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end

