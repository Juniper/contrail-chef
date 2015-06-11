#
# Cookbook Name:: contrail
# Recipe:: contrail-database
#
# Copyright 2014, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

package "contrail-openstack-database" do
    action :upgrade
    notifies :stop, "service[supervisor-database]", :immediately
    notifies :run, "bash[remove-initial-cassandra-data-dir]", :immediately
end

bash "remove-initial-cassandra-data-dir" do
    action :nothing
    user "root"
    code <<-EOC
        TIMESTAMP=`date +%Y%m%d-%H%M%S`
        mv /var/lib/cassandra /var/lib/cassandra.$TIMESTAMP
        mkdir /var/lib/cassandra
        chown cassandra:cassandra /var/lib/cassandra
    EOC
end

%w{cassandra-env.sh cassandra-rackdc.properties cassandra.yaml}.each do |file|
    database_nodes = get_database_nodes
    if platform?("ubuntu") then
      cass_path="/etc/cassandra/"
    else
      cass_path="/etc/cassandra/conf/"
    end
    template "#{cass_path}#{file}" do
        source "#{file}.erb"
        mode 00644
        variables(:servers => database_nodes)
        notifies :restart, "service[contrail-database]", :delayed
    end
end

%w{ supervisor-database contrail-database }.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end
