class Model < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many_hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  validates_lengths_from_database
  validates :name, :uniqueness => true, :presence => true

  default_scope -> { order('models.name') }

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info
  scoped_search :on => :vendor_class, :complete_value => :true
  scoped_search :on => :hardware_model, :complete_value => :true
end
