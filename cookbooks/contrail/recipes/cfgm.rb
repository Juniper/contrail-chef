#
# Cookbook Name:: cfgm
# Recipe:: contrail-cfgm
#
# Copyright 2014, Juniper Networks
#

package "contrail-openstack-config" do
    action :upgrade
    notifies :stop, "service[supervisor-config]", :immediately
end

%w{ ifmap-server
    contrail-config
    contrail-utils
    rabbitmq-server
}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

if not platform?("ubuntu") then
    %w{ contrail-api
        contrail-database
        contrail-device-manager
        contrail-discovery
        contrail-schema
        contrail-svc-monitor
    }.each do |svc|
        file "/etc/init.d/#{svc}" do
            owner 'root'
            group 'root'
            mode '0755'
        end
    end
end

template "/etc/rabbitmq/rabbitmq-env.conf" do
    source "rabbitmq-env.conf.erb"
    mode 0644
end

template "/etc/rabbitmq/rabbitmq.config" do
    source "rabbitmq.config.erb"
    mode 00644
    notifies :restart, "service[supervisor-support-service]", :delayed
end

template "/etc/ifmap-server/ifmap.properties" do
    source "ifmap.properties.erb"
    mode 00644
    notifies :restart, "service[ifmap]", :delayed
end

template "/etc/ifmap-server/basicauthusers.properties" do
    source "ifmap-basicauthusers.properties.erb"
    mode 00644
    variables(:servers => get_cfgm_nodes)
    notifies :restart, "service[ifmap]", :immediately
end

template "/etc/contrail/vnc_api_lib.ini" do
    source "contrail-vnc_api_lib.ini.erb"
    owner "contrail"
    group "contrail"
    mode 00644
end

%w{ contrail-discovery
    contrail-svc-monitor
    contrail-api
    contrail-schema
}.each do |pkg|
    template "/etc/contrail/#{pkg}.conf" do
        source "#{pkg}.conf.erb"
        owner "contrail"
        group "contrail"
        mode 00640
        variables(:servers => get_database_nodes)
        notifies :restart, "service[#{pkg}]", :immediately
    end
end

%w{ rabbitmq-server
    supervisor-support-service
    supervisor-config
    ifmap
    contrail-discovery
    contrail-svc-monitor
    contrail-api
    contrail-schema
}.each do |pkg|
    service pkg do
        action [:enable, :start]
    end
end

bash "provision_metadata_services" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    admin_tenant_name=node['contrail']['admin_tenant_name']
    cfgm_ip=node['contrail']['cfgm']['ip']
    code <<-EOH
        python /opt/contrail/utils/provision_linklocal.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --ipfabric_service_ip #{cfgm_ip} \
            --ipfabric_service_port 8775 \
            --api_server_ip #{cfgm_ip} \
            --linklocal_service_name metadata \
            --linklocal_service_ip 169.254.169.254 \
            --linklocal_service_port 80 \
            --oper add
    EOH
end

bash "provision_control" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    admin_tenant_name=node['contrail']['admin_tenant_name']
    cfgm_ip=node['contrail']['cfgm']['ip']
    ctrl_ip=node['contrail']['control']['ip']
    asn=node['contrail']['router_asn']
    hostname=node['contrail']['control']['hostname']
    code <<-EOH
        python /opt/contrail/utils/provision_control.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --admin_tenant_name #{admin_tenant_name} \
            --api_server_ip #{cfgm_ip} \
            --api_server_port 8082 \
            --router_asn #{asn} \
            --host_name #{hostname} \
            --host_ip #{ctrl_ip} \
            --oper add
    EOH
end

bash "provision_encap_type" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    code <<-EOH
        python /opt/contrail/utils/provision_encap.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --encap_priority MPLSoUDP,MPLSoGRE,VXLAN \
            --oper add
    EOH
end

bash "provision_vrouter" do
    user "root"
    admin_user=node['contrail']['admin_user']
    admin_password=node['contrail']['admin_password']
    admin_tenant_name=node['contrail']['admin_tenant_name']
    hostname=node['contrail']['compute']['hostname']
    hostip=node['contrail']['compute']['ip']
    cfgm_ip=node['contrail']['cfgm']['ip']
    openstack_ip=node['contrail']['openstack']['ip']
    code <<-EOH
        python /opt/contrail/utils/provision_vrouter.py \
            --admin_user #{admin_user} \
            --admin_password #{admin_password} \
            --admin_tenant_name #{admin_tenant_name} \
            --host_name #{hostname} \
            --host_ip #{hostip} \
            --api_server_ip #{cfgm_ip} \
            --openstack_ip #{openstack_ip} \
            --oper add
    EOH
end
