class TrendImporter

  def self.update!
    importer = new
    importer.check_values
    importer.update_trend_counters
    importer.aggregate_counters
  end

  # Check for missing values
  # Comparing a count prior to trying to recreating them all for efficiency sake
  def check_values
    ForemanTrend.types.pluck(:trendable_type).each do |trend_type|
      changes = trend_type.constantize.pluck(:id) - ForemanTrend.has_value.where(:trendable_type => trend_type).pluck(:trendable_id)
      ForemanTrend.create_values(trend_type) unless changes.empty?
    end

    FactTrend.types.pluck(:trendable_id).each do |fact_name_id|
      changes = FactValue.where(:fact_name_id => fact_name_id).group(:value).pluck(:value) - FactTrend.has_value.where(:trendable_id => fact_name_id).pluck(:fact_value)
      FactTrend.create_values(fact_name_id) unless changes.empty?
    end
  end

  def update_trend_counters
    timestamp = Time.now
    counter_hash = Hash.new
    Trend.group(:trendable_type, :fact_name).where(:fact_value => nil).each do |trend|
      if trend.is_a? FactTrend
        counter_hash[trend.trendable_id]   = Host.joins(:fact_values).where(:fact_values => {:fact_name_id => trend.trendable_id}).group(:value).count
      else
        counter_hash[trend.trendable_type] = Host.group(trend.trendable_type.foreign_key.to_sym).count
      end
    end
    Trend.has_value.all.each do |trend|
      counter = trend.trend_counters.new
      counter.count = if trend.is_a? FactTrend
                        counter_hash[trend.trendable_id][trend.fact_value]
                      else
                        counter_hash[trend.trendable_type][trend.trendable_id]
                      end || 0
      counter.created_at = timestamp
      counter.save!
      end
  end

  def aggregate_counters

  end

end
