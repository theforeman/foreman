class AddIndexToHost < ActiveRecord::Migration[4.2]
  def up
    add_index "hosts", "last_report"
    add_index "hosts", "installed_at"
    add_index "hosts", "puppet_status"
    add_index "hosts", :domain_id, :name => 'host_domain_id_ix'
    add_index "hosts", :architecture_id, :name => 'host_arch_id_ix'
    add_index "hosts", :operatingsystem_id, :name => 'host_os_id_ix'
    add_index "hosts", :medium_id, :name => 'host_medium_id_ix'
    add_index "hosts", :hostgroup_id, :name => 'host_group_id_ix'
  end

  def down
    remove_index "hosts", "last_report"
    remove_index "hosts", "installed_at"
    remove_index "hosts", "puppet_status"
    remove_index "hosts", :name => 'host_domain_id_ix'
    remove_index "hosts", :name => 'host_arch_id_ix'
    remove_index "hosts", :name => 'host_os_id_ix'
    remove_index "hosts", :name => 'host_medium_id_ix'
    remove_index "hosts", :name => 'host_group_id_ix'
  end
end
