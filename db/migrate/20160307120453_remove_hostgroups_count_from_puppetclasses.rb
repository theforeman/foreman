class RemoveHostgroupsCountFromPuppetclasses < ActiveRecord::Migration
  def up
    remove_column :puppetclasses, :hostgroups_count
  end

  def down
    add_column :puppetclasses, :hostgroups_count, :integer, :default => 0
    execute 'UPDATE puppetclasses SET hostgroups_count = (SELECT COUNT(*) FROM hostgroup_classes WHERE hostgroup_classes.puppetclass_id = puppetclasses.id)'
  end
end
