class AddSomeIndexes < ActiveRecord::Migration
  def self.up
    #environments_puppetclasses
    add_index :environments_puppetclasses, :puppetclass_id
    add_index :environments_puppetclasses, :environment_id
    #puppetclasses
    add_index :puppetclasses, :name
    #hostgroups_puppetclasses
    add_index :hostgroups_puppetclasses, :puppetclass_id
    add_index :hostgroups_puppetclasses, :hostgroup_id
  end

  def self.down
    #environments_puppetclasses
    remove_index :environments_puppetclasses, :puppetclass_id
    remove_index :environments_puppetclasses, :environment_id
    #puppetclasses
    remove_index :puppetclasses, :name
    #hostgroups_puppetclasses
    remove_index :hostgroups_puppetclasses, :puppetclass_id
    remove_index :hostgroups_puppetclasses, :hostgroup_id
  end
end
