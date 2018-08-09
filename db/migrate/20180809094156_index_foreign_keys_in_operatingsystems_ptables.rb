class IndexForeignKeysInOperatingsystemsPtables < ActiveRecord::Migration[5.1]
  def change
    add_index :operatingsystems_ptables, :operatingsystem_id
    add_index :operatingsystems_ptables, :ptable_id
  end
end
