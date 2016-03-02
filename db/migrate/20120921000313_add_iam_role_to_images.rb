class AddIamRoleToImages < ActiveRecord::Migration
  def up
    add_column :images, :iam_role, :string, :limit => 255
  end

  def down
    remove_column :images, :iam_role
  end
end
