class Trend < ActiveRecord::Base

  belongs_to :trendable, :polymorphic => true
  has_many :trend_counters

  scope :has_value, where('fact_value IS NOT NULL')
  scope :types, where('fact_value IS NULL')

  after_save :create_values, :if => lambda{ |o|  o.fact_value == nil }
  after_destroy :destroy_values, :if => lambda{ |o|  o.fact_value == nil }

  def to_param
    "#{id}-#{to_label.parameterize}"
  end

  def chart_data(timerange = 30.day.ago)
     trend_counters.recent(timerange).map { |t|  [t.created_at.to_i*1000, t.count]  }
  end

end
