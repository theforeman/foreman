class ChangeNameIndexOnFactName < ActiveRecord::Migration[4.2]
  def up
    remove_index :fact_names, :column => :name, :unique => true
    add_index :fact_names, [:name, :type], unique: true
  end

  def down
    remove_index :fact_names, [:name, :type]
    add_index :fact_names, :name, unique: true
  end
end
