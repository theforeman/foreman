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

  validates_presence_of    :value, :host_id, :expires

  def self.find_host_id_by_token token_string
    records = Token.where("value = ? and expires >= ?", token_string, Time.now.utc)
    return false if records.size != 1
    records.first.host_id
  end

end
