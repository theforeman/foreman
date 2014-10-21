class AddMergeOverridesAndAvoidDuplicatesToLookupKey < ActiveRecord::Migration
  def change
    add_column :lookup_keys, :merge_overrides, :boolean
    add_column :lookup_keys, :avoid_duplicates, :boolean
  end
end
