# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  expires    :datetime
#  created_at :datetime
#  updated_at :datetime
#  host_id    :integer
#

class Token < ActiveRecord::Base
  attr_accessible :value, :expires
  belongs_to :host

  validates_presence_of :value, :host_id, :expires

  def to_s
    value
  end

end
