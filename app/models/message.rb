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
    self.digest ||= Digest::SHA1.hexdigest(value)
  end

  def self.find_or_create val
    digest = Digest::SHA1.hexdigest(val)
    Message.where(:digest => digest).first || Message.create(:value=>val, :digest => digest)
  end

end
