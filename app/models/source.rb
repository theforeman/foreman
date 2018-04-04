class Source < ApplicationRecord
  validates_lengths_from_database
  has_many :reports, :through => :logs
  has_many :logs
  validates :value, :digest, :presence => true

  def to_s
    value
  end

  def self.find_or_create(val)
    digest = Digest::SHA1.hexdigest(val)
    Source.find_by(:digest => digest) || Source.create(:value => val, :digest => digest)
  end
end
