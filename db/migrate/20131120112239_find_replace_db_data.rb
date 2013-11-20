class FindReplaceDbData < ActiveRecord::Migration
  def up
    execute "UPDATE lookup_keys SET path = replace(path, 'hostgroup', 'system_group')"
    execute "UPDATE lookup_values SET match = replace(match, 'hostgroup', 'system_group')"
    execute "UPDATE bookmarks SET controller = replace(controller, 'hostgroups', 'system_groups')"
    execute "UPDATE bookmarks SET controller = replace(controller, 'hosts', 'systems')"
    execute "UPDATE bookmarks SET query = replace(query, 'hostgroup', 'system_group')"
    execute "UPDATE bookmarks SET query = replace(query, 'host', 'system')"
    execute "UPDATE bookmarks SET name = replace(name, 'hostgroup', 'system_group')"
    execute "UPDATE bookmarks SET name = replace(name, 'host', 'system')"
    execute "UPDATE taxonomies SET ignore_types = replace(ignore_types, 'Hostgroup', 'SystemGroup')"
  end

  def down
    execute "UPDATE lookup_keys SET path = replace(path, 'system_group', 'hostgroup')"
    execute "UPDATE lookup_values SET match = replace(match, 'system_group', 'hostgroup')"
    execute "UPDATE bookmarks SET controller = replace(controller, 'system_groups', 'hostgroups')"
    execute "UPDATE bookmarks SET controller = replace(controller, 'systems', 'hosts')"
    execute "UPDATE bookmarks SET query = replace(query, 'system_group', 'hostgroup')"
    execute "UPDATE bookmarks SET query = replace(query, 'system', 'host')"
    execute "UPDATE bookmarks SET name = replace(name, 'hostgroup', 'system_group')"
    execute "UPDATE bookmarks SET name = replace(name, 'host', 'system')"
    execute "UPDATE taxonomies SET ignore_types = replace(ignore_types, 'SystemGroup', 'Hostgroup')"
  end
end
