#
# Cookbook Name:: contrail
# Library:: utils
#
# Copyright 2014, Juniper Networks
#

module ::Contrail

  def get_all_roles_nodes
      result = search(:node, "chef_environment:#{node.chef_environment}")
      if result.any? { |x| x['hostname'] == node['hostname'] }
          result.map! { |x| x['hostname'] == node['hostname'] ? node : x }
      else
          result.push(node)
      end
      return result
  end

  def get_database_nodes
      result = search(:node, "role:*contrail-database* AND chef_environment:#{node.chef_environment}")
      result.map! { |x| x['hostname'] == node['hostname'] ? node : x }
      if not result.include?(node) and node.run_list.roles.include?('contrail-database')
          result.push(node)
      end
      return result
  end

  def get_config_nodes
      result = search(:node, "role:*config* AND chef_environment:#{node.chef_environment}")
      result.map! { |x| x['hostname'] == node['hostname'] ? node : x }
      if not result.include?(node) and node.run_list.roles.include?('contrail-config')
          result.push(node)
      end
      result.each { |node| node.default['contrail']['priority'] = "#{100-result.rindex(node)}" }
      return result
  end

  def get_compute_nodes
      result = search(:node, "role:*compute* AND chef_environment:#{node.chef_environment}")
      result.map! { |x| x['hostname'] == node['hostname'] ? node : x }
      if not result.include?(node) and node.run_list.roles.include?('compute')
          result.push(node)
      end
      return result
  end

  def search_for(role)
    resp = search(:node, "role:#{role} AND chef_environment:#{node.chef_environment}")
    resp ? resp : []
  end

  def get_openstack_controller_node_ip
    controller_nodes = search_for(node['contrail']['openstack_controller_role'])
    msg = "Can't find OpenStack controller node with role '#{node['contrail']['openstack_controller_role']}'"
    if controller_nodes.length < 1
      raise msg
    end
    controller_nodes.first["ipaddress"]
  end

  def get_contrail_controller_node_ip
    controller_nodes = search_for(node['contrail']['controller_role'])
    msg = "Can't find Contrail controller node with role '#{node['contrail']['controller_role']}'"
    if controller_nodes.length < 1
      raise msg
    end
    controller_nodes.first["ipaddress"]
  end

  def get_interface_address(interface)
    if node["network"]['interfaces'].key?(interface)
      node["network"]['interfaces'][interface]['addresses'].each do |ip, params|
        if params['family'] == 'inet'
          return ip
        end
      end
    end
    nil
  end

  def get_cfgm_virtual_ipaddr
      if node['contrail']['cfgm']['vip']
        return node['contrail']['cfgm']['vip']
      else
        node['ipaddress']
      end
  end

  def get_cfgm_virtual_pfxlen
      if node['contrail']['cfgm']['pfxlen']
        return node['contrail']['cfgm']['pfxlen']
      end
  end

  def set_node_number
      result = search(:node, "role:*config* AND chef_environment:#{node.chef_environment}")
      result.map! { |x| x['hostname'] == node['hostname'] ? node : x }
      if not result.include?(node) and node.run_list.roles.include?('contrail-config')
          result.push(node)
      end
      result.sort! { |a, b| a['ipaddress'] <=> b['ipaddress'] }
      result.each { |node| node.default['contrail']['node_number'] = "#{result.rindex(node)+1}" }
  end

end
