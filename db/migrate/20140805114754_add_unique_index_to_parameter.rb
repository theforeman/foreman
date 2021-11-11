class AddUniqueIndexToParameter < ActiveRecord::Migration[4.2]
  def up
    add_index :parameters, [:type, :reference_id, :name], :unique => true
  end

  def down
    # previous version, prior to #8366 and 20141112165600_add_type_to_parameter_index
    remove_index :parameters, :column => [:reference_id, :name] if index_exists? :parameters, [:reference_id, :name], :unique => true
    remove_index :parameters, :column => [:type, :reference_id, :name] if index_exists? :parameters, [:type, :reference_id, :name], :unique => true
  end
end
