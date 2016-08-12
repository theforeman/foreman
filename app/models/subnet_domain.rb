class SubnetDomain < ApplicationRecord
  belongs_to :domain
  belongs_to :subnet

  validates :subnet, :presence => true
  validates :domain, :presence => true, :uniqueness => {:scope => :subnet}

  def to_s
    "#{domain} : #{subnet}"
  end
end
