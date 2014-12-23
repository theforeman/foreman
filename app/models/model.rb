class Model < ActiveRecord::Base
  include Authorizable
  include SearchScope::Model
  extend FriendlyId
  friendly_id :name

  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many_hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  validates_lengths_from_database
  validates :name, :uniqueness => true, :presence => true

  default_scope lambda { order('models.name') }
end
