class Architecture < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystem
  validates_uniqueness_of :name
  before_destroy :ensure_not_used
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."

  def to_s
    name
  end
end
