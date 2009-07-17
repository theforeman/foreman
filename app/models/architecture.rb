class Architecture < ActiveRecord::Base
  has_many :hosts
  validates_uniqueness_of :name
  before_destroy :ensure_not_used

  def to_s
    name
  end 

  private
  def ensure_not_used
    self.hosts.length == 0
  end

end
