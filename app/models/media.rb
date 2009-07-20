class Media < ActiveRecord::Base
  has_many :hosts
  belongs_to :operatingsystem
  before_destroy :ensure_not_used
  validates_uniqueness_of :name
  validates_presence_of :name, :path

  alias_attribute :os, :operatingsystem

end
