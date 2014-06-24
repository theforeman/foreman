class AddMyTaxonomyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organizations_andor,    :string, :limit => 3, :default => "or"
    add_column :users, :locations_andor, :string, :limit => 3, :default => "or"
  end

  def self.down
    remove_column :users, :organizations_andor
    remove_column :users, :locations_andor
  end
end
