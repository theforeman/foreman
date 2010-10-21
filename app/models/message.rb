class Message < ActiveRecord::Base
  has_many :reports, :through => :logs
  has_many :logs
  validates_presence_of :value

  def to_s
    value
  end

end
