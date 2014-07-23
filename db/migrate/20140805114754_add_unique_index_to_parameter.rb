class AddUniqueIndexToParameter < ActiveRecord::Migration
  def up
    add_index :parameters, [:reference_id, :name], :unique => true
  end

  def down
    remove_index :parameters, :column => [:reference_id, :name]
  end
end
