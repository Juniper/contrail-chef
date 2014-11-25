#
# Cookbook Name:: cfgm
# Recipe:: contrail-cfgm
#
# Copyright 2014, Juniper Networks
#

package "contrail-openstack-config" do
    action :upgrade
    notifies :stop, "service[supervisor-config]", :immediately
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
    contrail-discovery
    contrail-svc-monitor
}.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end
