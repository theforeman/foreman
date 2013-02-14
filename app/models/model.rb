class Model < ActiveRecord::Base
  include Authorization
  include Hostmix

  add_host_associations :has_many # Host STI
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates_uniqueness_of :name
  validates_presence_of :name
  default_scope :order => 'LOWER(models.name)'

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info

end
