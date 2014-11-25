#
# Cookbook Name:: cfgm
# Recipe:: contrail-cfgm
#
# Copyright 2014, Juniper Networks
#

%w{ ifmap-server
}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

package "contrail-openstack-config" do
    action :upgrade
    notifies :stop, "service[supervisor-config]", :immediately
end

template "/etc/ifmap-server/ifmap.properties" do
    source "ifmap.properties.erb"
    mode 00644
    notifies :restart, "service[ifmap]", :delayed
end

template "/etc/ifmap-server/basicauthusers.properties" do
    source "ifmap-basicauthusers.properties.erb"
    mode 00644
    variables(:servers => get_cfgm_nodes)
    notifies :restart, "service[ifmap]", :immediately
end

%w{ discovery
    svc-monitor
}.each do |pkg|
    template "/etc/contrail/contrail-#{pkg}.conf" do
        source "contrail-#{pkg}.conf.erb"
        owner "contrail"
        group "contrail"
        mode 00640
        variables(:servers => get_cfgm_nodes)
        notifies :restart, "service[contrail-#{pkg}]", :immediately
    end
end

%w{ supervisor-config
    ifmap
    contrail-discovery
    contrail-svc-monitor
}.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end
