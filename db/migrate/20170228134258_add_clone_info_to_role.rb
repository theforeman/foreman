class AddCloneInfoToRole < ActiveRecord::Migration
  def change
    add_column :roles, :cloned_from_id, :integer
  end
end
