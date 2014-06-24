class Trend < ActiveRecord::Base

  after_save :create_values, :if => lambda{ |o|  o.fact_value == nil }
  after_destroy :destroy_values, :if => lambda{ |o|  o.fact_value == nil }

  belongs_to :trendable, :polymorphic => true
  has_many :trend_counters, :dependent => :destroy

  scope :has_value, lambda { where('fact_value IS NOT NULL').order("fact_value") }
  scope :types, lambda { where(:fact_value => nil) }

  def to_param
    "#{id}-#{to_label.parameterize}"
  end

  private

  def destroy_values ids = []
    TrendCounter.where(:trend_id => ids).delete_all
    Trend.where(:id => ids).delete_all
  end
end
