class IndexForeignKeysInNics < ActiveRecord::Migration[5.1]
  def change
    add_index :nics, :domain_id
    add_index :nics, :subnet6_id
    add_index :nics, :subnet_id
  end
end
