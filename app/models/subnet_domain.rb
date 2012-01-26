class SubnetDomain < ActiveRecord::Base
  belongs_to :domain
  belongs_to :subnet

  validates_presence_of :subnet_id, :domain_id
  validates_uniqueness_of :domain_id, :scope => :subnet_id

  def to_s
    "#{domain} : #{subnet}"
  end

end
