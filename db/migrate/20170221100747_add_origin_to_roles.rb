class AddOriginToRoles < ActiveRecord::Migration
  def up
    add_column :roles, :origin, :string
  end

  def down
    remove_column :roles, :origin
  end
end
