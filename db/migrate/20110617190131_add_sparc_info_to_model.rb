class AddSparcInfoToModel < ActiveRecord::Migration[4.2]
  def up
    add_column :models, :vendor_class,   :string, :limit => 32
    add_column :models, :hardware_model, :string, :limit => 16
  end

  def down
    remove_column :models, :hardware_model
    remove_column :models, :vendor_class
  end
end
