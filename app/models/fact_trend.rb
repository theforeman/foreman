class FactTrend < Trend
  validates :trendable_id, :uniqueness => {:scope =>  [:trendable_type, :fact_value] }
  validates_presence_of :trendable_id, :allow_blank => false

  before_save :update_fact_name

  def to_label
    name.blank? ? fact_value || fact_name : name
  end

  def type_name
    name.blank? ? fact_name : name
  end

  def create_values
    self.class.create_values(self.trendable_id)
  end

  def self.create_values(fact_name_id)
    FactValue.group(:fact_name_id, :value).where(:fact_name_id => fact_name_id).includes(:fact_name).map do |fact|
      create(:trendable_type => "FactName",
             :trendable_id => fact.fact_name.id,
             :fact_name => fact.fact_name.name,
             :fact_value => fact.value,
             :name => fact.value)
    end
  end

  def destroy_values
    ids = FactTrend.where(:trendable_id => trendable_id, :trendable_type => trendable_type).pluck(:id)
    super(ids)
  end

  def values
    return [self] if fact_value
    FactTrend.has_value.where(:trendable_type => trendable_type, :trendable_id => trendable_id)
  end

  def self.model_name
    Trend.model_name
  end

  private

  def update_fact_name
    self.fact_name = FactName.find(trendable_id).name if trendable_id
  end

end
