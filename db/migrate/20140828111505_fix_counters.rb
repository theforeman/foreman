class FixCounters < ActiveRecord::Migration[4.2]
  # Fix all the cached counters that were corrupted by #5692 and related bugs - no longer needed
  def up
  end

  def down
  end
end
