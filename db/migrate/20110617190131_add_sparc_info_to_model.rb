class AddSparcInfoToModel < ActiveRecord::Migration
  def self.up
    add_column :models, :vendor_class,   :string, :limit => 32
    add_column :models, :hardware_model, :string, :limit => 16
  end

  def self.down
    remove_column :models, :hardware_model
    remove_column :models, :vendor_class
  end
end
