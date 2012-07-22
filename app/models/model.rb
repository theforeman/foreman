class Model < ActiveRecord::Base
  include Authorization
  has_many :hosts
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates_uniqueness_of :name
  validates_presence_of :name
  default_scope :order => 'LOWER(models.name)'

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info
end
