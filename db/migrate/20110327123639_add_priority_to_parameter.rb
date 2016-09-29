class AddPriorityToParameter < ActiveRecord::Migration
  def up
    add_column :parameters, :priority, :integer
    Parameter.reset_column_information
    Rake::Task['parameters:reset_priorities'].invoke
  end

  def down
    remove_column :parameters, :priority
  end
end
