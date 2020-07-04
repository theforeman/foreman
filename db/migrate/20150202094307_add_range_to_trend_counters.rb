class AddRangeToTrendCounters < ActiveRecord::Migration[4.2]
  def change
    add_column :trend_counters, :interval_start, :datetime
    add_column :trend_counters, :interval_end, :datetime
  end
end
