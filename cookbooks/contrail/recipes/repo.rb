#
# Cookbook Name:: contrail
# Recipe:: centos
#
# Copyright 2014, Juniper Networks
#

# We're using yum-priorities to ensure packages in the contrail repo are used
# over and above newer versions that may exist in other repos.
package "yum-plugin-priorities" do
  action :install
end

case node["platform_family"]
when "rhel"
  yum_repository "contrail" do
    description "Contrail Packages"
    baseurl node["contrail"]["yum_repo_url"]
    gpgcheck false
    priority "1"
    action :create
  end
end
