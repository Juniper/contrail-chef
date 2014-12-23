#
# Cookbook Name:: contrail
# Recipe:: contrail-common
#
# Copyright 2014, Juniper Networks
#

bash "disable-selinux" do
    user  "root"
    code <<-EOC
       sudo sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
       setenforce 0 || true
    EOC
end

bash "disable-iptables" do
    user  "root"
    code <<-EOC
        sudo chkconfig iptables off
        sudo iptables --flush
    EOC
end

bash "setp-coredump" do
    user  "root"
    code <<-EOC
       echo "TODO .. setup core dump here"
    EOC
end

