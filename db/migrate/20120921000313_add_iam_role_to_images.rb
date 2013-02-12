class AddIamRoleToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :iam_role, :string
  end

  def self.down
    remove_column :images, :iam_role
  end
end
