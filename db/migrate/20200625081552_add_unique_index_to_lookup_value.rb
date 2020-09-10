class AddUniqueIndexToLookupValue < ActiveRecord::Migration[6.0]
  def change
    add_index :lookup_values, [:lookup_key_id, :match], unique: true
  end
end
