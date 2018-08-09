class IndexForeignKeysInMediaOperatingsystems < ActiveRecord::Migration[5.1]
  def change
    add_index :media_operatingsystems, :medium_id
    add_index :media_operatingsystems, :operatingsystem_id
  end
end
