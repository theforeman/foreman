class FactTrend < Trend
  validates :trendable_id, :uniqueness => {:scope =>  [:trendable_type, :fact_value] }
  validates_presence_of :trendable_id, :allow_blank => false

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
    FactValue.where(:fact_name_id => fact_name_id).group(:value).map do |fact|
      create(:trendable_type => "FactName",
             :trendable_id => fact.fact_name.id,
             :fact_name => fact.fact_name.name,
             :fact_value => fact.value,
             :name => fact.value)
    end
  end

  def destroy_values
    FactTrend.where(:trendable_id => trendable_id, :trendable_type => trendable_type).each { |t| t.delete}
  end
end
