#
# Cookbook Name:: bcpc
# Recipe:: redis
#
# Copyright 2013, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
