#
# Cookbook Name:: contrail
# Recipe:: redis
#
# Copyright 2014, Juniper Networks
#

%w{redis redis-py}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

template "/etc/redis.conf" do
    source "redis.conf.erb"
    mode 00640
    owner "redis"
    group "redis"
    notifies :restart, "service[redis]", :immediately
end

service "redis" do
    action [:enable, :start]
end
