class Media < ActiveRecord::Base
  has_many :hosts
  has_one :os
  before_destroy :ensure_not_used
  validates_uniqueness_of :name
  validates_presence_of :name, :path

end
