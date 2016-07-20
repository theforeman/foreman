class AddTypeToParameterIndex < ActiveRecord::Migration[4.2]
  def up
    if index_exists? :parameters, [:reference_id, :name], :unique => true
      remove_index :parameters, :column => [:reference_id, :name]
      add_index :parameters, [:type, :reference_id, :name], :unique => true
    end
  end

  def down
    remove_index :parameters, :column => [:type, :reference_id, :name]
  end
end
