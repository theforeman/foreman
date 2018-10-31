class AddTrendCounterCreatedAtUniqueConstraint < ActiveRecord::Migration[5.1]
  def up
    fields = [:trend_id, :created_at]
    duplicates = TrendCounter.order(created_at: :asc).select(fields)
      .group(*fields).
    having(TrendCounter.arel_table[:created_at].count.gt(1))
      .pluck(*fields)

    duplicates.each do |duplicate|
      trend_id, created_at = duplicate
      to_delete = TrendCounter.where(trend_id: trend_id, created_at: created_at).pluck(:id)[1..-1]
      say "Removing duplicate TrendCounters for Trend #{trend_id} with IDs: #{to_delete.to_sentence}"
      TrendCounter.where(id: to_delete).delete_all
    end

    add_index :trend_counters, [:trend_id, :created_at], unique: true
  end

  def down
    remove_index :trend_counters, [:trend_id, :created_at]
  end
end
