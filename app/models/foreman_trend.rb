class ForemanTrend < Trend

  validates :trendable_id, :uniqueness => {:scope => :trendable_type}

  def to_label
    trendable ? trendable.to_label : trendable_type
  end

  def type_name
    name.blank? ? trendable_type : name
  end

  def chart_data(timerange = 30.day.ago)
     trend_counters.recent(timerange).map { |t|  [t.created_at.to_i*1000, t.count]  }
  end

  def create_values
    self.class.create_values(self.trendable_type)
  end

  def self.create_values(trendable_type)
    trendable_type.constantize.all.map { |t| t.trends.create(:fact_value => t.to_label)}
  end

  def destroy_values
    ForemanTrend.where(:trendable_type => trendable_type).each { |t| t.delete}
  end
end
