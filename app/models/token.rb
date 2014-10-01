class Token < ActiveRecord::Base
  validates_lengths_from_database
  belongs_to_host :foreign_key => :host_id

  validates :value, :host_id, :expires, :presence => true

  class Jail < ::Safemode::Jail
    allow :host, :value, :expires, :nil?
  end

  def to_s
    value
  end

end
