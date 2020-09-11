class Source < ApplicationRecord
  has_many :reports, :through => :logs
  has_many :logs
  validates_lengths_from_database
  validates :value, :presence => true

  def to_s
    value
  end

  # DEPRECATED: use Rails method (no warning because this is called many times)
  def self.find_or_create(value)
    find_or_create_by(value: value)
  end

  def skip_strip_attrs
    ['value']
  end
end
