class HostAlias < ActiveRecord::Base
  belongs_to :domain
  belongs_to :nic, :class_name => 'Nic::Base'

  validates :nic_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :domain_id}

  def to_s
    name
  end

  def cname
    nic.host.fqdn
  end
end
