class Message < ActiveRecord::Base
  has_many :reports, :through => :logs
  has_many :logs
  validates_presence_of :value
  before_save :calc_digest

  def to_s
    value
  end

  def as_json(options={})
    {:message => value }
  end

  def calc_digest
    self.digest = Digest::SHA1.hexdigest(value)
  end

  def self.digest val
    Digest::SHA1.hexdigest(val)
  end
end
