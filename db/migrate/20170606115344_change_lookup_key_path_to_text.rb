class ChangeLookupKeyPathToText < ActiveRecord::Migration
  def change
    remove_index :lookup_keys, :path
    change_column :lookup_keys, :path, :text
  end
end
