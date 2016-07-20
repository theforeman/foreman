class AddMergeDefaultToLookupKey < ActiveRecord::Migration[4.2]
  def change
    add_column :lookup_keys, :merge_default, :boolean, :null => false, :default => false
  end
end
