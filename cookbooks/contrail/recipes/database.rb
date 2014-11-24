#
# Cookbook Name:: contrail
# Recipe:: contrail-database
#
# Copyright 2014, Juniper Networks
#

package "contrail-openstack-database" do
    action :upgrade
    notifies :stop, "service[cassandra]", :immediately
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
    template "/etc/cassandra/#{file}" do
        source "#{file}.erb"
        mode 00644
        variables(:servers => get_database_nodes)
        notifies :restart, "service[cassandra]", :delayed
    end
end

service "cassandra" do
    action [:enable, :start]
    restart_command "service cassandra stop && service cassandra start && sleep 5"
end

%w{ supervisor-database }.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end
