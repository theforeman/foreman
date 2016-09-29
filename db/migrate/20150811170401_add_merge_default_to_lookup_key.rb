class AddMergeDefaultToLookupKey < ActiveRecord::Migration
  def change
    add_column :lookup_keys, :merge_default, :boolean, :null => false, :default => false
  end
end
