class Token < ApplicationRecord
  validates_lengths_from_database
  belongs_to_host :foreign_key => :host_id

  validates :value, :host_id, :presence => true

  class Jail < ::Safemode::Jail
    allow :id, :host, :value, :expires, :nil?, :present?
  end

  def to_s
    value
  end
end
