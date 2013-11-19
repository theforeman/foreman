class Token < ActiveRecord::Base
  attr_accessible :value, :expires
  belongs_to_system :foreign_key => :system_id

  validates :value, :system_id, :expires, :presence => true

  def to_s
    value
  end

end
