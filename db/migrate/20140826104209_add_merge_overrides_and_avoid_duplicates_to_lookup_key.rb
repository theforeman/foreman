class AddMergeOverridesAndAvoidDuplicatesToLookupKey < ActiveRecord::Migration[4.2]
  def change
    add_column :lookup_keys, :merge_overrides, :boolean
    add_column :lookup_keys, :avoid_duplicates, :boolean
  end
end
