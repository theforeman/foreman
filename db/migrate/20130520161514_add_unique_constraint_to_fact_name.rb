class AddUniqueConstraintToFactName < ActiveRecord::Migration[4.2]
  def up
    remove_index(:fact_names, :column => :name) rescue nil
    add_index(:fact_names, :name, unique: true)
  end

  def down
    remove_index(:fact_names, :column => :name)
  end
end
