#
# Cookbook Name:: contrail
# Recipe:: haproxy
#
# Copyright 2014, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

package "haproxy" do
    action :upgrade
end

#bash "enable-defaults-haproxy" do
#    user "root"
#    code <<-EOH
#        sed --in-place '/^ENABLED=/d' /etc/default/haproxy
#        echo 'ENABLED=1' >> /etc/default/haproxy
#    EOH
#    not_if "grep -e '^ENABLED=1' /etc/default/haproxy"
#end

config_nodes = get_config_nodes

template "/etc/haproxy/haproxy.cfg" do
    source "haproxy.cfg.erb"
    mode 00644
    variables(
        :servers => config_nodes,
        :nworkers => 1,
    )
    notifies :restart, "service[haproxy]", :immediately
end

service "haproxy" do
    restart_command "service haproxy stop && service haproxy start && sleep 5"
    action [:enable, :start]
end
