class RemoveNilFromMergeOverride < ActiveRecord::Migration[4.2]
  def up
    change_column_null :lookup_keys, :merge_overrides, false, false
    change_column_default :lookup_keys, :merge_overrides, false

    change_column_null :lookup_keys, :avoid_duplicates, false, false
    change_column_default :lookup_keys, :avoid_duplicates, false

    change_column_null :lookup_keys, :merge_default, false, false
    change_column_default :lookup_keys, :merge_default, false
  end

  def down
    change_column_default :lookup_keys, :merge_overrides, nil
    change_column_null :lookup_keys, :merge_overrides, true

    change_column_default :lookup_keys, :avoid_duplicates, nil
    change_column_null :lookup_keys, :avoid_duplicates, true

    change_column_default :lookup_keys, :merge_default, nil
    change_column_null :lookup_keys, :merge_default, true
  end
end
