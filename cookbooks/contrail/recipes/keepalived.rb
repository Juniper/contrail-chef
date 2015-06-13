#
# Cookbook Name:: contrail
# Recipe:: keppalived
#
# Copyright 2015, Juniper Networks
#

class ::Chef::Recipe
  include ::Contrail
end

package "keepalived" do
    action :upgrade
end

interface = "eth1"
virtual_ipaddr = get_cfgm_virtual_ipaddr
virtual_pfxlen = get_cfgm_virtual_pfxlen
get_database_nodes
if node['contrail']['node_number'] == "1"
  state = 'MASTER'
  preempt_delay = 7 
  delay = 5 
else
  state = 'BACKOFF'
  preempt_delay = 1 
  delay = 1 
end
get_config_nodes
priority = node['contrail']['priority']

template "/etc/keepalived/keepalived.conf" do
    source "contrail-keepalived.conf.erb"
    mode 00644
    variables(
        :interface => interface,
        :virtual_ipaddr => virtual_ipaddr,
        :virtual_pfxlen => virtual_pfxlen,
        :state => state,
        :delay => delay,
        :preempt_delay => preempt_delay,
        :garp_master_delay => delay,
        :priority => priority,
    )
    notifies :restart, "service[keepalived]", :immediately
end

service "keepalived" do
    action [:enable, :start]
end
