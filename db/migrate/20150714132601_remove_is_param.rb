class RemoveIsParam < ActiveRecord::Migration
  def up
    remove_column :lookup_keys, :is_param
  end

  def down
    add_column :lookup_keys, :is_param, :boolean
  end
end
