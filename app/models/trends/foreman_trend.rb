class ForemanTrend < Trend
  validates :trendable_id, :uniqueness => {:scope => :trendable_type}
  validates :trendable_type, :presence => true

  def to_label
    trendable ? trendable.to_label : trendable_type
  end

  def type_name
    trendable_type
  end

  def create_values
    self.class.create_values(self.trendable_type)
  end

  def self.create_values(trendable_type)
    trendable_type.constantize.all.map { |t| t.trends.create(:fact_value => t.to_label)}
  end

  def destroy_values
    ids = ForemanTrend.where(:trendable_type => trendable_type).pluck(:id)
    super(ids)
  end

  def values
    return ForemanTrend.where(:id => self) if fact_value
    ForemanTrend.has_value.where(:trendable_type => trendable_type)
  end

  def self.model_name
    Trend.model_name
  end

  def find_hosts
    return Host::Managed.none unless trendable
    trendable.hosts.order(:name)
  end
end
