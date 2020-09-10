class UpdateParameterPriorities < ActiveRecord::Migration[4.2]
  def up
    Rake::Task['parameters:reset_priorities'].invoke
  end
end
