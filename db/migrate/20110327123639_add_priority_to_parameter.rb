class AddPriorityToParameter < ActiveRecord::Migration[4.2]
  def up
    add_column :parameters, :priority, :integer
  end

  def down
    remove_column :parameters, :priority
  end
end
