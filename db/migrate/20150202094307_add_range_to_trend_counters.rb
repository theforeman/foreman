class AddRangeToTrendCounters < ActiveRecord::Migration
  def change
    add_column :trend_counters, :interval_start, :datetime
    add_column :trend_counters, :interval_end, :datetime

    Rake::Task['trends:reduce'].invoke
  end
end
