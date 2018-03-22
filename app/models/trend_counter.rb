class TrendCounter < ApplicationRecord
  belongs_to :trend
  validates :count, :numericality => {:greater_than_or_equal_to => 0}
  validates :created_at, :uniqueness => {:scope => :trend_id}
  default_scope -> { order(:created_at) }
  scope :recent, ->(*args) { where("created_at > ?", (args.first || 30.days.ago)).order(:created_at) }
end
