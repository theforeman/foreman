class Model < ActiveRecord::Base
  include Authorization
  has_many :hosts
  before_destroy Ensure_not_used_by.new(:hosts)
  validates_uniqueness_of :name
  validates_presence_of :name
end
