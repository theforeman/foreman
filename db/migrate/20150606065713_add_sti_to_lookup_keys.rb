class AddStiToLookupKeys < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :type, :string, limit: 255
    add_index :lookup_keys, :type
  end

  def down
    remove_column :lookup_keys, :type
  end
end
