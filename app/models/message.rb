class Message < ApplicationRecord
  has_many :reports, :through => :logs
  has_many :logs
  validates_lengths_from_database
  validates :value, :digest, :presence => true

  def to_s
    value
  end

  def self.find_or_create(val)
    digest = Digest::SHA1.hexdigest(val)
    Message.find_by(:digest => digest) || Message.create(:value => val, :digest => digest)
  end

  def skip_strip_attrs
    ['value']
  end
end
