class AddTypeToParameterIndex < ActiveRecord::Migration
  def up
    remove_index :parameters, [:reference_id, :name]
    add_index :parameters, [:reference_id, :name, :type], :unique => true
  end

  def down
    remove_index :parameters, :column => [:reference_id, :name, :type]
    add_index :parameters, [:reference_id, :name], :unique => true
  end
end
