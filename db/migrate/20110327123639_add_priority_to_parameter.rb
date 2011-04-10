class AddPriorityToParameter < ActiveRecord::Migration
  def self.up
    add_column :parameters, :priority, :integer
    Parameter.reset_column_information
    Parameter.reassign_priorities
  end

  def self.down
    remove_column :parameters, :priority
  end
end
