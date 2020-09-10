class AddIndexToLookupValues < ActiveRecord::Migration[5.2]
  def change
    add_index :lookup_values, :lookup_key_id
  end
end
