class AddOriginToRoles < ActiveRecord::Migration[4.2]
  def up
    add_column :roles, :origin, :string
  end

  def down
    remove_column :roles, :origin
  end
end
