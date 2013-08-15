class AddIsShowPropertyOnParameter < ActiveRecord::Migration
  def up
    add_column :parameters, :is_property, :boolean
  end

  def down
    remove_column :parameters, :is_property
  end
end
