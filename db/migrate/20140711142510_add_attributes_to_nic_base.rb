class AddAttributesToNicBase < ActiveRecord::Migration
  def change
    add_column :nics, :virtual, :boolean, :default => false, :null => false
    add_column :nics, :link, :boolean, :default => true, :null => false
    add_column :nics, :identifier, :string
    add_column :nics, :tag, :string, :default => '', :null => false
    add_column :nics, :physical_device, :string, :default => '', :null => false
  end
end
