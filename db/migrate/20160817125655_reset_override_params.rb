class ResetOverrideParams < ActiveRecord::Migration[4.2]
  def up
    PuppetclassLookupKey.where(override: false).update_all(
      :merge_overrides => false,
      :avoid_duplicates => false,
      :merge_default => false
    )
  end
end
