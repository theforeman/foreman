class IndexForeignKeysInLookupValues < ActiveRecord::Migration[5.1]
  def change
    add_index :lookup_values, :lookup_key_id
  end
end
