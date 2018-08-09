class IndexForeignKeysInKeyPairs < ActiveRecord::Migration[5.1]
  def change
    add_index :key_pairs, :compute_resource_id
  end
end
