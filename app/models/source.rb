class Source < ActiveRecord::Base
  has_many :reports, :through => :logs
  has_many :logs
  validates_presence_of :value, :digest

  def to_s
    value
  end

  def as_json(options={})
    {:source => value }
  end

  def self.find_or_create val
    digest = Digest::SHA1.hexdigest(val)
    Source.where(:digest => digest).first || Source.create(:value => val, :digest => digest)
  end
end
