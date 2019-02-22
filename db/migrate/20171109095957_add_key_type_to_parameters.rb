class AddKeyTypeToParameters < ActiveRecord::Migration[4.2]
  def up
    add_column :parameters, :key_type, :string, :limit => 255
  end

  def down
    remove_column :parameters, :key_type
  end
end
