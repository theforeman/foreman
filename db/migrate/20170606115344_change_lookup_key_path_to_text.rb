class ChangeLookupKeyPathToText < ActiveRecord::Migration[4.2]
  def change
    remove_index :lookup_keys, :path
    change_column :lookup_keys, :path, :text
  end
end
