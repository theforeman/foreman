class Source < ActiveRecord::Base
  has_many :reports, :through => :logs
  has_many :logs
  validates_presence_of :value

  def to_s
    value
  end

  def as_json(options={})
    {:source => value }
  end
end
