class AddTypeToParameter < ActiveRecord::Migration[4.2]
  def up
    add_column :parameters, :type, :string, :limit => 255
  end

  def down
    remove_column :parameters, :type
  end
end
