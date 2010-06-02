class UpdateOsMinor  < ActiveRecord::Migration
  def self.up
    Operatingsystem.update_all("minor = ''", {:minor => nil})
    change_column :operatingsystems, :minor, :string, :limit => 16, :default => "", :null => false
  end

  def self.down
    change_column :operatingsystems, :minor, :string, :limit => 16
  end
end
