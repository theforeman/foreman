class TrendCounter < ActiveRecord::Base
  belongs_to :trend
  validates_numericality_of :count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :created_at, :scope => :trend_id
  default_scope :order => "created_at"
  scope :recent, lambda { |*args| {:conditions => ["created_at > ?", (args.first || 30.day.ago)], :order => "created_at"} }
end
