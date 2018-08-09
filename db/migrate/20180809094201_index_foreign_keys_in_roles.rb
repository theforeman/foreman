class IndexForeignKeysInRoles < ActiveRecord::Migration[5.1]
  def change
    add_index :roles, :cloned_from_id
  end
end
