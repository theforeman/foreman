class Message < ApplicationRecord
  has_many :reports, :through => :logs
  has_many :logs
  validates_lengths_from_database
  validates :value, :digest, :presence => true

  def to_s
    value
  end

  def self.make_digest(val)
    # convert from unsinged to signed int64
    XXhash.xxh64(val) - 9_223_372_036_854_775_808
  end

  def self.make_digest_legacy(val)
    Digest::SHA1.hexdigest(val)
  end

  def self.find_or_create(val)
    digest = make_digest(val)
    Message.where(:digest => digest).first || Message.create(:value => val, :digest => digest)
  end

  def skip_strip_attrs
    ['value']
  end
end
