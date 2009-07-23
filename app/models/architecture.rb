class Architecture < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystem
  validates_uniqueness_of :name
  before_destroy :ensure_not_used

  def to_s
    name
  end 

end
