class Token < ActiveRecord::Base
  attr_accessible :value, :expires
  belongs_to_host :foreign_key => :host_id

  validates :value, :host_id, :expires, :presence => true

  def to_s
    value
  end

end
