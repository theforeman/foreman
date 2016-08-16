class ResetOverrideParams < ActiveRecord::Migration
  class LookupKey < ::ActiveRecord::Base
  end

  def up
    LookupKey.where(override: false).update_all(
      :merge_overrides => false,
      :avoid_duplicates => false,
      :merge_default => false
    )
  end
end
