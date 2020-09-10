class LimitOsDescription < ActiveRecord::Migration[4.2]
  class FakeOperatingSystem < ApplicationRecord
    self.table_name = 'operatingsystems'
  end

  def up
    FakeOperatingSystem.where("description <> ''").each do |os|
      os.update_attribute(:description, os.description.truncate(255))
    end
    change_column :operatingsystems, :description, :string, :limit => 255
  end

  def down
    change_column :operatingsystems, :description, :text
  end
end
