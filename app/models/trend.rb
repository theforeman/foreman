class Trend < ApplicationRecord
  validates_lengths_from_database
  after_save :create_values, :if => ->(o) { o.fact_value.nil? }
  after_destroy :destroy_values, :if => ->(o) { o.fact_value.nil? }

  belongs_to :trendable, :polymorphic => true
  has_many :trend_counters, :dependent => :destroy

  scope :has_value, -> { where('fact_value IS NOT NULL').order("fact_value") }
  scope :types, -> { where(:fact_value => nil) }

  def to_param
    Parameterizable.parameterize("#{id}-#{to_label}")
  end

  def self.title_name
    'label'.freeze
  end

  def self.build_trend(trend_params = {})
    (trend_params[:trendable_type] == 'FactName') ? FactTrend.new(trend_params) : ForemanTrend.new(trend_params)
  end

  private

  def destroy_values(ids = [])
    TrendCounter.where(:trend_id => ids).delete_all
    Trend.where(:id => ids).delete_all
  end
end
