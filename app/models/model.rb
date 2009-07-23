class Model < ActiveRecord::Base
  has_many :hosts
  before_destroy :ensure_not_used
  validates_uniqueness_of :name
  validates_presence_of :name

  def to_label
    name
  end

end
