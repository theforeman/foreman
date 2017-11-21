class UpdateOsMinor < ActiveRecord::Migration[4.2]
  class Operatingsystem < ApplicationRecord; end

  def up
    Operatingsystem.where(:minor => nil).update_all("minor = ''")
    change_column :operatingsystems, :minor, :string, :limit => 16, :default => "", :null => false
  end

  def down
    change_column :operatingsystems, :minor, :string, :limit => 16
  end
end
