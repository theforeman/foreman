class AddPriorityToParameter < ActiveRecord::Migration
  def up
    add_column :parameters, :priority, :integer
    Parameter.reset_column_information
    Parameter.reassign_priorities
  end

  def down
    remove_column :parameters, :priority
  end
end
