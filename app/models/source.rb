class Source < ApplicationRecord
  has_many :reports, :through => :logs
  has_many :logs
  validates_lengths_from_database
  validates :value, :presence => true

  def to_s
    value
  end

  def skip_strip_attrs
    ['value']
  end
end
