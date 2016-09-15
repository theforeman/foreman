class UpdateParameterPriorities < ActiveRecord::Migration
  def up
    Rake::Task['parameters:reset_priorities'].invoke
  end
end
