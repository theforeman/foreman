class Token < ActiveRecord::Base
  attr_accessible :value, :expires
  belongs_to_host :foreign_key => :host_id

  validates_presence_of :value, :host_id, :expires

  def to_s
    value
  end

end
