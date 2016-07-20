class AddCloneInfoToRole < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :cloned_from_id, :integer
  end
end
