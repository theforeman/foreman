class AddAttributesToNicBase < ActiveRecord::Migration[4.2]
  def change
    add_column :nics, :virtual, :boolean, :default => false, :null => false
    add_column :nics, :link, :boolean, :default => true, :null => false
    add_column :nics, :identifier, :string, :limit => 255
    add_column :nics, :tag, :string, :default => '', :null => false, :limit => 255
    add_column :nics, :physical_device, :string, :default => '', :null => false, :limit => 255
  end
end
