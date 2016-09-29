class AddIndexToParameters < ActiveRecord::Migration
  def up
    add_index :parameters, [:host_id, :type]
    add_index :parameters, [:hostgroup_id, :type]
    add_index :parameters, [:domain_id, :type]
    add_index :parameters, :type
  end

  def down
    remove_index :parameters, [:host_id, :type]
    remove_index :parameters, [:hostgroup_id, :type]
    remove_index :parameters, [:domain_id, :type]
    remove_index :parameters, :type
  end
end
