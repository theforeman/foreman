class FixCounters < ActiveRecord::Migration
  # Fix all the cached counters that were corrupted by #5692 and related bugs
  def up
    Rake::Task['fix_cached_counters'].invoke
  end

  def down
  end
end
