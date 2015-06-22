#
# Cookbook Name:: contrail
# Recipe:: contrail-zookeeper
#
# Copyright 2014, Juniper Networks 
#

class ::Chef::Recipe
  include ::Contrail
end

package "zookeeper" do
    action :upgrade
end

set_node_number
database_nodes = get_database_nodes

template "/etc/zookeeper/conf/zoo.cfg" do
    source "zoo.cfg.erb"
    mode 00644
    variables(:servers => database_nodes)
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
