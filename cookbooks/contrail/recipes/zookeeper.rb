#
# Cookbook Name:: contrail
# Recipe:: contrail-zookeeper
#
# Copyright 2014, Juniper Networks 
#

package "zookeeper" do
    action :upgrade
end

template "/etc/zookeeper/conf/zoo.cfg" do
    source "zoo.cfg.erb"
    mode 00644
    variables(:servers => get_database_nodes)
    notifies :restart, "service[zookeeper]", :immediately
end

file "/etc/zookeeper/conf/myid" do
    user "root"
    group "root"
    mode 00644
    content node['contrail']['node_number']
    notifies :restart, "service[zookeeper]", :immediately
end

service "zookeeper" do
    action [:enable, :start]
end
