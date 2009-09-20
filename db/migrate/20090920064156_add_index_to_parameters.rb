class AddIndexToParameters < ActiveRecord::Migration
  def self.up
    add_index :parameters, [:host_id, :type]
    add_index :parameters, [:hostgroup_id, :type]
    add_index :parameters, [:domain_id, :type]
    add_index :parameters, :type
  end

  def self.down
    remove_index :parameters, [:host_id, :type]
    remove_index :parameters, [:hostgroup_id, :type]
    remove_index :parameters, [:domain_id, :type]
    remove_index :parameters, :type
  end
end
