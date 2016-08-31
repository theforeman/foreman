class ResetOverrideParams < ActiveRecord::Migration
  def up
    PuppetclassLookupKey.where(override: false).update_all(
      :merge_overrides => false,
      :avoid_duplicates => false,
      :merge_default => false
    )
  end
end
