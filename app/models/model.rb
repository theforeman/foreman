class Model < ActiveRecord::Base
  include Authorization
  include Authorizable

  has_many_hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates :name, :uniqueness => true, :presence => true

  default_scope lambda { order('models.name') }

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info

end
